

%{
        #include <stdio.h>
        #include <stdlib.h>
	#include <stdbool.h>
        #include "common.h"

        bool stmt_error = false;
        
        struct quad{
                char opr; //add //sub //assign                          
                                                                
                node* dst;
                node* src1;
                node* src2;
        };
        union Data{ //what can be stored ba2a?
                int i; //for int values
                float f; //for float values
                char c; //for char values
                char* s; //for string values or id of var
                quad* q;
        };
        struct entry{
                data_type type;
                char id[32];
		bool intialized;
                Data value;
        };
        struct node {
                node_type type;
                Data data;
        };
	// symbol table linked list structure
	struct STNode { 
		entry nodeEntry; 
		struct STNode* next; 
	}; 
        extern FILE *yyin;
        void yyerror(char *);
        int yylex(void);

        node* create_node(node_type, Data );
        quad* create_quad(char, node* src1, node* src2, node* dst);

        // get data type of a node
        data_type get_node_type(node* exp);
        void print_quad(node* stmt);
        // get value of parse tree node
        union Data get_value(node* exp);
        // *************Symbol table************* //

        typedef struct STNode *node_ptr; //Define node as pointer of data type struct LinkedList
        node_ptr create_list_node();
        // add new entry to symbol table
        // returns linked list head
        node_ptr add_list_node(node_ptr head, entry value);
        // search symbol table for entry with id
        // returns entry if found, NULL otherwise
        node_ptr get_list_node(node_ptr head, char* id);
        // check if symbol exists in the symbol table
        bool declaration_check(node_ptr head, char* id, bool sym_declared);
        // check if symbol is intialized in the symbol table
        void intialization_check(node_ptr head, char* id); 
        // print symbol table
        void print_table(node_ptr head);
        // retrieve data type of specific symbol
        data_type get_sym_type(node_ptr head, char* id); 

        // Symbol table linked list head
        node_ptr SThead = NULL;
        
%}

%union {
    
    int iValue;               
    char cValue;             
    char* sValue;
    float fValue; 
    data_type type;
    node* nPtr;
};

%token <type>DATATYPE 
%token <sValue>VARIABLE  STRING 
%token <iValue>INTEGER
%token <cValue>CHAR 
%token <fValue>FLOAT 
%token END
%left '+' '-' //in shift reduce conflicts yacc shifts

%type <nPtr> statement expr right
%%

program:
        program statements END       {
                                       //print_table(SThead);
                                        printf("done with program \n");
                                        printf("**********************************\n");
                                        exit(1);
                                        } 
        |
        ;

statements:
        statements statement ';' { 	print_table(SThead);
                                        if($2!=NULL){
                                                if($2->type==OPR_NODE){ //what actually matters
                                                        if(stmt_error)
                                                                yyerror("Error in line:");
                                                        else printf("Statment Quadruple:\n");
							print_quad($2);
                                                }}
                                                printf("**********************************\n");
                                                stmt_error = false;
                                }
        |
        ;

