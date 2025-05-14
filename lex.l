%option noyywrap

%{
#include "yacc.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%

"ghoshit"       { return GHOSHIT; }
"badlo"         { return BADLO; }
"chhapo"        { return CHHAPO; }
"yadi"          { return YADI; }
"anyatha"       { return ANYATHA; }
"anyatha_yadi"  { return ANYATHA_YADI; }
"jabtak"        { return JABTAK; }
"ke_liye"       { return KE_LIYE; }
"todo"          { return TODO; }
"aage_badho"    { return AAGE_BADHO; }
"lautao"        { return LAUTAO; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MUL; }
"/"             { return DIV; }
"%"             { return MOD; }
"="             { return ASSIGN; }
"<"             { return LT; }
">"             { return GT; }
"=="            { return EQ; }
"<="            { return LE; }
">="            { return GE; }
"!="            { return NE; }
"&&"            { return AND; }
"||"            { return OR; }
"!"             { return NOT; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
";"             { return SEMICOLON; }
[0-9]+          { yylval.ival = atoi(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*   { yylval.str = strdup(yytext); return ID; }
[ \t\n\r]+      { /* skip whitespace */ }
"##"[^\n]*      { /* skip single-line comment */ }
"##*"([^*]|[*][^#])*"*##" { /* skip multi-line comment */ }
\"[^\"]*\"      { yylval.str = strdup(yytext); return STRING; }
.               { printf("Invalid character: %s\n", yytext); }

%%