%{
/***********************************************************************
 *   Interface to the parser module for CSC467 course project.
 * 
 *   Phase 2: Implement context free grammar for source language, and
 *            parse tracing functionality.
 *   Phase 3: Construct the AST for the source language program.
 ***********************************************************************/

/***********************************************************************
 *  C Definitions and external declarations for this module.
 *
 *  Phase 3: Include ast.h if needed, and declarations for other global or
 *           external vars, functions etc. as needed.
 ***********************************************************************/

#include <string.h>
#include "common.h"
//#include "ast.h"
//#include "symbol.h"
//#include "semantic.h"
#define YYERROR_VERBOSE
#define yTRACE(x)    { if (traceParser) fprintf(traceFile, "%s\n", x); }

void yyerror(const char* s);    /* what to do in case of error            */
int yylex();              /* procedure for calling lexical analyzer */
extern int yyline;        /* variable holding current line number   */

%}

/***********************************************************************
 *  Yacc/Bison declarations.
 *  Phase 2:
 *    1. Add precedence declarations for operators (after %start declaration)
 *    2. If necessary, add %type declarations for some nonterminals
 *  Phase 3:
 *    1. Add fields to the union below to facilitate the construction of the
 *       AST (the two existing fields allow the lexical analyzer to pass back
 *       semantic info, so they shouldn't be touched).
 *    2. Add <type> modifiers to appropriate %token declarations (using the
 *       fields of the union) so that semantic information can by passed back
 *       by the scanner.
 *    3. Make the %type declarations for the language non-terminals, utilizing
 *       the fields of the union as well.
 ***********************************************************************/

%{
#define YYDEBUG 1
%}


// TODO:Modify me to add more data types
// Can access me from flex useing yyval

%union {
  int i_value;
  float f_value;
  char *var_name;
}

%token  TOKEN_VAR 

%token TOKEN_RESULT_GL_FRAGCOLOR TOKEN_RESULT_GL_FRAGDEPTH TOKEN_RESULT_GL_FRAGCOORD TOKEN_ATTR_GL_TEXCOORD TOKEN_ATTR_GL_COLOR TOKEN_ATTR_GL_SECONDARY TOKEN_ATTR_GL_FOGFRAGCOORD TOKEN_UNIF_GL_LIGHT_HALF TOKEN_UNIF_GL_LIGHT_AMBIENT TOKEN_UNIF_GL_MATERIAL_SHININESS TOKEN_UNIF_ENV1 TOKEN_UNIF_ENV2 TOKEN_UNIF_ENV3

%token TOKEN_FUNC_LIT TOKEN_FUNC_DP3 TOKEN_FUNC_RSQ

%token TOKEN_TYPE_BOOL TOKEN_TYPE_BVEC2 TOKEN_TYPE_BVEC3 TOKEN_TYPE_BVEC4 TOKEN_TYPE_INT TOKEN_TYPE_IVEC2 TOKEN_TYPE_IVEC3 TOKEN_TYPE_IVEC4 TOKEN_TYPE_FLOAT TOKEN_TYPE_VEC2 TOKEN_TYPE_VEC3 TOKEN_TYPE_VEC4

%token TOKEN_NUM_INT TOKEN_NUM_TRUE TOKEN_NUM_FALSE TOKEN_NUM_FLOAT 

%token TOKEN_KEYWORD_IF TOKEN_KEYWORD_ELSE TOKEN_KEYWORD_WHILE TOKEN_KEYWORD_CONST 

%left TOKEN_OP_OR

%left TOKEN_OP_AND

%token TOKEN_OP_EQUAL TOKEN_OP_NOT_EQUAL TOKEN_OP_LESS_THAN TOKEN_OP_LESS_THAN_OR_EQUAL TOKEN_OP_GREATER_THAN TOKEN_OP_GREATER_THAN_OR_EQUAL 

%left TOKEN_OP_PLUS TOKEN_OP_MINUS 

%left TOKEN_OP_MULTIPLY TOKEN_OP_DIVIDE 

%right TOKEN_OP_POWER

%token TOKEN_OP_NOT

%precedence UNARY