statement: 
        DATATYPE VARIABLE right{
                                // does the symbol already exist in the symbol table
                                if(!stmt_error && !declaration_check(SThead, $2, false)){
                                        // add the symbol to the table
                                        entry newEntry;
                                        strcpy(newEntry.id, $2);
                                        newEntry.type=$1;
                                        // if right expression exists update the variable value;
                                        if($3 != NULL){
                                                //printf("%s, %s\n", types[get_node_type($3)], types[$1]);
                                                data_type tmp_type = get_node_type($3);
                                                if (tmp_type == $1){
                                                        newEntry.value = get_value($3);
                                                        newEntry.intialized = true;
                                                        SThead = add_list_node(SThead, newEntry);
                                                }
                                                else{
                                                        char buf[100];
                                                        snprintf(buf, sizeof buf, "Assignment types mismatch %s and %s", types[$1], types[tmp_type]);
                                                        yyerror(buf);
                                                        stmt_error = true;
                                                }
                                        }
                                        else {
                                                newEntry.value = (union Data) 0;
                                                newEntry.intialized = false;
                                                SThead = add_list_node(SThead, newEntry);
                                        }
                                }
                                if($3!=NULL){
                                        node* var_nd=create_node(VAR_NODE,(union Data)$2);
                                        if($3->type==OPR_NODE)
                                        {$3->data.q->dst=var_nd; 
                                        $$=$3;}
                                        else{$$=create_node(OPR_NODE,(union Data)create_quad('=',$3,NULL,var_nd));}
                                }
                                else $$ = $3;
                                }
        | VARIABLE right        {
                                if($2!=NULL){
                                        node* var_nd=create_node(VAR_NODE,(union Data)$1);
                                        declaration_check(SThead, $1, true);
                                        
                                        if (!stmt_error){
                                                data_type tmp_type = get_node_type($2);
                                                // printf("%s, %s\n", types[tmp_type], types[get_sym_type(SThead, $1)]);
                                                if(tmp_type == get_sym_type(SThead, $1)){
                                                        node_ptr list_node = get_list_node(SThead, var_nd->data.s);
                                                        list_node->nodeEntry.value = get_value($2);
                                                        list_node->nodeEntry.intialized = true;
                                                }
                                                else{
                                                        char buf[100];
                                                        snprintf(buf, sizeof buf, "Assignment types mismatch %s and %s\n", types[get_sym_type(SThead, $1)], types[tmp_type]);
                                                        yyerror(buf);
                                                        stmt_error = true;
                                                }
                                        }
                                        if($2->type==OPR_NODE){$2->data.q->dst=var_nd; 
                                        $$=$2;}
                                        else{$$=create_node(OPR_NODE,(union Data)create_quad('=',$2,NULL,var_nd));}}
                                else{
                                        declaration_check(SThead, $1, true);
                                        $$ = NULL;
                                }}
        |                       { $$=NULL; printf("empty stmt\n");}
        |error                  {}
        
        ;
        

right:
        '=' expr        {$$=$2;}
        |               {$$=NULL;}
        ;  

expr: 
        VARIABLE        {
                        $$= create_node(VAR_NODE,(union Data)$1); 
                        intialization_check(SThead, $1);  
                        declaration_check(SThead, $1, true);}
        |INTEGER        {$$= create_node(INT_NODE,(union Data)$1);}
        |FLOAT          {$$= create_node(FL_NODE,(union Data)$1);}
        |CHAR           {$$= create_node(CHAR_NODE,(union Data)$1);}
        |STRING         {$$= create_node(STR_NODE,(union Data)$1);}
        |expr '+' expr  { //will create a quad without a dst temporarily
                        $$= create_node(OPR_NODE,(union Data)create_quad('+',$1,$3,NULL));}
        |expr '-' expr  { //will create a quad without a dst temporarily
                        $$= create_node(OPR_NODE,(union Data)create_quad('-',$1,$3,NULL));}
        |'-' INTEGER    {$$= create_node(INT_NODE,(union Data)(-1*$2));}
        |'-' FLOAT      {$$= create_node(FL_NODE,(union Data)(-1*$2));}
        ;

%%

node* create_node(node_type t, Data d ){

        //checks needed
        node* temp= malloc(sizeof(node));
        temp->type=t;
        temp->data=d;

        return temp;
}

quad* create_quad(char opr , node* src1, node* src2, node* dst){
        quad* temp=malloc(sizeof(quad));
        temp->opr=opr; //add //sub //assign 
        temp->dst=dst;
        temp->src1=src1;
        temp->src2=src2;

        return temp;
}

node_ptr create_list_node(){
    node_ptr temp;
    temp = (node_ptr)malloc(sizeof(struct STNode));
    temp->next = NULL;
    return temp;		//return the new node
}

