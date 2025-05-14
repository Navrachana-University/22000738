%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;
extern FILE *yyout;
int yylex(void);
void yyerror(char *s);
char* newTemp();
char* newLabel();

int tempCount = 0;
int labelCount = 0;
char* currentBreakLabel = NULL;
char* currentContinueLabel = NULL;
%}

%union {
    int ival;
    char* str;
    struct {
        char* code;  /* TAC code for the expression or statement */
        char* place; /* Temporary variable holding expression result */
        char* true_label; /* Label for true condition */
        char* false_label; /* Label for false condition */
        char* next_label; /* Label for next statement */
    } expr;
}

%token <str> ID STRING
%token <ival> NUM
%token GHOSHIT BADLO CHHAPO YADI ANYATHA ANYATHA_YADI JABTAK KE_LIYE TODO AAGE_BADHO LAUTAO
%token PLUS MINUS MUL DIV MOD ASSIGN LT GT EQ LE GE NE AND OR NOT
%token SEMICOLON LPAREN RPAREN LBRACE RBRACE

%type <expr> expression condition statement statements program if_statement if_else if_else_ladder
%type <expr> else_if_block else_if_blocks opt_else while_loop for_loop
%type <expr> for_init declaration assignment print break_stmt continue_stmt return_stmt

%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left MUL DIV MOD
%right NOT

%%

program:
    statements {
        fprintf(yyout, "%s", $1.code);
    }
    ;

statements:
    statement {
        $$.code = $1.code;
    }
    | statements statement {
        char* temp = malloc(strlen($1.code) + strlen($2.code) + 1);
        sprintf(temp, "%s%s", $1.code, $2.code);
        $$.code = temp;
    }
    ;

statement:
    declaration SEMICOLON {
        $$.code = $1.code;
    }
    | assignment SEMICOLON {
        $$.code = $1.code;
    }
    | print SEMICOLON {
        $$.code = $1.code;
    }
    | if_statement {
        $$.code = $1.code;
    }
    | while_loop {
        $$.code = $1.code;
    }
    | for_loop {
        $$.code = $1.code;
    }
    | break_stmt SEMICOLON {
        $$.code = $1.code;
    }
    | continue_stmt SEMICOLON {
        $$.code = $1.code;
    }
    | return_stmt SEMICOLON {
        $$.code = $1.code;
    }
    ;

declaration:
    GHOSHIT ID ASSIGN expression {
        char* code = malloc(strlen($4.code) + strlen($2) + strlen($4.place) + 50);
        sprintf(code, "%s%s = %s\n", $4.code, $2, $4.place);
        $$.code = code;
    }
    | GHOSHIT ID {
        $$.code = strdup("");  // Just declare, no assignment
    }
    ;

assignment:
    BADLO ID ASSIGN expression {
        char* code = malloc(strlen($4.code) + strlen($2) + strlen($4.place) + 50);
        sprintf(code, "%s%s = %s\n", $4.code, $2, $4.place);
        $$.code = code;
    }
    ;

print:
    CHHAPO expression {
        char* code = malloc(strlen($2.code) + strlen($2.place) + 50);
        sprintf(code, "%sprint %s\n", $2.code, $2.place);
        $$.code = code;
    }
    | CHHAPO STRING {
        char* code = malloc(strlen($2) + 50);
        sprintf(code, "print %s\n", $2);
        $$.code = code;
    }
    ;

