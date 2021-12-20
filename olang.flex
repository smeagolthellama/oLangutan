%{
#include <stdio.h>
#include "olang.tab.h"

enum vartypes{INT,REAL,RAW} yyvartype;

int oszlop=0;
int elozosor=0;
int yyerror(const char* c);
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

%x COMMENT
%option noyywrap yylineno

%%

[ \t\n\r] {}

\. {
	token("end of statement");
	return STATEMENT_END;
}

\{[^} \t\n\r]*?\} {
	token("int");
	yyvartype=INT;
	yylval.name=strdup(yytext+1);
	yylval.name[strlen(yylval.name)-1]=0;
	return VARNAME;
}

\[[^] \t\n\r]*?\] {
	token("real");
	yyvartype=REAL;
	yylval.name=strdup(yytext+1);
	yylval.name[strlen(yylval.name)-1]=0;
	return VARNAME;
}
_[^_ \t\n\r]*?_ {
	token("raw data (effectively char)");
	yyvartype=RAW;
	yylval.name=strdup(yytext+1);
	yylval.name[strlen(yylval.name)-1]=0;
	return VARNAME;
}

"becomen"|"<-" {
	token("ertekadas");
	return PBVALUE;
}

"isten"|"<=" {
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

"es"|"?" {
	token("query end");
	return EOQRY;
}

"irven("[^)]*")" {
	token("comment");
}

nove {
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


[+-]?[0-9]* {
	token("szam");
	yylval.ival=strtol(yytext,NULL,0);
	return NUMBER;
}

[+-]?[0-9]*\.[0-9]* {
	token("valos");
	yylval.dval=strtod(yytext,NULL);
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