node_ptr add_list_node(node_ptr head, entry value){
    node_ptr temp,p;
    temp = create_list_node();
    temp->nodeEntry = value;
    if(head == NULL){
        head = temp;     
    }
    else{
        p  = head;
        while(p->next != NULL){
            p = p->next;
        }
        p->next = temp;
    }
    return head;
}

node_ptr get_list_node(node_ptr head, char* id){
	node_ptr p;
	p = head;
	while(p != NULL){
		if (strcmp(p->nodeEntry.id, id) == 0)
			return p;
		p = p->next;
	}
	return NULL;
}

data_type get_sym_type(node_ptr head, char* id){
	node_ptr p = get_list_node(head, id);
	return p->nodeEntry.type;
}

data_type get_node_type(node* exp){
        if (exp->type == INT_NODE)
                return INT;
        else if (exp->type == FL_NODE)
                return FL;
        else if (exp->type == CHAR_NODE)
                return CH;
        else if (exp->type == STR_NODE)
                return STR;
        else if (exp->type == VAR_NODE)
                return get_sym_type(SThead, exp->data.s);
        else if (exp->type == OPR_NODE){
                data_type src1_type = get_node_type(exp->data.q->src1);
                data_type src2_type = get_node_type(exp->data.q->src2);
                if (src1_type + src2_type < 3){
                        if(src1_type == src2_type){
                                return src1_type;
                        }
                        else{
                                char buf[100];
                                snprintf(buf, sizeof buf, "Type mismatch: %s and %s", types[src1_type], types[src2_type]);
                                yyerror(buf);
                                stmt_error = true;
                                return UNDEFINED;
                        }
                }
                else {
                        char buf[100];
                        snprintf(buf, sizeof buf, "Operation on non-numeric types: %s and %s", types[src1_type], types[src2_type]);
                        yyerror(buf);
                        stmt_error = true;
                        return UNDEFINED;
                }
        } 
}

union Data get_value(node* exp){
        if (exp->type == INT_NODE)
                return (union Data) exp->data.i;
        else if (exp->type == FL_NODE)
                return (union Data) exp->data.f;
        else if (exp->type == CHAR_NODE)
                return (union Data) exp->data.c;
        else if (exp->type == STR_NODE)
                return (union Data) exp->data.s;
        else if (exp->type == VAR_NODE)
                return get_list_node(SThead, exp->data.s)->nodeEntry.value;
        else if (exp->type == OPR_NODE){  
                // access the integer element if int or variable of type int            
                if (exp->data.q->src1->type == INT_NODE || (exp->data.q->src1->type == VAR_NODE && get_sym_type(SThead, exp->data.q->src1->data.s) == INT)){
                        if (exp->data.q->opr == '+')
                                return (union Data) (get_value(exp->data.q->src1).i + get_value(exp->data.q->src2).i);
                        else if (exp->data.q->opr == '-')
                                return (union Data) (get_value(exp->data.q->src1).i - get_value(exp->data.q->src2).i);
                }
                // access the float element if float or variable of type float  
                else if (exp->data.q->src1->type == FL_NODE || (exp->data.q->src1->type == VAR_NODE && get_sym_type(SThead, exp->data.q->src1->data.s) == FL))
                        if (exp->data.q->opr == '+')
                                return (union Data) (get_value(exp->data.q->src1).f + get_value(exp->data.q->src2).f);
                        else if (exp->data.q->opr == '-')
                                return (union Data) (get_value(exp->data.q->src1).f - get_value(exp->data.q->src2).f);
        }
}

void intialization_check(node_ptr head, char* id){
        node_ptr list_node = get_list_node(head, id);
        if (list_node != NULL && !list_node->nodeEntry.intialized){
                char buf[100];
                snprintf(buf, sizeof buf, "unintialized variable %s", id);
                yyerror(buf);
                stmt_error = true;
        }
}

