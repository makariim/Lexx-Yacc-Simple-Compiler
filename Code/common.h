
#ifndef COMMMON_H
#define COMMMON_H
 #include <string.h>

typedef enum{INT, FL, CH, STR, UNDEFINED}  data_type ;
static const char *types[] = {"Int", "Float", "Char", "String", "Undefined"};
typedef enum {INT_NODE, CHAR_NODE,FL_NODE,STR_NODE, VAR_NODE, OPR_NODE }node_type;
typedef struct node node;
typedef struct quad quad;
typedef union Data Data;
typedef struct entry entry;
typedef struct STNode *node_ptr;

#endif