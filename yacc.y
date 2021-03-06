%{
void yyerror (char *s);
#include <stdio.h>     
#include <stdlib.h>
#include <string.h>


struct var
{
	char type;
	char name[16];
};


struct func
{
	char *name;
	char *args[10];
	char args_count;
};
char var_count = 0;
char last_type = 0;
struct var variables[128];
struct func functions[128];

void handle_syntax_error();
void declare_variable(char *id);
int **functionTable;
int cscope = 0;
int declared[26];
int scope[26]; 
int brace = 0;
char *lastID;
int functionCounter =0;
%}

%union {
	int num;
	char *id;
	char *str;
	double doub;
}

%start Program
%token program INTEGER DOUBLE CHARACTER BOOLEAN CONSTANT STRING REALNUM
%token FOR THEN DOWN TO DO WHILE SWITCH CASE OF
%token IF ELSE TRUE FALSE
%token BREAK REPEAT UNTIL CONTINUE RETURN
%token READ WRITE PRINT
%token IN END
%token EQUAL NEQUAL AND OR CHAR LESS GREATER LESSOREQ GREATEROREQ DIVIDE SUB ADD MOD MUL DOT

%token <id> ID
%token <num> IntNumber
%left ADD SUB
%left MUL devide

%%

Program:
	program ID ';' DecList '{' open_b SList  '}' close_b '.' {printf("program ID > program \n"); final_END();}
	| { handle_syntax_error(400); }
	;

DecList:
	Dec  DecList {printf("Dec And DecList > DecList \n");}
	|            {printf("No > DecList \n");}
	;

Dec:
	VarDecs ';'      {printf("VarDecs > Dec \n");}
    | FuncDecs         {printf("FuncDecs > Dec \n");}
    ;

FuncDecs:
	FuncDec FuncDecs {printf("FuncDec And FuncDecs > FuncDecs \n");}
	|                  {printf("No > FuncDecs \n");}
	;

VarDecs:
	VarDec           {printf("VarDec > VarDecs \n");}
	| VarDec VarDecs   {printf("VarDec VarDecs > VarDecs \n");}
	;

VarDec:
	Type IDDList      {printf("Type IDDList > VarDec \n");}/////////////check varible begin from here
	;

Type:
	INTEGER  		{ last_type = 1; }
	| DOUBLE   		{ last_type = 2; }
	| BOOLEAN  		{ last_type = 3; }
	| CHARACTER  	{ last_type = 4; }
	| CONSTANT		{ last_type = 5; }//constant_check();
	;

IDDim:
	ID                     									{declare_variable($1); printf("ID  > IDDim \n");lastID=$1;}
	| IDDim '['IntNumber']'									{printf("IDDim '['IntNumber']'  > IDDim \n");}
	;

IDDList:
	IDDim              										{printf("IDDim  > IDDList \n");}
	| IDDim ',' IDDList										{printf("IDDim  IDDList   > IDDList \n");}
	;

IDList:
	ID                        {printf("ID  > IDList \n");lastID=$1;}    
	| ID ',' IDList           {printf("ID  IDList  > IDList \n");}
	;

FuncDec:
        Type ID '(' ArgsList ')' {check_function($2);} '{' open_b SList '}' close_b ';' {printf("Type ID '(' ArgsList ')' '{' SList '}' ';' > FuncDec \n");}
	//Type ID '(' ArgsList ')' '{' open_b SList '}'  ';' {printf("reduced FROM Type ID '(' ArgsList ')' '{' SList '}' ';' TO FuncDec \n");}
	;
open_b:
               {printf("-- open brace\n");open_brace();}
        ;
close_b:
               {printf("-- close brace\n");close_brace();}
        ;
ArgsList:
	ArgList													{printf("ArgList > ArgsList \n");}
	|      													{printf(" > ArgsList \n");}
	;

ArgList:
	Arg              										{printf("ArgList > Arg \n");}
	| Arg ';' ArgList										{printf("Arg ';' ArgList > Arg \n");}
	;

Arg:
	Type IDList           									{printf("Type IDList > Arg  \n");}
    ;

SList:
	Stmt ';' SList       									{printf("Stmt ';' SList > SList  \n");}
	|                     									{printf(" > SList  \n");}
	;

Stmt:
	Exp                              						{printf("Exp > Stmt  \n");}
	| VarDecs                          						{printf("VarDecs > Stmt  \n");}
	| FOR lvalue '=' Exp valfor Exp DO Block				{printf("FOR lvalue '=' Exp '('valfor')' Exp DO Block > Stmt  \n");}
	| WHILE Exp DO Block           							{printf("WHILE Exp DO Block > Stmt  \n");}  
	| IF Exp THEN Block            							{printf("IF Exp THEN Block > Stmt  \n");}
	| IF Exp THEN Block ELSE Block 							{printf("IF Exp THEN Block ELSE Block > Stmt  \n");} 
	| SWITCH Exp OF '{'open_b Cases '}'close_b  			{printf("SWITCH Exp OF '{' Cases '}' > Stmt  \n");}
	| BREAK                          						{printf("BREAK > Stmt  \n");}
	| REPEAT Block UNTIL Exp       							{printf("REPEAT Block UNTIL Exp > Stmt  \n");}
	| CONTINUE                       						{printf("CONTINUE > Stmt  \n");}
	| RETURN Exp                     						{printf("RETURN Exp > Stmt  \n");} 
	| PRINT Exp                      						{printf("PRINT Exp > Stmt  \n");}
	| WRITE ExpPlus                  						{printf("WRITE ExpPlus > Stmt  \n");} 
	| READ '(' lvalue ')'            						{printf("READ '(' lvalue ')' > Stmt  \n");}
	|                                  						{printf(" > Stmt  \n");}
	;