expression:
    expression PLUS expression {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + strlen($1.place) + strlen($3.place) + 50);
        sprintf(code, "%s%s%s = %s + %s\n", $1.code, $3.code, temp, $1.place, $3.place);
        $$.code = code;
        $$.place = temp;
    }
    | expression MINUS expression {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + strlen($1.place) + strlen($3.place) + 50);
        sprintf(code, "%s%s%s = %s - %s\n", $1.code, $3.code, temp, $1.place, $3.place);
        $$.code = code;
        $$.place = temp;
    }
    | expression MUL expression {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + strlen($1.place) + strlen($3.place) + 50);
        sprintf(code, "%s%s%s = %s * %s\n", $1.code, $3.code, temp, $1.place, $3.place);
        $$.code = code;
        $$.place = temp;
    }
    | expression DIV expression {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + strlen($1.place) + strlen($3.place) + 50);
        sprintf(code, "%s%s%s = %s / %s\n", $1.code, $3.code, temp, $1.place, $3.place);
        $$.code = code;
        $$.place = temp;
    }
    | expression MOD expression {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + strlen($1.place) + strlen($3.place) + 50);
        sprintf(code, "%s%s%s = %s %% %s\n", $1.code, $3.code, temp, $1.place, $3.place);
        $$.code = code;
        $$.place = temp;
    }
    | expression AND expression {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + strlen($1.place) + strlen($3.place) + 50);
        sprintf(code, "%s%s%s = %s && %s\n", $1.code, $3.code, temp, $1.place, $3.place);
        $$.code = code;
        $$.place = temp;
    }
    | expression OR expression {
        char* temp = newTemp();
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + strlen($1.place) + strlen($3.place) + 50);
        sprintf(code, "%s%s%s = %s || %s\n", $1.code, $3.code, temp, $1.place, $3.place);
        $$.code = code;
        $$.place = temp;
    }
    | NOT expression {
        char* temp = newTemp();
        char* code = malloc(strlen($2.code) + strlen(temp) + strlen($2.place) + 50);
        sprintf(code, "%s%s = !%s\n", $2.code, temp, $2.place);
        $$.code = code;
        $$.place = temp;
    }
    | LPAREN expression RPAREN {
        $$.code = $2.code;
        $$.place = $2.place;
    }
    | ID {
        $$.code = strdup("");
        $$.place = strdup($1);
    }
    | NUM {
        char buf[20];
        sprintf(buf, "%d", $1);
        $$.code = strdup("");
        $$.place = strdup(buf);
    }
    ;

condition:
    expression LT expression {
        char* temp = newTemp();
        $$.true_label = newLabel();
        $$.false_label = newLabel();
        
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + 
                           strlen($1.place) + strlen($3.place) + 
                           strlen($$.true_label) + strlen($$.false_label) + 100);
                           
        sprintf(code, "%s%s%s = %s < %s\nif %s goto %s\ngoto %s\n", 
                $1.code, $3.code, temp, $1.place, $3.place, 
                temp, $$.true_label, $$.false_label);
        
        $$.code = code;
    }
    | expression GT expression {
        char* temp = newTemp();
        $$.true_label = newLabel();
        $$.false_label = newLabel();
        
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + 
                           strlen($1.place) + strlen($3.place) + 
                           strlen($$.true_label) + strlen($$.false_label) + 100);
                           
        sprintf(code, "%s%s%s = %s > %s\nif %s goto %s\ngoto %s\n", 
                $1.code, $3.code, temp, $1.place, $3.place, 
                temp, $$.true_label, $$.false_label);
        
        $$.code = code;
    }
    | expression EQ expression {
        char* temp = newTemp();
        $$.true_label = newLabel();
        $$.false_label = newLabel();
        
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + 
                           strlen($1.place) + strlen($3.place) + 
                           strlen($$.true_label) + strlen($$.false_label) + 100);
                           
        sprintf(code, "%s%s%s = %s == %s\nif %s goto %s\ngoto %s\n", 
                $1.code, $3.code, temp, $1.place, $3.place, 
                temp, $$.true_label, $$.false_label);
        
        $$.code = code;
    }
    | expression LE expression {
        char* temp = newTemp();
        $$.true_label = newLabel();
        $$.false_label = newLabel();
        
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + 
                           strlen($1.place) + strlen($3.place) + 
                           strlen($$.true_label) + strlen($$.false_label) + 100);
                           
        sprintf(code, "%s%s%s = %s <= %s\nif %s goto %s\ngoto %s\n", 
                $1.code, $3.code, temp, $1.place, $3.place, 
                temp, $$.true_label, $$.false_label);
        
        $$.code = code;
    }
    | expression GE expression {
        char* temp = newTemp();
        $$.true_label = newLabel();
        $$.false_label = newLabel();
        
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + 
                           strlen($1.place) + strlen($3.place) + 
                           strlen($$.true_label) + strlen($$.false_label) + 100);
                           
        sprintf(code, "%s%s%s = %s >= %s\nif %s goto %s\ngoto %s\n", 
                $1.code, $3.code, temp, $1.place, $3.place, 
                temp, $$.true_label, $$.false_label);
        
        $$.code = code;
    }
    | expression NE expression {
        char* temp = newTemp();
        $$.true_label = newLabel();
        $$.false_label = newLabel();
        
        char* code = malloc(strlen($1.code) + strlen($3.code) + strlen(temp) + 
                           strlen($1.place) + strlen($3.place) + 
                           strlen($$.true_label) + strlen($$.false_label) + 100);
                           
        sprintf(code, "%s%s%s = %s != %s\nif %s goto %s\ngoto %s\n", 
                $1.code, $3.code, temp, $1.place, $3.place, 
                temp, $$.true_label, $$.false_label);
        
        $$.code = code;
    }
    ;

