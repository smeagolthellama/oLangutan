%{
#include <stdio.h>
#include <cstring>
#include <iostream>
#include <map>
#include <string>
#include <stack>

using namespace std;

extern int yylineno;
int yyerror(const char* c);
int yylex();

unsigned int next_symbol=1;
map<string,unsigned int> symbol_table; //when unallocated int is 0. Otherwise, it is a number referrring to a patch of memory.

unsigned int nove_value;

unsigned int line_counter=0;
#define TMPSTR_SIZE 1024
char tmpstr[TMPSTR_SIZE];

stack<string> subjects_stack;
stack<unsigned int> var_stack;
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
%right PBVALUE PBREFERNCE

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
     | lines line 
     {
     $$=$1+$2;};

line: stmt STATEMENT_END{
     snprintf(tmpstr,TMPSTR_SIZE,"\n%d (%d):",line_counter++,yylineno);
    $$=/*tmpstr+*/$1+";\n";}
    | error {$$="";}
    ;

stmt: chStmt
    | nchStmt
    ;

chStmt: lvalue chOps {$$=$2;subjects_stack.pop();var_stack.pop();};

nchStmt: rvalue nchOps {$$=$2;subjects_stack.pop();var_stack.pop();}
       ;

lvalue: var {subjects_stack.push($1);$$="";}
      | print {subjects_stack.push("printObj");var_stack.push(-1);$$="";}
      ;


rvalue: var {subjects_stack.push($1);var_stack.push(-1);$$=$1;}
      | num {subjects_stack.push($1);var_stack.push(-1);$$=$1;}
      | expression {subjects_stack.push($1);var_stack.push(-1);$$=$1;}
      | printopts {subjects_stack.push("printObj");var_stack.push(-1);$$="printObj";}
      ;

expression: rvalue ADD rvalue {$$=$1+"+"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | rvalue SUB rvalue {$$=$1+"-"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | rvalue MUL rvalue {$$=$1+"*"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();;}
	  | rvalue DIV rvalue {$$=$1+"/"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | '(' stmt ')' {$$=$1+$2+$3;}
	  | '(' expression ')' {$$=$1+$2+$3;subjects_stack.pop();var_stack.pop();}
	  ;

var: realVar {$$=$1;}
   | intVar {$$=$1;}
   | rawVar {$$=$1;}
   ;

varname: VARNAME {
	if(symbol_table.find($1)==symbol_table.end()){
		symbol_table[ $1 ]=next_symbol++;
	}
	var_stack.push(symbol_table[$1]);
	snprintf(tmpstr,TMPSTR_SIZE,"%d",symbol_table[$1]);
	$$=string("var[varindex[")+tmpstr+"]]";

};

realVar: '[' varname ']' {$$=$2+".real";};

intVar: '{' varname '}' {$$=$2+".integer";};

rawVar: '_' varname '_' {$$=$2+".raw";};

num: NUMBER {$$=$1+"ll";}
   | DOUBLE
   ;

chOps: pbv
     | pbr
     ;

pbv: PBVALUE rvalue {subjects_stack.pop();var_stack.pop();$$=subjects_stack.top()+"="+$2;;};

pbr: PBREFERNCE brackets VARNAME brackets {
	if(var_stack.top()==-1){
		yyerror("can't pass by reference to non-variable.");
		
	}else{
	if(symbol_table.find($3)==symbol_table.end()){
		yyerror("can't pass from nonexistent variable.");
	}else{
		snprintf(tmpstr,TMPSTR_SIZE,"varindex[%d]=%d",var_stack.top(),symbol_table[$3]);
	}
	}
}
   | passNew;

brackets: '[' | '{' | '_' | '}' | ']';

passNew: PBREFERNCE NEWREF 
       {
	snprintf(tmpstr,TMPSTR_SIZE,"%d",var_stack.top());
	$$=string("varindex[")+tmpstr+"]="; 
	snprintf(tmpstr,TMPSTR_SIZE,"%d",nove_value++);
	$$=$$+tmpstr+";var.push_back(null);";
	}

nchOps: print
      /* | conditional*/
      ;

print: printopts {$$="printObj="+subjects_stack.top();}
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
