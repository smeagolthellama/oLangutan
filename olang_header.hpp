#include <iostream>
#include <vector>
#include <map>
#include <string>
using namespace std;

typedef union {
	long long	integer;
	double	real;
	char	raw[8];
}var_memory;

vector<var_memory> var;
map<int,int> index;
var_memory null;

class myPrint{
	public:
		template<class T>
		T operator=(T i){
			cout<<i;
			return i;
		}
} printObj;

template<class T>
myPrint operator=(T t,myPrint &prt){
	cin>>t;
	return prt;
}

myPrint operator=(char* t,myPrint &prt){
	int i;
	for(i=0;i<8;i++){
		cin.get(t[i]);
		if(t[i]=='\n'){
			t[i]=0;
			return prt;
		}
	}
	return prt;
}

int main(){
