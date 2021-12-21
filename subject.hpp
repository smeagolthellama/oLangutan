#ifndef SUBJECT_HPP_INCLUDED
#define SUBJECT_HPP_INCLUDED
#include <string>
#include <map>
using namespace std;

extern map<string,unsigned int> symbol_table;
enum vartypes {INT,REAL,RAW};
extern vartypes yyvartype;

int yyerror(const char* c);

struct subject{
	bool writeable;// if true, is var; else is number or real.
	bool readable;
	enum {T_INT,T_REAL,T_VAR} type;
	union{
		long long lval;
		double dval;
		char* vname;
	};
	enum vartypes vartype;
};
subject get_subject_from_num(long long l);
subject get_subject_from_real(double d);
subject get_subject_from_symbol(string name);
#endif
