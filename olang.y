%{
#include <stdio.h>

int yylex();
extern int yylineno;
int yyerror(const char* c);

extern enum {INT,REAL,RAW} yyvartype;
int yylval;
%}

%define parse.error verbose

%token STATEMENT_END
%token VARNAME
%token NUMBER
%token PBVALUE
%token PBREFERNCE
%token IFSTART
%token WHILESTART
%token EOQRY
%token BLK
%token EOBLK
%token ELSE
%token OR
%token AND
%token NOT
%token EQU
%token GRT
%token NEWREF
%token PRINT
%token PRT
%token EOPRT
%token SUBSTMT
%token ADD
%token SUB

%start lines

%right SUBSTMT

%%

lines: line
     | lines line
     ;

def: PBREFERNCE VARNAME
   | PBREFERNCE NEWREF
   ;

asgn: PBVALUE mtprt
    | PBVALUE stmt
    ;

line: stmt STATEMENT_END
    | error
    ;

stmt: subj vrbs 
    | subj 
    | BLK lines EOBLK 
    | cond
    | loop
    | prt
    | ELSE stmt
    ;

subj: VARNAME
    | NUMBER
    ;

vrbs: vrb
    | '(' vrb SUBSTMT vrbs ')'
    ;

vrb: def
   | asgn
   | proc
   | op
   ;

op: ADD stmt
  | SUB stmt
  | AND stmt
  | OR stmt
  | EQU stmt
  | GRT stmt
  | NOT stmt
  ;

proc: PRINT
    ;

prt: PRT stmt EOPRT
   ;


mtprt: PRINT
     | PRT EOPRT
     ;

cond: IFSTART stmt EOQRY stmt;

loop: WHILESTART stmt EOQRY stmt;

%%
int main(int argc,char** argv){
	yyparse();
}
int yyerror(const char* c){
	printf("error on line %d: %s\n",yylineno ,c);
	return 0;
}

