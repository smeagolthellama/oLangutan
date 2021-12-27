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
void assign(myPrint printObj, T t){
	cout<<t;
}

template<class T>
void assign(T &t, myPrint printObj){
	cin>>t;
}

template<class T1,class T2>
void assign(T1& lhs,T2 rhs){
	lhs=rhs;
}

void assign(char* t, myPrint printObj){
	char c;
	for(int i=0;i<8;i++){
		cin.get(c);
		if(c=='\n'){
			t[i]=0;
			break;
		}
		t[i]=c;	
	}
}

int main(){
