%{
#include <stdio.h>
#include <cstring>
#include <iostream>
#include <map>
#include <string>

using namespace std;

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

%start program

%%


program: lines {/*TODO: output program.*/};

lines: 
     %empty
     | lines line{/*TODO: concatanate.*/};

line: stmt STATEMENT_END{/*TODO: concatanate.*/}
    | error
    ;

stmt: chStmt
    | nchStmt
    ;

chStmt: lvalue chOps {/*subject=$1;$2;*/};

nchStmt: lvalue nchOps
       | rvalue nchOps
       ;

lvalue: var ;

rvalue: var
      | num
      | expression
      ;

expression: rvalue expOp rvalue {$$=$1+$2+$3;}
	  | '(' rvalue ')' {$$=$1+$2+$3;}
	  ;

var: realVar
   | intVar
   | rawVar
   ;

realVar: '[' VARNAME ']' {$$=$2+".real";};

intVar: '{' VARNAME '}' {$$=$2+".integer";};

rawVar: '_' VARNAME '_' {$$=$2+".raw";};

num: NUMBER
   | DOUBLE
   ;


expOp: add 
     | sub 
     | mul
     | div
     ;

add: ADD {$$='+';};

sub: SUB {$$="-";};

mul: MUL {$$="*";};

div: DIV {$$="/";};

%%