if_statement:
    YADI LPAREN condition RPAREN LBRACE statements RBRACE {
        char* next_label = newLabel();
        
        char* code = malloc(strlen($3.code) + strlen($6.code) + 
                           strlen($3.true_label) + strlen($3.false_label) + 
                           strlen(next_label) + 100);
                           
        sprintf(code, "%s%s:\n%sgoto %s\n%s:\n", 
                $3.code, $3.true_label, $6.code, next_label, $3.false_label);
        
        if (strstr($6.code, "break") || strstr($6.code, "continue")) {
            // Handle loops with break/continue
            sprintf(code, "%s%s:\n%s%s:\n", 
                    $3.code, $3.true_label, $6.code, $3.false_label);
        } else {
            sprintf(code, "%s%s:\n%sgoto %s\n%s:\n", 
                    $3.code, $3.true_label, $6.code, next_label, $3.false_label);
        }
        
        $$.next_label = next_label;
        $$.code = code;
    }
    | if_else {
        $$.code = $1.code;
        $$.next_label = $1.next_label;
    }
    | if_else_ladder {
        $$.code = $1.code;
        $$.next_label = $1.next_label;
    }
    ;

if_else:
    YADI LPAREN condition RPAREN LBRACE statements RBRACE ANYATHA LBRACE statements RBRACE {
        char* next_label = newLabel();
        
        char* code = malloc(strlen($3.code) + strlen($6.code) + 
                           strlen($10.code) + strlen($3.true_label) + 
                           strlen($3.false_label) + strlen(next_label) + 200);
                           
        sprintf(code, "%s%s:\n%sgoto %s\n%s:\n%s%s:\n", 
                $3.code, $3.true_label, $6.code, next_label, 
                $3.false_label, $10.code, next_label);
        
        $$.next_label = next_label;
        $$.code = code;
    }
    ;

if_else_ladder:
    YADI LPAREN condition RPAREN LBRACE statements RBRACE else_if_blocks opt_else {
        char* next_label = newLabel();
        
        // Allocate sufficient memory for the code
        char* code = malloc(strlen($3.code) + strlen($6.code) + 
                           strlen($8.code) + strlen($9.code) + 
                           strlen($3.true_label) + strlen($3.false_label) + 
                           strlen(next_label) + 200);
                           
        sprintf(code, "%s%s:\n%sgoto %s\n%s:\n%s%s%s:\n", 
                $3.code, $3.true_label, $6.code, next_label, 
                $3.false_label, $8.code, $9.code, next_label);
        
        $$.next_label = next_label;
        $$.code = code;
    }
    ;

else_if_blocks:
    else_if_block {
        $$.code = $1.code;
    }
    | else_if_blocks else_if_block {
        char* code = malloc(strlen($1.code) + strlen($2.code) + 2);
        sprintf(code, "%s%s", $1.code, $2.code);
        $$.code = code;
    }
    ;

else_if_block:
    ANYATHA_YADI LPAREN condition RPAREN LBRACE statements RBRACE {
        char* next_label = newLabel();
        
        char* code = malloc(strlen($3.code) + strlen($6.code) + 
                           strlen($3.true_label) + strlen($3.false_label) + 
                           strlen(next_label) + 100);
                           
        sprintf(code, "%s%s:\n%sgoto %s\n%s:\n", 
                $3.code, $3.true_label, $6.code, next_label, $3.false_label);
        
        $$.next_label = next_label;
        $$.code = code;
    }
    ;

opt_else:
    {
        $$.code = strdup("");
    }
    | ANYATHA LBRACE statements RBRACE {
        $$.code = $3.code;
    }
    ;

