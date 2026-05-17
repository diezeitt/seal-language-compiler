#ifndef SEMANTIC_H
#define SEMANTIC_H
#include "parser.h"
#include <stdlib.h>

extern AST* var_buffer;
extern uint var_counter;

extern AST* function_buffer;
extern uint function_counter;

void semantic_main();

#endif
