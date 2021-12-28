#include <iostream>
#include <vector>
#include <map>
#include <string>
#include <cstring>

using namespace std;

typedef union {
	long long	integer;
	double	real;
	char	raw[8];
}var_memory;

vector<var_memory> var;
map<long int,unsigned int> varindex;
var_memory null;

class myPrint{
} printObj;

template<class T>
T& assign(myPrint printObj, T& t){
	cout<<t;
	return t;
}

template<class T>
myPrint assign(T &t, myPrint printObj){
	cin>>t;
	return printObj;
}

template<class T1,class T2>
T2 assign(T1& lhs,T2 rhs){
	lhs=rhs;
	return rhs;
}

myPrint assign(char* t, myPrint printObj){
	char c;
	for(int i=0;i<8;i++){
		cin.get(c);
		if(c=='\n'){
			t[i]=0;
			break;
		}
		t[i]=c;	
	}
	return printObj;
}

char *assign(char lhs[8],char rhs[8]){
	for(int i=0;i<8;i++){
		lhs[i]=rhs[i];
	}
	return rhs;
}

void assign(myPrint printObj, char* t){
	cout<<t[0];
	for(int i=1;i<8 && t[i];i++){
		cout<<t[i];
	}
}

long int LINENO=1;

int main(){
	try{
