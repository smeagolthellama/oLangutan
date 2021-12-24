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
map<string,int> index;
var_memory null;

class myPrint{
	public
		template<class T>
		T operator=(T i){
			cout<<i;
			return i;
		}
} printObj;

int main(){