%left TOKEN_PUNC_OPEN_PAREN TOKEN_PUNC_CLOSE_PAREN TOKEN_PUNC_SEMICOLON TOKEN_PUNC_COMMA TOKEN_PUNC_OPEN_BRACE TOKEN_PUNC_CLOSE_BRACE TOKEN_PUNC_OPEN_BRACKET TOKEN_PUNC_CLOSE_BRACKET

%token TOKEN_OP_ASSIGNMENT

%start    program

%%

/***********************************************************************
 *  Yacc/Bison rules
 *  Phase 2:
 *    1. Replace grammar found here with something reflecting the source
 *       language grammar
 *    2. Implement the trace parser option of the compiler
 *  Phase 3:
 *    1. Add code to rules for construction of AST.
 ***********************************************************************/
program
  :   scope   {yTRACE("program -> scope")}   
  ;

scope
  :   TOKEN_PUNC_OPEN_BRACE declarations statements TOKEN_PUNC_CLOSE_BRACE {yTRACE("scope -> TOKEN_PUNC_OPEN_BRACE declarations statements TOKEN_PUNC_CLOSE_BRACE")}
  ;

declarations
  :   declaration declarations {yTRACE("declarations -> declaration declarations")}
  |   %empty {yTRACE("declarations -> %empty")}
  ;

statements
  :   statement statements {yTRACE("statements -> statement statements")}
  |   %empty {yTRACE("statements -> %empty")}
  ;

declaration
  :   type TOKEN_VAR TOKEN_PUNC_SEMICOLON {yTRACE("declaration -> type TOKEN_VAR TOKEN_PUNC_SEMICOLON")}
  |   type TOKEN_VAR TOKEN_OP_ASSIGNMENT expression TOKEN_PUNC_SEMICOLON {yTRACE("declaration -> type TOKEN_VAR TOKEN_OP_EQUAL expression TOKEN_PUNC_SEMICOLON")}
  |   TOKEN_KEYWORD_CONST type TOKEN_VAR TOKEN_OP_ASSIGNMENT expression TOKEN_PUNC_SEMICOLON {yTRACE("declaration -> TOKEN_KEYWORD_CONST type TOKEN_VAR TOKEN_OP_EQUAL expression TOKEN_PUNC_SEMICOLON")}
  ;

statement
  :   variable TOKEN_OP_ASSIGNMENT expression TOKEN_PUNC_SEMICOLON {yTRACE("statement -> variable TOKEN_OP_ASSIGNMENT expression TOKEN_PUNC_SEMICOLON")}
  |   TOKEN_KEYWORD_IF TOKEN_PUNC_OPEN_PAREN expression TOKEN_PUNC_CLOSE_PAREN statement {yTRACE("statement -> TOKEN_KEYWORD_IF TOKEN_PUNC_OPEN_PAREN expression TOKEN_PUNC_CLOSE_PAREN statement")}
  |   TOKEN_KEYWORD_IF TOKEN_PUNC_OPEN_PAREN expression TOKEN_PUNC_CLOSE_PAREN statement TOKEN_KEYWORD_ELSE statement {yTRACE("statement -> TOKEN_KEYWORD_IF TOKEN_PUNC_OPEN_PAREN expression TOKEN_PUNC_CLOSE_PAREN statement TOKEN_KEYWORD_ELSE statement")}
  |   TOKEN_KEYWORD_WHILE TOKEN_PUNC_OPEN_PAREN expression TOKEN_PUNC_CLOSE_PAREN statement {yTRACE("statement -> TOKEN_KEYWORD_WHILE TOKEN_PUNC_OPEN_PAREN expression TOKEN_PUNC_CLOSE_PAREN statement")}
  |   scope {yTRACE("statement -> scope")}
  |   TOKEN_PUNC_SEMICOLON {yTRACE("statement -> TOKEN_PUNC_SEMICOLON")}
  ;

