%{
#include <stdio.h>
#include <cstring>
#include <iostream>
#include <map>
#include <string>
#include <stack>
#include <deque>

using namespace std;

extern int yylineno;
int yyerror(const char* c);
int yylex();

unsigned int next_symbol=1;
map<string,unsigned int> symbol_table;

unsigned int nove_value;

unsigned int line_counter=0;
#define TMPSTR_SIZE 1024
char tmpstr[TMPSTR_SIZE];

template<
    class T,
    class Container = std::deque<T>
>
class my_stack : public stack<T,Container>{
public:
	void pop(){
//		yyerror("popping from stack.");
		stack<T,Container>::pop();
//		cerr<<"stack depth is "<<stack<T,Container>::size()<<"\n";
	}

	void push(const T& value){
//		yyerror("pushing onto stack.");
		stack<T,Container>::push(value);
//		cerr<<"stack depth is "<<stack<T,Container>::size()<<"\n";
	}
};

my_stack<string> subjects_stack;
my_stack<long int> var_stack;
%}

%code requires{
#include <string>
using namespace std;
inline int yyerror(const char* c){
	fprintf(stderr,"On line %d: %s\n",yylineno ,c);
	return 0;
}
#define NON_VARIABLE 0
#define TESTVAR if(var_stack.top()<0){yyerror("Cannot use variable that has never been allocated!");YYERROR;}
#define ABS(a) (((a)>0)?(a):(-(a)))
}

%define api.value.type {string}
%define parse.error verbose

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

%left EQU GRT
%left AND OR 
%left ADD SUB
%left MUL DIV
%right PBVALUE PBREFERNCE
%left SUBSTMT

%start program

%expect 2

%%


program: lines {
       /*TODO: output program.*/
       cout<<"#include \"olang_header.hpp\"\n\n";
       cout<<$1;
       cout<<"}\n";
       };

lines: 
     %empty {$$="";}
     | lines line 
     {
     $$=$1+$2;};

line: stmt STATEMENT_END{
	$$=$1+";\n";
    }
    | error {$$="";}
    ;

stmt: chStmt
    | nchStmt
    | conditional
    | loop
    | block
    | printline
    ;

printline: PRT rvalue EOPRT {
	$$="assign(printObj , "+$2 +")";
	subjects_stack.pop();
	var_stack.pop();
}

chStmt: lvalue chOps {$$=$2;subjects_stack.pop();var_stack.pop();};

nchStmt: rvalue nchOps {$$=$2;subjects_stack.pop();var_stack.pop();}
       ;

lvalue: var {subjects_stack.push($1);$$="";}
      | printopts {subjects_stack.push("printObj");var_stack.push(NON_VARIABLE);$$="";}
      ;


rvalue: var {subjects_stack.push($1);TESTVAR;$$=$1;}
      | NOT var {subjects_stack.push($2);TESTVAR;$$="!("+$2+")";}
      | num {subjects_stack.push($1);var_stack.push(NON_VARIABLE);$$=$1;}
      | NOT num {subjects_stack.push($2);var_stack.push(NON_VARIABLE);$$="!("+$2+")";}
      | expression {subjects_stack.push($1);var_stack.push(NON_VARIABLE);$$=$1;}
      | printopts {subjects_stack.push("printObj");var_stack.push(NON_VARIABLE);$$="printObj";}
      ;

