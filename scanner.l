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
{WS}        {}

\(		{yTRACE(TOKEN_PUNC_OPEN_PAREN)}
\)		{yTRACE(TOKEN_PUNC_CLOSE_PAREN)}
;		{yTRACE(TOKEN_PUNC_SEMICOLON)}
,		{yTRACE(TOKEN_PUNC_COMMA)}
\{		{yTRACE(TOKEN_PUNC_OPEN_BRACE)}
\}		{yTRACE(TOKEN_PUNC_CLOSE_BRACE)}
\[		{yTRACE(TOKEN_PUNC_OPEN_BRACKET)}
\]		{yTRACE(TOKEN_PUNC_CLOSE_BRACKET)}

=		{yTRACE(TOKEN_OP_ASSIGNMENT)}
\+		{yTRACE(TOKEN_OP_PLUS)}
-		{yTRACE(TOKEN_OP_MINUS)}
!		{yTRACE(TOKEN_OP_NOT)}
==		{yTRACE(TOKEN_OP_EQUAL)}
!=		{yTRACE(TOKEN_OP_NOT_EQUAL)}
\<		{yTRACE(TOKEN_OP_LESS_THAN)}
\<=		{yTRACE(TOKEN_OP_LESS_THAN_OR_EQUAL)}
\>		{yTRACE(TOKEN_OP_GREATER_THAN)}
\>=		{yTRACE(TOKEN_OP_GREATER_THAN_OR_EQUAL)}
\^		{yTRACE(TOKEN_OP_POWER)}
\*		{yTRACE(TOKEN_OP_MULTIPLY)}
\/		{yTRACE(TOKEN_OP_DIVIDE)}
&&		{yTRACE(TOKEN_OP_AND)}
\|\|	{yTRACE(TOKEN_OP_OR)}

bool	{yTRACE(TOKEN_TYPE_BOOL)}
bvec2	{yTRACE(TOKEN_TYPE_BVEC2)}
bvec3	{yTRACE(TOKEN_TYPE_BVEC3)}
bvec4	{yTRACE(TOKEN_TYPE_BVEC4)}

int	    {yTRACE(TOKEN_TYPE_INT)}
ivec2	{yTRACE(TOKEN_TYPE_IVEC2)}
ivec3	{yTRACE(TOKEN_TYPE_IVEC3)}
ivec4	{yTRACE(TOKEN_TYPE_IVEC4)}

float	{yTRACE(TOKEN_TYPE_FLOAT)}
vec2	{yTRACE(TOKEN_TYPE_VEC2)}
vec3	{yTRACE(TOKEN_TYPE_VEC3)}
vec4	{yTRACE(TOKEN_TYPE_VEC4)}

lit		{yTRACE(TOKEN_FUNC_LIT)}
dp3		{yTRACE(TOKEN_FUNC_DP3)}
rsq		{yTRACE(TOKEN_FUNC_RSQ)}

gl_FragColor	{yTRACE(TOKEN_RESULT_GL_FRAGCOLOR)}
gl_FragDepth	{yTRACE(TOKEN_RESULT_GL_FRAGDEPTH)}
gl_FragCoord	{yTRACE(TOKEN_RESULT_GL_FRAGCOORD)}

gl_TexCoord		{yTRACE(TOKEN_ATTR_GL_TEXCOORD)}
gl_Color		{yTRACE(TOKEN_ATTR_GL_COLOR)}
gl_Secondary	{yTRACE(TOKEN_ATTR_GL_SECONDARY)}
gl_FogFragCoord	{yTRACE(TOKEN_ATTR_GL_FOGFRAGCOORD)}

gl_Light_Half			{yTRACE(TOKEN_UNIF_GL_LIGHT_HALF)}
gl_Light_Ambient		{yTRACE(TOKEN_UNIF_GL_LIGHT_AMBIENT)}
gl_Material_Shininess	{yTRACE(TOKEN_UNIF_GL_MATERIAL_SHININESS)}
env1					{yTRACE(TOKEN_UNIF_ENV1)}
env2					{yTRACE(TOKEN_UNIF_ENV2)}
env3					{yTRACE(TOKEN_UNIF_ENV3)}

if		{yTRACE(TOKEN_KEYWORD_IF)}
else	{yTRACE(TOKEN_KEYWORD_ELSE)}
while	{yTRACE(TOKEN_KEYWORD_WHILE)}
const	{yTRACE(TOKEN_KEYWORD_CONST)}

true    {yTRACE(TOKEN_NUM_TRUE)}
false	{yTRACE(TOKEN_NUM_FALSE)}

(0|([1-9][0-9]*))/[^0-9a-zA-Z]	{if (atoi(yytext) > MAX_INTEGER) yERROR("Integer too big") yylval.i_value = atoi(yytext); yTRACE(TOKEN_NUM_INT)}
((0|([1-9][0-9]*))?\.([0-9][0-9]*))(([Ee])-?(0|([1-9][0-9]*)))?/[^0-9a-zA-Z\.]	{yylval.f_value = atof(yytext); yTRACE(TOKEN_NUM_FLOAT)}

[a-zA-Z_][a-zA-Z0-9_]*/[^\.] {if (strlen(yytext) > MAX_IDENTIFIER) yERROR("Identifier too long") yylval.var_name = strdup(yytext); yTRACE(TOKEN_VAR)}

.           { yERROR("Unknown token"); }

<<EOF>>     {yyterminate();}

%%
