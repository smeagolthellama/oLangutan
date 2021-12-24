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
map<int,int> varindex;
var_memory null;

class myPrint{
	public:
		template<class T>
		T operator=(T i){
			cout<<i;
			return i;
		}

		template<class T>
		operator T() const{
			T t;
			cin>>t;
			return t;
		}

		operator char*() const{
			char t[8];
			int i;
			for(i=0;i<8;i++){
				cin>>t[i];
				if(t[i]=='\n'){
					t[i]=0;
				}
				return strdup(t);
			}
			return strdup(t);
		}
} printObj;

int main(){
