  %{
	#include <iostream>
	#include <stdlib.h>
	#include <stdio.h>
	#include <cstring>
	#include "structs.h"

	using namespace std; 

	#define MAX_SIZE 20


	int yylex();
	int yyerror (char const *s);
	void init(char* file);


    double sym[MAX_SIZE];
    char type[MAX_SIZE];
    bool declared[MAX_SIZE];

%}

%union {
	double value;
	char type;	
	Exp_type exptype;
	CString stringData;
};

%token <value> ID NUM DONUM CHNUM
%token <stringData> HEADER STRING
%token IFC ELIFC ELC ELIFCLOSE WHEN WHENCLOSE INT PRINT FOR FORCLOSE LE GE EQ NQ TO DOUBLE CHAR VOID INCLUDE MAIN MAINCLOSE BOOL INPUT

%right '='
%left '<' '>' LE GE EQ
%left '+' '-'
%left '*' '/'


%type <type> type
%type <value> loop_condition
%type <exptype> expr

%start start

%%

start: header_root main
	;

header_root: header 
	| header '\n' header_root
	;

header: '#' INCLUDE '"' HEADER '"'
	| /* empty */
	;

main: MAIN '\n' body '\n' MAINCLOSE '\n'
	;

body: stmnt '\n' body
	| stmnt '\n'
	;

stmnt: declared
	| condition
	| loop
	| assign
	| printf
	| input
	|     /*empty line*/
	;

condition:
	IFC '(' expr ')' '\n' body ELIFCLOSE	{
		if($3.value){
			printf("If is executed.\n");
		}
		else {
			printf("Wrong condition of If.\n");
		}
	}
	| IFC '(' expr ')' '\n' body ELC '\n' body ELIFCLOSE {
		if($3.value){
			printf("If is executed.\n");
		}
		else {
			printf("Else is executed.\n");
			 }
	}
	| IFC '(' expr ')' '\n' body ELIFC '(' expr ')' '\n' body '\n' ELC '\n' body ELIFCLOSE {
		if($3.value){
			printf("If is executed.\n");
		}
		else if($9.value){printf("Else If is executed.\n");}
		else {
			printf("Else is executed.\n");
			 }
	}
	;

loop:
	WHEN '(' loop_condition ')' '\n' body WHENCLOSE {
		printf("While loop is executed.\n");
	}
	| FOR '(' loop_condition ')' '\n' body FORCLOSE {
		printf("For loop is executed.\n");
	}
	;

loop_condition:
	NUM TO NUM 	{$$ = $3 - $1;}
	;

declared:	type ID	'|' {
						if(declared[(int)$2])
						{
							yyerror("Error : Cannot redeclare variable!\n");
						}
						else
						{
							sym[(int)$2]=0;
							type[(int)$2]=$1;
							declared[(int)$2]=true; 
						}
					}
		;

assign:
	ID '=' expr '|'		{
						if(!declared[(int)$1])
						{
							yyerror("Error : undeclared variable is used!!\n");
						} 
						else if(type[(int)$1] != $3.type)
						{
							yyerror("Error : type does not match!!\n");
						}
						else
						{
							sym[(int)$1]=$3.value;
						}	
					}
	;



printf:
	PRINT '{' expr '}' '|'	{
								printf("%f\n", $3.value);
							}
	| PRINT '{' STRING '}' '|'  {
								printf("%s\n",$3 );
							}
	| PRINT '{' STRING ':' expr '}' '|' {
											printf("%s : %f\n",$3,$5.value );
										}
	;

input: INPUT '{' ID '}' '|'	{
						if(!declared[(int)$3])
						{
							yyerror("Error : undeclared variable used!");
						}
						else {
							printf("input is called.\n" );
							cin>>sym[(int)$3];
							getchar();
						}
					}
	;

expr:
	NUM 				{$$.value = $1;$$.type = 'i'}
	| DONUM 			{$$.value = $1;$$.type = 'd'}
	| CHNUM 			{$$.value = $1;$$.type = 'c'}
	| ID 				{$$.value = sym[(int)$1];$$.type = type[(int)$1];}
	| expr '+' expr 	{$$.value = $1.value + $3.value;if($1.type == $3.type){$$.type = $1.type;}else{$$.type = 'd';}}
	| expr '-' expr 	{$$.value = $1.value - $3.value;if($1.type == $3.type){$$.type = $1.type;}else{$$.type = 'd';}}
	| expr '*' expr 	{$$.value = $1.value * $3.value;if($1.type == $3.type){$$.type = $1.type;}else{$$.type = 'd';}}
	| expr '/' expr 	{
							if($3.value > 0){
								$$.value = $1.value / $3.value;
							}
							else {
								printf("Devision is not possible!!");
							}
						}
	| expr '<' expr 	{$$.value = $1.value < $3.value;}
	| expr '>' expr 	{$$.value = $1.value > $3.value;}
	| expr GE expr 	{$$.value = $1.value <= $3.value;}
	| expr LE expr 	{$$.value = $1.value >= $3.value;}
	| expr EQ expr 	{$$.value = $1.value == $3.value;}

	| '(' expr ')'	{ $$.value = $2.value; }
	;

type:
	INT 		{$$ = 'i';}
	| DOUBLE 	{$$ = 'd';}
	| CHAR 		{$$ = 'c';}
	| BOOL 		{$$ = 'b';}
	;

%%


int yyerror(char const *s)
{
	printf("%s\n",s);
	return (0);
}

int main()
{

	freopen("input.txt","r",stdin);
	freopen("output.txt","w",stdout);

	for(int i = 0; i < MAX_SIZE; i++){
		declared[i] = false;
	}

	yyparse();
	exit (0);
}