type
  :     TOKEN_TYPE_BOOL  {yTRACE("type -> TOKEN_TYPE_BOOL")}
  |     TOKEN_TYPE_BVEC2 {yTRACE("type -> TOKEN_TYPE_BVEC2")}
  |     TOKEN_TYPE_BVEC3 {yTRACE("type -> TOKEN_TYPE_BVEC3")}
  |     TOKEN_TYPE_BVEC4 {yTRACE("type -> TOKEN_TYPE_BVEC4")}
  |     TOKEN_TYPE_INT   {yTRACE("type -> TOKEN_TYPE_INT")}
  |     TOKEN_TYPE_IVEC2 {yTRACE("type -> TOKEN_TYPE_IVEC2")}
  |     TOKEN_TYPE_IVEC3 {yTRACE("type -> TOKEN_TYPE_IVEC3")}
  |     TOKEN_TYPE_IVEC4 {yTRACE("type -> TOKEN_TYPE_IVEC4")}
  |     TOKEN_TYPE_FLOAT {yTRACE("type -> TOKEN_TYPE_FLOAT")}
  |     TOKEN_TYPE_VEC2  {yTRACE("type -> TOKEN_TYPE_VEC2")}
  |     TOKEN_TYPE_VEC3  {yTRACE("type -> TOKEN_TYPE_VEC3")}
  |     TOKEN_TYPE_VEC4  {yTRACE("type -> TOKEN_TYPE_VEC4")}
  ;

expression
  :     TOKEN_NUM_INT   {yTRACE("expression -> TOKEN_NUM_INT")}
  |     TOKEN_NUM_TRUE  {yTRACE("expression -> TOKEN_NUM_TRUE")}
  |     TOKEN_NUM_FALSE {yTRACE("expression -> TOKEN_NUM_FALSE")}
  |     TOKEN_NUM_FLOAT {yTRACE("expression -> TOKEN_NUM_FLOAT")}
  |     variable        {yTRACE("expression -> variable")}
  |     TOKEN_PUNC_OPEN_PAREN expression TOKEN_PUNC_CLOSE_PAREN  {yTRACE("expression -> TOKEN_PUNC_OPEN_PAREN expression TOKEN_PUNC_CLOSE_PAREN")}
  |     TOKEN_OP_MINUS expression %prec UNARY {yTRACE("expression -> TOKEN_OP_MINUS expression")}
  |     TOKEN_OP_NOT expression{yTRACE("expression -> TOKEN_OP_NOT expression")}
  |     expression binary_op expression  {yTRACE("expression -> expression binary_op expression")}
  |     constructor  {yTRACE("expression -> constructor")}
  |     function  {yTRACE("expression -> function")}
  ;

binary_op
  :     TOKEN_OP_PLUS {yTRACE("binary_op -> TOKEN_OP_PLUS")} 
  |     TOKEN_OP_MINUS {yTRACE("binary_op -> TOKEN_OP_MINUS")}  
  |     TOKEN_OP_EQUAL {yTRACE("binary_op -> TOKEN_OP_EQUAL")}  
  |     TOKEN_OP_NOT_EQUAL {yTRACE("binary_op -> TOKEN_OP_NOT_EQUAL")}  
  |     TOKEN_OP_LESS_THAN {yTRACE("binary_op -> TOKEN_OP_LESS_THAN")}  
  |     TOKEN_OP_LESS_THAN_OR_EQUAL {yTRACE("binary_op -> TOKEN_OP_LESS_THAN_OR_EQUAL")} 
  |     TOKEN_OP_GREATER_THAN {yTRACE("binary_op -> TOKEN_OP_GREATER_THAN")}  
  |     TOKEN_OP_GREATER_THAN_OR_EQUAL {yTRACE("binary_op -> TOKEN_OP_GREATER_THAN_OR_EQUAL")}  
  |     TOKEN_OP_POWER {yTRACE("binary_op -> TOKEN_OP_POWER")}  
  |     TOKEN_OP_MULTIPLY {yTRACE("binary_op -> TOKEN_OP_MULTIPLY")}  
  |     TOKEN_OP_DIVIDE {yTRACE("binary_op -> TOKEN_OP_DIVIDE")}  
  |     TOKEN_OP_AND {yTRACE("binary_op -> TOKEN_OP_AND")}  
  |     TOKEN_OP_OR {yTRACE("binary_op -> TOKEN_OP_OR")}  
  ;

variable
  :    identifier {yTRACE("variable -> identifier")}  
  |    identifier TOKEN_PUNC_OPEN_BRACKET TOKEN_NUM_INT TOKEN_PUNC_CLOSE_BRACKET {yTRACE("variable -> identifier TOKEN_PUNC_OPEN_BRACKET TOKEN_NUM_INT TOKEN_PUNC_CLOSE_BRACKET")}  
  ;

