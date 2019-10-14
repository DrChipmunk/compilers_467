%{
/**********************************************************************
 *  Interface to the scanner module for CSC467 course project
 **********************************************************************/


#include "common.h"
#include "parser.tab.h"
#include "string.h"


#define YY_USER_INIT { yyin = inputFile; }
#define	yyinput      input
#define yTRACE(x)    { if (traceScanner) fprintf(traceFile, "TOKEN %3d : %s\n", x, yytext); }
#define yERROR(x)    { fprintf(errorFile, "\nLEXICAL ERROR, LINE %d: %s\n", yyline, x); errorOccurred = TRUE; yyterminate(); }
#define SCAN(__id)   { yTRACE(__id) return __id; }

int CheckInt(void);
int yyline = 1;

%}
%option noyywrap

WS          [ \t]

%%
"/*"        {
            int c1 = 0; int c2 = yyinput();
            for(;;) {
                if (c2 == 0) {
                	yERROR("Unmatched /*");
                    }
                if (c1 == '*' && c2== '/')
                    break;
                c1 = c2;
                c2 = yyinput();
                if (c1 == '\n' && c2 != EOF) {
                    yyline++;
                    }
                }
            }

\n          {yyline++;}
{WS}        { /* Your rules go below this rule and above EOF */ }

\(		{SCAN(TOKEN_PUNC_OPEN_PAREN)}
\)		{SCAN(TOKEN_PUNC_CLOSE_PAREN)}
;		{SCAN(TOKEN_PUNC_SEMICOLON)}
,		{SCAN(TOKEN_PUNC_COMMA)}
\{		{SCAN(TOKEN_PUNC_OPEN_BRACE)}
\}		{SCAN(TOKEN_PUNC_CLOSE_BRACE)}
\[		{SCAN(TOKEN_PUNC_OPEN_BRACKET)}
\]		{SCAN(TOKEN_PUNC_CLOSE_BRACKET)}

=		{SCAN(TOKEN_OP_ASSIGNMENT)}
\+		{SCAN(TOKEN_OP_PLUS)}
-		{SCAN(TOKEN_OP_MINUS)}
!		{SCAN(TOKEN_OP_NOT)}
==		{SCAN(TOKEN_OP_EQUAL)}
!=		{SCAN(TOKEN_OP_NOT_EQUAL)}
\<		{SCAN(TOKEN_OP_LESS_THAN)}
\<=		{SCAN(TOKEN_OP_LESS_THAN_OR_EQUAL)}
\>		{SCAN(TOKEN_OP_GREATER_THAN)}
\>=		{SCAN(TOKEN_OP_GREATER_THAN_OR_EQUAL)}
\^		{SCAN(TOKEN_OP_POWER)}
\*		{SCAN(TOKEN_OP_MULTIPLY)}
\/		{SCAN(TOKEN_OP_DIVIDE)}
&&		{SCAN(TOKEN_OP_AND)}
\|\|	{SCAN(TOKEN_OP_OR)}

bool	{SCAN(TOKEN_TYPE_BOOL)}
bvec2	{SCAN(TOKEN_TYPE_BVEC2)}
bvec3	{SCAN(TOKEN_TYPE_BVEC3)}
bvec4	{SCAN(TOKEN_TYPE_BVEC4)}

int	    {SCAN(TOKEN_TYPE_INT)}
ivec2	{SCAN(TOKEN_TYPE_IVEC2)}
ivec3	{SCAN(TOKEN_TYPE_IVEC3)}
ivec4	{SCAN(TOKEN_TYPE_IVEC4)}

float	{SCAN(TOKEN_TYPE_FLOAT)}
vec2	{SCAN(TOKEN_TYPE_VEC2)}
vec3	{SCAN(TOKEN_TYPE_VEC3)}
vec4	{SCAN(TOKEN_TYPE_VEC4)}

lit		{SCAN(TOKEN_FUNC_LIT)}
dp3		{SCAN(TOKEN_FUNC_DP3)}
rsq		{SCAN(TOKEN_FUNC_RSQ)}

gl_FragColor	{SCAN(TOKEN_RESULT_GL_FRAGCOLOR)}
gl_FragDepth	{SCAN(TOKEN_RESULT_GL_FRAGDEPTH)}
gl_FragCoord	{SCAN(TOKEN_RESULT_GL_FRAGCOORD)}

gl_TexCoord		{SCAN(TOKEN_ATTR_GL_TEXCOORD)}
gl_Color		{SCAN(TOKEN_ATTR_GL_COLOR)}
gl_Secondary	{SCAN(TOKEN_ATTR_GL_SECONDARY)}
gl_FogFragCoord	{SCAN(TOKEN_ATTR_GL_FOGFRAGCOORD)}

gl_Light_Half			{SCAN(TOKEN_UNIF_GL_LIGHT_HALF)}
gl_Light_Ambient		{SCAN(TOKEN_UNIF_GL_LIGHT_AMBIENT)}
gl_Material_Shininess	{SCAN(TOKEN_UNIF_GL_MATERIAL_SHININESS)}
env1					{SCAN(TOKEN_UNIF_ENV1)}
env2					{SCAN(TOKEN_UNIF_ENV2)}
env3					{SCAN(TOKEN_UNIF_ENV3)}

if		{SCAN(TOKEN_KEYWORD_IF)}
else	{SCAN(TOKEN_KEYWORD_ELSE)}
while	{SCAN(TOKEN_KEYWORD_WHILE)}
const	{SCAN(TOKEN_KEYWORD_CONST)}

true    {SCAN(TOKEN_NUM_TRUE)}
false	{SCAN(TOKEN_NUM_FALSE)}

(0|([1-9][0-9]*))/[^0-9a-zA-Z]	{if (atoi(yytext) > MAX_INTEGER) yERROR("Integer too big") yylval.i_value = atoi(yytext); SCAN(TOKEN_NUM_INT)}
((0|([1-9][0-9]*))?\.([0-9][0-9]*))(E-?(0|([1-9][0-9]*)))?/[^0-9a-zA-Z]	{yylval.f_value = atof(yytext); SCAN(TOKEN_NUM_FLOAT)}

[a-zA-Z_][a-zA-Z0-9_]* {if (strlen(yytext) > MAX_IDENTIFIER) yERROR("Identifier too long") yylval.var_name = strdup(yytext); SCAN(TOKEN_VAR)}

.           { yERROR("Unknown token"); }

<<EOF>>     {yyterminate();}

%%
