%{
#include <stdio.h>
#include <cstring>
#include <iostream>
#include <map>
#include <stack>
#include <string>

using namespace std;

int yylex();
extern int yylineno;
int yyerror(const char* c);

extern enum {INT,REAL,RAW} yyvartype;

struct subject{
	bool writeable;// if true, is var; else is number or real.
	bool readable;
	enum {T_INT,T_REAL,T_VAR} type;
	union{
		long long lval;
		double dval;
		char* vname;
	};
};

typedef union {
	long long	integer;
	double	real;
	char	raw[8];
}var_memory;

unsigned int next_symbol=1;
map<string,unsigned int> symbol_table; //when unallocated int is 0. Otherwise, it is a number referrring to a patch of memory.

subject get_subject_from_num(long long l){
	yyerror("\033[33mNOTICE\033[39m: subject NUMBER got.");
	subject retval;
	retval.writeable=false;
	retval.readable=true;
	retval.type=subject::T_INT;
	retval.lval=l;
	return retval;
}

subject get_subject_from_real(double d){
	yyerror("\033[33mNOTICE\033[39m: subject REAL got.");
	subject retval;
	retval.writeable=false;
	retval.readable=true;
	retval.type=subject::T_REAL;
	retval.dval=d;
	return retval;
}


subject get_subject_from_symbol(string name){
	yyerror("\033[33mNOTICE\033[39m: subject VARNAME got.");
	subject retval;
	retval.writeable=true;
	retval.vname=strdup(name.c_str());
	retval.type=subject::T_VAR;
	if(symbol_table.find(name)==symbol_table.end()){
		symbol_table[name]=0;
		retval.readable=false;
	}else{
		retval.readable=true;
	}
	return retval;
}

stack<subject> subjects;

%}

%define parse.error verbose

%union{
	double	dval;
	long	ival;
	char	*name;
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

%type<name> def asgn

%%

lines: line
     | lines line
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
		}
	}
    | PBVALUE stmt
    	{
		subject subj=subjects.top();
		if(!subj.writeable){
			yyerror("\033[31msemantical error\033[39m: subject is not writeable.");
		}else{
		}
	}
    ;

line: stmt STATEMENT_END
    | error
    ;

stmt:stmt_
     {
		subjects.pop();
		yyerror("\033[33mNOTICE\033[39m: previous subject popped.");
     }
     ;

stmt_: subj vrbs 
    | subj 
    | BLK lines EOBLK 
    | cond
    | loop
    | prt
    | ELSE stmt
    ;

subj: VARNAME	{subjects.push(get_subject_from_symbol($1));}
    | NUMBER	{subjects.push(get_subject_from_num($1));}
    | DOUBLE	{subjects.push(get_subject_from_real($1));}
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
	fprintf(stderr,"on line %d: %s\n",yylineno ,c);
	return 0;
}

