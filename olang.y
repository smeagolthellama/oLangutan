%{
#include <stdio.h>
#include <cstring>
#include <iostream>
#include <map>
#include <string>

using namespace std;

extern int yylineno;
int yyerror(const char* c);
int yylex();

unsigned int next_symbol=1;
map<string,unsigned int> symbol_table; //when unallocated int is 0. Otherwise, it is a number referrring to a patch of memory.

%}

%define api.value.type {string}

%token STATEMENT_END
%token VARNAME
%token NUMBER
%token DOUBLE
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
%token MUL
%token DIV

%left ADD SUB
%left MUL DIV

%start program

%%


program: lines {
       /*TODO: output program.*/
       cout<<"#include \"olang_header.hpp\"\n\n";
       cout<<$1;
       cout<<"}\n";
       };

lines: 
     %empty
     | lines line {$$=$1+$2;};

line: stmt STATEMENT_END{$$=$1+";";}
    | error
    ;

stmt: chStmt
    | nchStmt
    ;

chStmt: lvalue chOps {$$="subject=\""+$1+"\";"+$2;};

nchStmt: lvalue nchOps {$$="subject=\""+$1+"\";"+$2;}
       | rvalue nchOps  {$$="subject=\""+$1+"\";"+$2;}
       ;

lvalue: var ;

rvalue: var
      | num
      | expression
      ;

expression: rvalue ADD rvalue {$$=$1+"+"+$3;}
	  | rvalue SUB rvalue {$$=$1+"-"+$3;}
	  | rvalue MUL rvalue {$$=$1+"*"+$3;}
	  | rvalue DIV rvalue {$$=$1+"/"+$3;}
	  | '(' rvalue ')' {$$=$1+$2+$3;}
	  ;

var: realVar {$$=$1;}
   | intVar {$$=$1;}
   | rawVar {$$=$1;}
   ;

varname: VARNAME {$$="var[index[\""+$1+"\"]]";};

realVar: '[' varname ']' {$$=$2+".real";};

intVar: '{' varname '}' {$$=$2+".integer";};

rawVar: '_' varname '_' {$$=$2+".raw";};

num: NUMBER
   | DOUBLE
   ;

chOps: pbv
     | pbr
     ;

pbv: PBVALUE rvalue {$$="var[index[subject]]="+$2;};

pbr: passReal
   | passInt
   | passRaw
   ;

passReal: PBREFERNCE '[' VARNAME ']' {$$="index[subject]="+$3;};
passInt: PBREFERNCE '{' VARNAME '}' {$$="index[subject]="+$3;};
passRaw: PBREFERNCE '_' VARNAME '_' {$$="index[subject]="+$3;};

nchOps: print
      /* | conditional*/
      ;

print: printopts {}
     ;
printopts: PRINT
	 | PRT EOPRT
	 ;



%%

int main(int argc,char** argv){
	yyparse();
}

int yyerror(const char* c){
	fprintf(stderr,"on line %d: %s\n",yylineno ,c);
	return 0;
}