valfor:
	TO                                      				{printf("TO  > valfor  \n");}
	|DOWN TO                               					{printf("DOWN TO  > valfor  \n");}
	;

Range:
	Exp DOT Exp                               
	;                           

Cases:
	Case                                       {printf("Case > Cases  \n");}
	| Case Cases                                {printf("Case Cases > Cases  \n");}
	;

Case:
	CASE Exp ':' Block                      {printf("CASE Exp ':' Block > Case \n");}
	| CASE Range ':' Block                    {printf("CASE Range ':' Block > Case \n");}
	;
  
Logic:
	  AND         				{printf("AND > Logic \n");}
	| OR        				{printf("OR > Logic \n");}
	| ""        				{printf("> Logic \n");}
	| '='       				{printf("'=' > Logic \n");}
	| EQUAL     				{printf("EQUAL > Logic \n");}   
	| NEQUAL    				{printf("NEQUAL > Logic \n");}
	| LESS       				{printf("LESS > Logic \n");}
	| GREATER    				{printf("GREATER > Logic \n");}
	| LESSOREQ   				{printf("LESSOREQ > Logic \n");}
	| GREATEROREQ				{printf("GREATEROREQ > Logic \n");}
	;

Aop:
	  ADD   					{printf("ADD > Aop \n");}
    | SUB   					{printf("SUB > Aop \n");}
    | MUL   					{printf("MUL > Aop \n");}
    | MOD   					{printf("MOD > Aop \n");}
    | DIVIDE					{printf("DIVIDE > Aop \n");}
    ;
 
ExpList:
	ExpPlus						{printf("ExpPlus > ExpList \n");}
	|      						{printf(" > ExpList \n");}
	;

ExpPlus:
	Exp                           {printf("Exp > ExpPlus \n");}
	| Exp ',' ExpPlus             {printf("Exp ',' ExpPlus > ExpPlus \n");}
	;

IDD:
	ID               				{printf("Exp > IDD \n");} 
    | IDD '[' Exp ']'				{printf("IDD '[' Exp ']' > IDD \n");} 
    ;

lvalue:
	ID   							{printf("ID > lvalue \n");} 
	| IDD							{printf("IDD > lvalue \n");} 
	;

Exp:
	ID								{ printf("/*/-*//-*/*"); }
    | lvalue         				{ printf("lvalue > Exp \n");}
    | REALNUM
    | CHAR           				{ printf("CHAR > Exp \n");}
    | TRUE           				{ printf("TRUE > Exp \n");}
    | FALSE          				{ printf("FALSE > Exp \n");}
    | Exp Aop Exp    				{ printf("Exp Aop Exp > Exp \n");}
    | Exp Logic Exp  				{ printf("Exp Logic Exp > Exp \n");}
    | '-' Exp        				{ printf("'-' Exp  > Exp \n");}
    | STRING         				{ printf("STRING > Exp \n");}
    | '('Exp')'      				{ printf("'('Exp')' > Exp \n");}
    | Exp IN Range   				{ printf("Exp IN Range > Exp \n");}
    | lvalue '=' Exp 				{ printf("lvalue '=' Exp > Exp \n"); /*check_value_defined($1);*/ }
    | ID'('ExpList')'				{ printf("ID'('ExpList')'  > Exp \n");}
	| IntNumber						{ printf("IntNumber > Exp \n");}
    ; 

Block:
	'{' open_b SList '}' close_b	{ printf("'{' SList '} > Block \n");}
	| Stmt                      	{ printf("Stmt > Block \n");}
	; 

%%


int main (void)
{
	make_function_table();
	return yyparse();
}

void yyerror (char *s)
{
	fprintf (stderr, "%s\n", s);
}

void declare_variable(char *id) {
	char find = 0;
	// printf("line number : %d", lineNumber);
	char i;
	for(i = 0; i < var_count; i++) {
		if (strcmp(id, variables[i].name) == 0)
			find = 1;
		if(variables[i].type==5)
			printf(" -- Syntax Error : #%s# is constant varible.can't change it\n", id);
	}

	
	if(find == 0) {
		variables[var_count].type = last_type;
		strcpy(variables[var_count++].name, id);
		printf(" -- create new var #%s# with type %c\n", id, last_type + 48);
	}
	else
			printf(" -- Syntax Error : #%s# is an already declared variable\n", id);
		
	
	
}

void constant_check(){
	for(char i = 0; i < var_count; i++)
		if(strcmp(lastID, variables[i].name) == 0 && variables[i].type==5 )
			printf("-- Syntax Error : #%s# is constant varible.can't change it\n", lastID);
		
}
void open_brace(){
        brace++;
}

void close_brace()
{
        brace--;
}

void final_END()
{
	if( brace != 0 ) {
		printf("Error:Wrong braces");
	}
}

/*
*	Error Handle Code:
*	400: Program Define Error
*
*/

void handle_syntax_error(int code) {
	
	switch (code)
	{
		case 400:
			printf("-- Syntax Error: is not define\n");
			break;
	
		default:
			break;
	}
	
}

void check_function(char *id){
		printf("--Debugging:check_function called \n");
	 
	int find =0;
	
		for(char  i = 0; i < functionCounter; i++){
		if (strcmp(id, functionTable[i][0]) == 0)
			find = 1;

	}

	
	if (find == 0) {
		functionTable[functionCounter][0]=id;
		functionCounter++;
	}
	else
			printf(" -- Syntax Error : #%s# is an already declared function\n", id);
	
}
void make_function_table(){
	printf("--Debugging:make_function_table called \n");
	    int r = 100, c = 100, i, j, count;
 
    functionTable = (int **)malloc(r * sizeof(int *));
    for (i=0; i<r; i++)
         functionTable[i] = (int *)malloc(c * sizeof(int));

 
}