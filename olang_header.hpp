R"(

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

int main(){

)"
