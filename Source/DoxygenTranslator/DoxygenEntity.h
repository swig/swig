
#include <cstdlib>
#include <iostream>
#include <string>
#include <list>

using namespace std;

class DoxygenEntity{

public:
	DoxygenEntity(int typeEnt);
	DoxygenEntity(int typeEnt, string param1);
	DoxygenEntity(int typeEnt, list <DoxygenEntity> entList);
	virtual ~DoxygenEntity();
	void printEntity();
    int typeOfEntity;
    list <DoxygenEntity> entityList;
    string data;
    int isLeaf;
};