expression: rvalue ADD rvalue {$$=$1+"+"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | rvalue SUB rvalue {$$=$1+"-"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | rvalue MUL rvalue {$$=$1+"*"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();;}
	  | rvalue DIV rvalue {$$=$1+"/"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | '(' stmt ')' {$$="("+$2+")";}
	  | '(' rvalue ')' {$$="("+$2+")";subjects_stack.pop();var_stack.pop();}
	  | rvalue AND rvalue {$$=$1+"&&"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | rvalue OR rvalue {$$=$1+"||"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | rvalue EQU rvalue {$$=$1+"=="+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | rvalue GRT rvalue {$$=$1+">"+$3;subjects_stack.pop();var_stack.pop();subjects_stack.pop();var_stack.pop();}
	  | NOT '(' rvalue ')' {$$="!("+$3+")"; subjects_stack.pop();var_stack.pop();}
	  ;

var: realVar {$$=$1;}
   | intVar {$$=$1;}
   | rawVar {$$=$1;}
   ;

varname: VARNAME {
	if(symbol_table.find($1)==symbol_table.end()){
		symbol_table[ $1 ]=next_symbol++;
		var_stack.push(-((long int)symbol_table[$1]));
	}else{
		var_stack.push(symbol_table[$1]);
	}
	snprintf(tmpstr,TMPSTR_SIZE,"%d",symbol_table[$1]);
//	yyerror(string("notice: noticed variable:"+$1).c_str());

	$$="/*"+$1+"*/"+string("var.at(varindex.at(")+tmpstr+"))";

};

realVar: '[' varname ']' {$$=$2+".real";};

intVar: '{' varname '}' {$$=$2+".integer";};

rawVar: '_' varname '_' {$$=$2+".raw";};

num: NUMBER {$$=$1+"ll";}
   | DOUBLE
   ;

chOps: pbv
     | pbr
     | '(' groupedOps ')' {$$=$2;}
     | conditionalOps
     | loopOps
     ;

groupedOps: groupedOps SUBSTMT chOps {$$=$1+";"+$3;}
	  | groupedOps SUBSTMT nchOps {$$=$1+";"+$3;}
	  | chOps
	  | nchOps 
	  ;

pbv: PBVALUE rvalue 
   {
   	TESTVAR;
   	subjects_stack.pop();var_stack.pop();
	$$="assign("+subjects_stack.top()+" , "+$2+")";
   };

pbr: PBREFERNCE brackets VARNAME brackets {
	if(var_stack.top()==NON_VARIABLE){
		yyerror("can't pass by reference to non-variable.");
		YYERROR;		
	}
	if(symbol_table.find($3)==symbol_table.end()){
		yyerror("can't pass from nonexistent variable.");
		YYERROR;
	}
	long int varid=ABS(var_stack.top());
	var_stack.pop();
	var_stack.push(varid);
	snprintf(tmpstr,TMPSTR_SIZE,"varindex.at(%ld)=varindex.at(%d)",varid,symbol_table[$3]);
	$$=tmpstr;
}
   | passNew;

brackets: '[' | '{' | '_' | '}' | ']';

passNew: PBREFERNCE NEWREF 
       {
	long int varid=ABS(var_stack.top());
	var_stack.pop();
	var_stack.push(varid);
	snprintf(tmpstr,TMPSTR_SIZE,"%ld",varid);
	$$=string("varindex.at(")+tmpstr+")="; 
	snprintf(tmpstr,TMPSTR_SIZE,"%d",nove_value++);
	$$=$$+tmpstr+";var.push_back(null);";
	}
	;

nchOps: print
      ;

conditional: IFSTART expression EOQRY stmt {$$="if("+$2+"){\n"+$4+";\n}\n";}
           | IFSTART expression EOQRY stmt ELSE stmt {$$="if("+$2+"){\n"+$4+";\n}else{\n"+$6+";\n}";}
           | IFSTART expression EOQRY SUBSTMT ELSE stmt {$$="if(! ("+$2+")){\n"+$6+";\n}";}
	   ;

conditionalOps: IFSTART expression EOQRY chOps {$$="if("+$2+"){\n"+$4+";\n}\n";}
	      | IFSTART expression EOQRY chOps ELSE chOps {$$="if("+$2+"){\n"+$4+";\n}else{\n"+$6+";\n}";}
	      | IFSTART expression EOQRY SUBSTMT ELSE chOps {$$="if(! ("+$2+")){\n"+$6+";\n}";}
	      ;

loop: WHILESTART expression EOQRY stmt {$$="while("+$2+"){\n"+$4+";\n}\n";}
       ;

loopOps: WHILESTART expression EOQRY chOps {$$="while("+$2+"){\n"+$4+";\n}\n";}
       ;

block: BLK lines EOBLK {$$=""+$2+"";};

print: printopts {$$="assign(printObj , "+subjects_stack.top()+")";}
     ;
printopts: PRINT
	 | PRT EOPRT
	 ;

%%

int main(int argc,char** argv){
#ifdef YYDEBUG
	if(argc>1 && strcmp(argv[1],"-t")==0){
		yydebug=1;
	}
#endif
	yyparse();
}

