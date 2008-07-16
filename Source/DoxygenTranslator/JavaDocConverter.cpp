#include "JavaDocConverter.h"
#include <cstdlib>
#include <iostream>
#include <string>
#include <list>

int printTree = 1;
JavaDocConverter::JavaDocConverter()
{
}

JavaDocConverter::~JavaDocConverter()
{
}

/* Sorts entities by javaDoc standard order for commands
 * NOTE: will not behave entirely properly until "First level" comments
 * such as brief descriptions are TAGGED as such
 */
bool compare_DoxygenEntities(DoxygenEntity first, DoxygenEntity second){
	if(first.typeOfEntity.compare("plainstring") == 0) return true;
	if(second.typeOfEntity.compare("plainstring") == 0) return false;
	if(first.typeOfEntity.compare("param") == 0){
		if(second.typeOfEntity.compare("param")== 0) return true;
		if(second.typeOfEntity.compare("return")== 0) return true;
		if(second.typeOfEntity.compare("exception")== 0) return true;
		if(second.typeOfEntity.compare("author")== 0) return true;
		if(second.typeOfEntity.compare("version")== 0)return true;
		if(second.typeOfEntity.compare("see")== 0)return true;
		if(second.typeOfEntity.compare("since")== 0)return true;
		if(second.typeOfEntity.compare("deprecated")== 0)return true;
		return false;
	}
	if(first.typeOfEntity.compare("return")== 0){
		if(second.typeOfEntity.compare("return")== 0) return true;
		if(second.typeOfEntity.compare("exception")== 0) return true;
		if(second.typeOfEntity.compare("author")== 0) return true;
		if(second.typeOfEntity.compare("version")== 0)return true;
		if(second.typeOfEntity.compare("see")== 0)return true;
		if(second.typeOfEntity.compare("since")== 0)return true;
		if(second.typeOfEntity.compare("deprecated")== 0)return true;
		return false;
		
	}
	if(first.typeOfEntity.compare("exception")== 0){
		if(second.typeOfEntity.compare("exception")== 0) return true;
		if(second.typeOfEntity.compare("author")== 0) return true;
		if(second.typeOfEntity.compare("version")== 0)return true;
		if(second.typeOfEntity.compare("see")== 0)return true;
		if(second.typeOfEntity.compare("since")== 0)return true;
		if(second.typeOfEntity.compare("deprecated")== 0)return true;
		return false;
	}
	if(first.typeOfEntity.compare("author")== 0){
		if(first.typeOfEntity.compare("author")== 0) return true;
		if(first.typeOfEntity.compare("version")== 0)return true;
		if(first.typeOfEntity.compare("see")== 0)return true;
		if(first.typeOfEntity.compare("since")== 0)return true;
		if(first.typeOfEntity.compare("deprecated")== 0)return true;
		return false;
	}
	if(first.typeOfEntity.compare("version")== 0){
		if(second.typeOfEntity.compare("version")== 0)return true;
		if(second.typeOfEntity.compare("see")== 0)return true;
		if(second.typeOfEntity.compare("since")== 0)return true;
		if(second.typeOfEntity.compare("deprecated")== 0)return true;
		return false;
	}
	if(first.typeOfEntity.compare("see")== 0){
		if(second.typeOfEntity.compare("see")== 0)return true;
		if(second.typeOfEntity.compare("since")== 0)return true;
		if(second.typeOfEntity.compare("deprecated")== 0)return true;
		return false;
	}
	if(first.typeOfEntity.compare("since")== 0){
		if(second.typeOfEntity.compare("since")== 0) return true;
		if(second.typeOfEntity.compare("deprecated")== 0)return true;
		return false;
	}
	if(first.typeOfEntity.compare("deprecated")== 0){
		if(second.typeOfEntity.compare("deprecated")== 0)return true;
		return false;
	}
	return true;
}

string JavaDocConverter:: convertToJavaDoc(list <DoxygenEntity> entityList){
	
	list<DoxygenEntity>::iterator entityIterator = entityList.begin();
	entityList.sort(compare_DoxygenEntities);

	cout << "---RESORTED LIST---" << endl;
	if (printTree ){
		list<DoxygenEntity>::iterator p = entityList.begin();
		while (p != entityList.end()){
			(*p).printEntity(0);
			p++;
		}
	}
	string javaDocString = "/**\n";
	
	javaDocString += "*/\n";
	return javaDocString;
}
