%{
#include <stdio.h>

%}

%option noyywrap

%%

\{[^ \t\n\r\}]*\} {
	printf("[] var");
}

%%

int main(int argc,char** argv){
	yylex();
}

