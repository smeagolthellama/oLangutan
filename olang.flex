%{
#define VARTYPES
#include <stdio.h>
#include "olang.tab.h"

//vartypes yyvartype;

int oszlop=0;
int elozosor=0;
void token(const char* name){
	if(elozosor!=yylineno){
		oszlop=0;
		elozosor=yylineno;
	}/*
	printf("[sor: %d oszlop: %d hosz: %d] %s (%s)\n",
	yylineno, oszlop, yyleng, name ,yytext);*/
	oszlop+=yyleng;
}

%}

%x VAR
%option noyywrap yylineno

%%

[ \t\n\r] {}

[\[{_] {
	BEGIN(VAR);
//	yyerror("starting variable.");
	return yytext[0];
}

<VAR>[a-zA-Z1-9]+ {
	token("variable");
//	yyerror("variable:");
//	yyerror(yytext);
	yylval=yytext;
	return VARNAME;
}

<VAR>[\]}_] {
	BEGIN(0);
//	yyerror("ending variable.");
	return yytext[0];
}

\. {
	token("end of statement");
	return STATEMENT_END;
}


"becomen"|"<-" {
	token("ertekadas");
	return PBVALUE;
}

"esten"|"<=" {
	token("referencia");
	return PBREFERNCE;
}

"se"|"¿" {
	token("conditional start");
	return IFSTART;
}

ke|"¿?" {
	token("while loop start");
	return WHILESTART;
}

e {
	token("begin code block");
	return BLK;
}

par {
	token("end code block");
	return EOBLK;
}

"senek"|"¡" {
	token("else");
	return ELSE;
}

"ses"|"|" {
	token("or");
	return OR;
}

"kaj"|"&" {
	token("and");
	return AND;
}

"isto"|"=" {
	token("equality");
	return EQU;
}

"majo"|">" {
	token("nagyobb");
	return GRT;
}

nea+|¬ {
	token("negation");
	return NOT;
}


‽.* {
	token("comment");
} 

"es"|"?" {
	token("query end");
	return EOQRY;
}

"irven("[^)]*")" {
	token("comment");
}

nove|£ {
	token("new reference");
	return NEWREF;
}

"token" {
	token("print");
	return PRINT;
}
"-{ " {
	token("print small");
	return PRT;
}

"}" {
	token("end of print");
	return EOPRT;
}

; {
	token("end sub-statement");
	return SUBSTMT;
}

"kajen"|\+ {
	token("addition");
	return ADD;
}

"neken"|- {
	token("subtraction");
	return SUB;
}

"frulen"|\* {
	token("multiplication");
	return MUL;
}

"pakalen"|\/ {
	token("division");
	return DIV;
}

-?[0-9]* {
	token("szam");
	yylval=yytext;
	return NUMBER;
}

-?[0-9]*\.[0-9]* {
	token("valos");
	yylval=yytext;
	return DOUBLE;
}
[()] { 
	return yytext[0];
}

. {
	fprintf(stderr,"[sor: %d oszlop: %d hosz: %d] %s (%s)\n",
	yylineno, oszlop, yyleng, "\033[31mLEXING ERROR\033[39m" ,yytext);
	yyerror("\033[31mLEXING ERROR\033[39m");
}

%%