bool declaration_check(node_ptr head, char* id, bool sym_declared){
        if (sym_declared && get_list_node(head, id) == NULL){
                char buf[100];
                snprintf(buf, sizeof buf, "Undefined variable %s", id);
                yyerror(buf);
                stmt_error = true;
                return true;
        }
        else if (!sym_declared && get_list_node(head, id) != NULL){
                char buf[100];
                snprintf(buf, sizeof buf, "Variable %s multiple declaration!", id);
                yyerror(buf);
                stmt_error = true;
                return true;
        }
        return false;
}

void print_quad(node* stmt){
	node* src1_node = stmt->data.q->src1;
	node* src2_node = stmt->data.q->src2;
	node* dst_node = stmt->data.q->dst;
	char opr_c = stmt->data.q->opr;

	if(opr_c == '=')
		printf("MOV ");
	else if(opr_c == '+')
		printf("ADD ");
	else if(opr_c == '-')
		printf("SUB ");

	if(dst_node->type == VAR_NODE || dst_node->type == STR_NODE)
		printf("%s, ", dst_node->data.s);
	else if(dst_node->type == INT_NODE)
		printf("%d, ", dst_node->data.i);
	else if(dst_node->type == FL_NODE)
		printf("%f, ", dst_node->data.f);
	else if(dst_node->type == CHAR_NODE)
		printf("'%c', ", dst_node->data.c);
	if(src1_node->type == VAR_NODE || src1_node->type == STR_NODE)
		printf("%s", src1_node->data.s);
	else if(src1_node->type == INT_NODE)
		printf("%d", src1_node->data.i);
	else if(src1_node->type == FL_NODE)
		printf("%f", src1_node->data.f);
	else if(src1_node->type == CHAR_NODE)
		printf("'%c'", src1_node->data.c);
	if (src2_node != NULL){
		if(src2_node->type == VAR_NODE || src2_node->type == STR_NODE)
			printf(", %s\n", src2_node->data.s);
		else if(src2_node->type == INT_NODE)
			printf(", %d\n", src2_node->data.i);
		else if(src2_node->type == FL_NODE)
			printf(", %f\n", src2_node->data.f);
		else if(src2_node->type == CHAR_NODE)
			printf(", '%c'\n", src2_node->data.c);
	}
	else {
		printf("\n");
	}
}

void print_table(node_ptr head){
	node_ptr p;
	p = head;
	int i = 1;
        if(p!=NULL) printf("Printing Symbol Table:\n");
	while(p != NULL){
                if (p->nodeEntry.type == INT)
		        printf("table entry %d is with id %s, type %s , value = %d and intialized = %d\n", i, p->nodeEntry.id ,types[p->nodeEntry.type], p->nodeEntry.value.i, p->nodeEntry.intialized); 
                else if (p->nodeEntry.type == FL)
		        printf("table entry %d is with id %s, type %s , value = %f and intialized = %d\n", i, p->nodeEntry.id ,types[p->nodeEntry.type], p->nodeEntry.value.f, p->nodeEntry.intialized); 
		else if (p->nodeEntry.type == CH)
		        printf("table entry %d is with id %s, type %s , value = %c and intialized = %d\n", i, p->nodeEntry.id ,types[p->nodeEntry.type], p->nodeEntry.value.c, p->nodeEntry.intialized); 
		else
		        printf("table entry %d is with id %s, type %s , value = %s and intialized = %d\n", i, p->nodeEntry.id ,types[p->nodeEntry.type], p->nodeEntry.value.s, p->nodeEntry.intialized); 
                p = p->next;
                i += 1;
	}
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(int argc, char* argv[]) {
        yydebug = 0;
        char filename[100];
        strcpy(filename, argv[1]);
        if (argc == 2) {
                yyin = fopen(argv[1], "r");
        }
        else {
                printf("No files - Exit\n");
                exit(1);
        }
        // parse through the input until there is no more:
        yyparse();
        fclose(yyin);
        return 0;
}



