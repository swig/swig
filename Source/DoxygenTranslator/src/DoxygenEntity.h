#ifndef DOXYGENENTITY_H_
#define DOXYGENENTITY_H_

#include <cstdlib>
#include <iostream>
#include <string>
#include <list>

using namespace std;

class DoxygenEntity{

public:
	DoxygenEntity(string typeEnt);
	DoxygenEntity(string typeEnt, string param1);
	DoxygenEntity(string typeEnt, list <DoxygenEntity> &entList );
   ~DoxygenEntity();
	void printEntity(int level);
    string typeOfEntity;
    list <DoxygenEntity> entityList;
    string data;
    int isLeaf;
};


#endif /*TOKENLIST_H_*/
