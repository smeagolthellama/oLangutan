%{
#include <stdio.h>
#include <cstring>
#include <iostream>
#include <map>
#include <stack>
#include <string>
#include "subject.hpp"

using namespace std;

int yylex();
extern int yylineno;
int yyerror(const char* c);

extern enum vartypes {INT,REAL,RAW} yyvartype;
string program;
string variables_declared;

unsigned int next_symbol=1;
map<string,unsigned int> symbol_table; //when unallocated int is 0. Otherwise, it is a number referrring to a patch of memory.
stack<subject> subjects;

%}

%define parse.error verbose

%union{
	double	dval;
	long	ival;
	char	*name;
	subject	subjct;
}

%token STATEMENT_END
%token <name> VARNAME
%token <ival> NUMBER
%token <dval> DOUBLE
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

%type<name>	def asgn
%type<subjct>	subj stmt lines line vrbs vrb

%%

lines: line {$$=$1;}
     | lines line {$$=$2;}
     ;

def: PBREFERNCE VARNAME	
   	{
		subject subj=subjects.top();
		switch(subj.type){
			case subject::T_VAR:
				if(!subj.writeable){
					yyerror("\033[31msemantical error\033[39m: subject is not writeable.");
				}
				else if(symbol_table.find($2)==symbol_table.end()){
					char error[256];
					snprintf(error,256,"\033[31msemantical error\033[39m: variable '%s' is not defined.",$2);
					yyerror(error);
				} else{
					symbol_table[subj.vname]=symbol_table[$2];
					$$=subj.vname;
				}
				break;

			case subject::T_INT:
				yyerror("\033[31msemantical error\033[39m: cannot assign to NUMBER.");
				break;

			case subject::T_REAL:
				yyerror("\033[31msemantical error\033[39m: cannot assign to REAL.");
				break;

		}
	}

   | PBREFERNCE NEWREF
   	{
		subject subj=subjects.top();
		if(!subj.writeable){
			yyerror("\033[31msemantical error\033[39m: subject is not writeable.");
		}else{
			char str[64];
			snprintf(str,64,"var[%d]=0;index[\"%s\"]=%d;\n",next_symbol,subj.vname,next_symbol);
			variables_declared+=str;
			symbol_table[subj.vname]=next_symbol++;

			$$=subj.vname;

		}
	}
   ;

asgn: PBVALUE mtprt
    	{
		subject subj=subjects.top();
		if(!subj.writeable){
			yyerror("\033[31msemantical error\033[39m: subject is not writeable.");
		}else{
			program+="cin>>var[index[\"";
			program+=subj.vname;
			program+="\"]]";
			switch(yyvartype){
				case(INT):
				program+=".integer;";break;
				case(REAL):
				program+=".real;";break;
				case(RAW):
				program+=".raw;";break;
				
			}
			program+="\n";
		}
	}
    | PBVALUE stmt
    	{
		subject subj=subjects.top();
		subject value=$2;
		if(!subj.writeable){
			yyerror("\033[31msemantical error\033[39m: subject is not writeable.");
		}else{
			program+=subj.vname;
			switch(yyvartype){
				case(INT):
				program+=".integer";break;
				case(REAL):
				program+=".real";break;
				case(RAW):
				program+=".raw";break;
				
			}
			program+="=";
			if(!value.readable){
				program+="0;";
				yyerror("\033[31msemantical warning\033[39m: assignment of non-readable value. assuming 0.");
			}else{
				switch(value.type){
					char str[64];
					case(subject::T_INT):
						snprintf(str,64,"%lld;",value.lval);
						program+=str;break;
					case(subject::T_REAL):
						snprintf(str,64,"%lf;",value.dval);
						program+=str;break;
				
				}
			}
		}
	}
    ;

line: stmt STATEMENT_END
    | error
    ;

stmt: subj vrbs 
     {
     		$$=$2;
		subjects.pop();
		yyerror("\033[33mNOTICE\033[39m: previous subject popped.");
     }
    | subj 
     {
     		$$=$1;
		subjects.pop();
		yyerror("\033[33mNOTICE\033[39m: previous subject popped.");
     }
    | BLK lines EOBLK {$$=$2;}
    | cond
    | loop
    | prt
    | ELSE stmt
    ;

subj: VARNAME	{subjects.push($$=get_subject_from_symbol($1));}
    | NUMBER	{subjects.push($$=get_subject_from_num($1));}
    | DOUBLE	{subjects.push($$=get_subject_from_real($1));}
    ;

vrbs: vrb
    | '(' verbset ')'
    ;

verbset: vrb
       | verbset SUBSTMT vrb
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
    | PRT EOPRT
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
	program=
#include "olang_header.hpp"
+variables_declared+program+"\
	return 0;\
}\n";
	cout<<program;
}
int yyerror(const char* c){
	fprintf(stderr,"on line %d: %s\n",yylineno ,c);
	return 0;
}