while_loop:
    JABTAK LPAREN condition RPAREN LBRACE {
        currentBreakLabel = newLabel();      // L_break for the loop
        currentContinueLabel = newLabel();   // L_continue for the loop
    } statements RBRACE {
        char* loop_start = newLabel();
        
        char* code = malloc(strlen(loop_start) + strlen($3.code) + 
                           strlen($7.code) + strlen($3.true_label) + 
                           strlen($3.false_label) + strlen(currentBreakLabel) + 
                           strlen(currentContinueLabel) + 200);
                           
        sprintf(code, "%s:\n%s%s:\n%s%s:\ngoto %s\n%s:\n", 
                loop_start, $3.code, $3.true_label, $7.code, 
                currentContinueLabel, loop_start, $3.false_label);
        
        // Add the break label at the end
        char* fullCode = malloc(strlen(code) + strlen(currentBreakLabel) + 10);
        sprintf(fullCode, "%s%s:\n", code, currentBreakLabel);
        
        $$.code = fullCode;
        
        currentBreakLabel = NULL;
        currentContinueLabel = NULL;
    }
    ;

for_loop:
    KE_LIYE LPAREN for_init SEMICOLON {
        currentBreakLabel = newLabel();      // L_break for the loop
        currentContinueLabel = newLabel();   // L_continue for the loop
    } condition SEMICOLON assignment RPAREN LBRACE statements RBRACE {
        char* loop_start = newLabel();
        char* body_label = newLabel();
        
        char* code = malloc(strlen($3.code) + strlen(loop_start) + 
                          strlen($6.code) + strlen($8.code) + 
                          strlen($11.code) + strlen($6.true_label) + 
                          strlen($6.false_label) + strlen(body_label) + 
                          strlen(currentBreakLabel) + strlen(currentContinueLabel) + 500);
                          
        sprintf(code, "%s%s:\n%s%s:\n%s%s:\n%sgoto %s\n%s:\n%s:\n", 
                $3.code,                 // initialization: i = 0
                loop_start,              // L_start:
                $6.code,                 // condition: t0 = i < 5, if t0 goto L_body, goto L_end
                $6.true_label,           // L_body:
                $11.code,                // loop body: print i
                currentContinueLabel,    // L_continue:
                $8.code,                 // increment: i = i + 1
                loop_start,              // goto L_start
                $6.false_label,          // L_end:
                currentBreakLabel);      // L_break:
        
        $$.code = code;
        
        currentBreakLabel = NULL;
        currentContinueLabel = NULL;
    }
    ;

for_init:
    declaration {
        $$.code = $1.code;
    }
    | assignment {
        $$.code = $1.code;
    }
    ;

break_stmt:
    TODO {
        if (currentBreakLabel) {
            char* code = malloc(strlen(currentBreakLabel) + 20);
            sprintf(code, "goto %s\n", currentBreakLabel);
            $$.code = code;
        } else {
            $$.code = strdup("# Error: break outside loop\n");
        }
    }
    ;

continue_stmt:
    AAGE_BADHO {
        if (currentContinueLabel) {
            char* code = malloc(strlen(currentContinueLabel) + 20);
            sprintf(code, "goto %s\n", currentContinueLabel);
            $$.code = code;
        } else {
            $$.code = strdup("# Error: continue outside loop\n");
        }
    }
    ;

return_stmt:
    LAUTAO expression {
        char* code = malloc(strlen($2.code) + strlen($2.place) + 50);
        sprintf(code, "%sreturn %s\n", $2.code, $2.place);
        $$.code = code;
    }
    ;

%%

char* newTemp() {
    char buffer[20];
    sprintf(buffer, "t%d", tempCount++);
    return strdup(buffer);
}

char* newLabel() {
    char buffer[20];
    sprintf(buffer, "L%d", labelCount++);
    return strdup(buffer);
}

void yyerror(char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main() {
    yyin = fopen("input.txt", "r");
    if (!yyin) {
        printf("Failed to open input file.\n");
        return 1;
    }
    
    yyout = fopen("output.txt", "w");
    if (!yyout) {
        printf("Failed to open output file.\n");
        fclose(yyin);
        return 1;
    }
    
    yyparse();
    
    fclose(yyin);
    fclose(yyout);
    printf("Parsing complete. 3-address code generated in output.txt\n");
    return 0;
}