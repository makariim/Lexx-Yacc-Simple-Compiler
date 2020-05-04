%{
#include <stdlib.h>
#include <stdio.h>
#include "common.h"
#include "y.tab.h"
void yyerror(char *);
// int index=0;
%}

%%
"int"   {  yylval.type=INT;
            return DATATYPE; 
        }

"float" {  yylval.type=FL;
            return DATATYPE; 
        }

"char"  {  yylval.type=CH;
            return DATATYPE; 
        }

"string" {  yylval.type=STR;
            return DATATYPE;
        }

[A-Za-z_][A-Za-z0-9_]{0,31} { 
            
            yylval.sValue = malloc(strlen(yytext)+1);
            strcpy(yylval.sValue,yytext);
            return VARIABLE; 
        }

'.' { 
        yylval.cValue=*(yytext+1);
        return CHAR;
    }

[0-9]+ {
            yylval.iValue = atoi(yytext);
            
            return INTEGER;
         }

[0-9]+\.[0-9]* {
                    yylval.fValue = atof(yytext);
                    return FLOAT;
                }

\"[^\"]*\" { 
            yylval.sValue = malloc(strlen(yytext)+1);
            strcpy(yylval.sValue,yytext);
            return STRING;
     }

"+" {
    return '+';
 }

"-" {
    return '-';
 }

;+ {
        return ';';
   }


"="   return '=';


[ \t\n]+        ;       /* ignore whitespace */

"//".*                                    { /* DO NOTHING */ }

<<EOF>>     return END;

.               {yyerror("Unknown character");
                exit(1); /*commented to show different lexical errors in testcase1*/}


%%
int yywrap(void) {
    return 1;
}