identifier
  :     TOKEN_VAR {yTRACE("identifier -> TOKEN_VAR")}  
  |     TOKEN_RESULT_GL_FRAGCOLOR {yTRACE("identifier -> TOKEN_RESULT_GL_FRAGCOLOR")}  
  |     TOKEN_RESULT_GL_FRAGDEPTH {yTRACE("identifier -> TOKEN_RESULT_GL_FRAGDEPTH")}  
  |     TOKEN_RESULT_GL_FRAGCOORD {yTRACE("identifier -> TOKEN_RESULT_GL_FRAGCOORD")} 
  |     TOKEN_ATTR_GL_TEXCOORD {yTRACE("identifier -> TOKEN_ATTR_GL_TEXCOORD")}  
  |     TOKEN_ATTR_GL_COLOR {yTRACE("identifier -> TOKEN_ATTR_GL_COLOR")}  
  |     TOKEN_ATTR_GL_SECONDARY {yTRACE("identifier -> TOKEN_ATTR_GL_SECONDARY")}  
  |     TOKEN_ATTR_GL_FOGFRAGCOORD {yTRACE("identifier -> TOKEN_ATTR_GL_FOGFRAGCOORD")} 
  |     TOKEN_UNIF_GL_LIGHT_HALF {yTRACE("identifier -> TOKEN_UNIF_GL_LIGHT_HALF")}  
  |     TOKEN_UNIF_GL_LIGHT_AMBIENT {yTRACE("identifier -> TOKEN_UNIF_GL_LIGHT_AMBIENT")}  
  |     TOKEN_UNIF_GL_MATERIAL_SHININESS {yTRACE("identifier -> TOKEN_UNIF_GL_MATERIAL_SHININESS")} 
  |     TOKEN_UNIF_ENV1 {yTRACE("identifier -> TOKEN_UNIF_ENV1")}  
  |     TOKEN_UNIF_ENV2 {yTRACE("identifier -> TOKEN_UNIF_ENV2")}  
  |     TOKEN_UNIF_ENV3 {yTRACE("identifier -> TOKEN_UNIF_ENV3")}  
  ;

constructor
  :    type TOKEN_PUNC_OPEN_PAREN arguments TOKEN_PUNC_CLOSE_PAREN {yTRACE("constructor -> type TOKEN_PUNC_OPEN_PAREN arguments TOKEN_PUNC_CLOSE_PAREN")}  
  ;

function
  :    function_name TOKEN_PUNC_OPEN_PAREN arguments TOKEN_PUNC_CLOSE_PAREN {yTRACE("function -> function_name TOKEN_PUNC_OPEN_PAREN arguments TOKEN_PUNC_CLOSE_PAREN")}
  |    function_name TOKEN_PUNC_OPEN_PAREN TOKEN_PUNC_CLOSE_PAREN {yTRACE("function -> function_name TOKEN_PUNC_OPEN_PAREN TOKEN_PUNC_CLOSE_PAREN")}
  ;

function_name
  :     TOKEN_FUNC_LIT {yTRACE("function_name -> TOKEN_FUNC_LIT")}  
  |     TOKEN_FUNC_DP3 {yTRACE("function_name -> TOKEN_FUNC_DP3")}  
  |     TOKEN_FUNC_RSQ {yTRACE("function_name -> TOKEN_FUNC_RSQ")}  
  ;

arguments
  :    expression TOKEN_PUNC_COMMA arguments {yTRACE("arguments -> expression TOKEN_PUNC_COMMA arguments")} 
  |    expression {yTRACE("arguments -> expression")} 
  ;

%%

/***********************************************************************ol
 * Extra C code.
 *
 * The given yyerror function should not be touched. You may add helper
 * functions as necessary in subsequent phases.
 ***********************************************************************/
void yyerror(const char* s) {
  if (errorOccurred)
    return;    /* Error has already been reported by scanner */
  else
    errorOccurred = 1;
        
  fprintf(errorFile, "\nPARSER ERROR, LINE %d",yyline);
  if (strcmp(s, "parse error")) {
    if (strncmp(s, "parse error, ", 13))
      fprintf(errorFile, ": %s\n", s);
    else
      fprintf(errorFile, ": %s\n", s+13);
  } else
    fprintf(errorFile, ": Reading token %s\n", yytname[YYTRANSLATE(yychar)]);
}

