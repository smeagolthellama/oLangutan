#include "subject.hpp"
#include <cstring>

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
	retval.vartype=yyvartype;
	if(symbol_table.find(name)==symbol_table.end()){
		symbol_table[name]=0;
		retval.readable=false;
	}else{
		retval.readable=true;
	}
	return retval;
}

;



