%{
#include <stdio.h>

int oszlop=0;
int elozosor=0;

void token(char* name){
	if(elozosor!=yylineno){
		oszlop=0;
		elozosor=yylineno;
	}
	printf("[sor: %d oszlop: %d hosz: %d] %s (%s)\n",
	yylineno, oszlop, yyleng, name ,yytext);
	oszlop+=yyleng;
}

%}

%x VAR
%x COMMENT
%option noyywrap yylineno

%%

[ \t\n\r] {}

\. {
	token("end of statement");
}

\{[^} \t\n\r]*?\} {
	token("int");
}

\[[^] \t\n\r]*?\] {
	token("real");
}
_[^_ \t\n\r]*?_ {
	token("raw data (effectively char)");
}

[0-9]* {
	token("szam");
}

"becomen"|"<-" {
	token("ertekadas");
}

"esten"|"<=" {
	token("referencia");
}

"se"|"¿" {
	token("conditional start");
}

ke|"¿?" {
	token("while loop start");
}

e {
	token("begin code block");
}

par {
	token("end code block");
}

"senek"|"¡" {
	token("else");
}

"ses"|"|" {
	token("or");
}

"kaj"|"&" {
	token("and");
}

"isto"|"=" {
	token("equality");
}

"majo"|">" {
	token("nagyobb");
}

"es"|"?" {
	token("query end");
}

"irven("[^)]*")" {
	token("comment");
}

nove {
	token("new reference");
}

"token" {
	token("print");
}
"-{ " {
	token("print small");
}

"}" {
	token("end of print");
}

; {
	token("end sub-statement");
}

"kajen"|\+ {
	token("addition");
}

"neken"|- {
	token("subtraction");
}

. {
	token("\033[31mLEXING ERROR\033[39m");
}

%%

int main(int argc,char** argv){
	yylex();
}

