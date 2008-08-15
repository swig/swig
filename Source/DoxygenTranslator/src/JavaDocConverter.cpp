#include "JavaDocConverter.h"
#include <cstdlib>
#include <iostream>
#include <string>
#include <list>
#define APPROX_LINE_LENGTH 64//characters per line allowed
#define TAB_SIZE 8//characters per line allowed
int printSortedTree2 = 0;
//TODO {@link} {@linkplain} {@docRoot}, and other useful doxy commands that are not a javadoc tag
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
	if(first.typeOfEntity.compare("see")== 0 || first.typeOfEntity.compare("sa")== 0){
		if(second.typeOfEntity.compare("see")== 0)return true;
		if(second.typeOfEntity.compare("sa")== 0)return true;
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

void JavaDocConverter::printSortedTree(list <DoxygenEntity> &entityList){
	list<DoxygenEntity>::iterator p = entityList.begin();
	while (p != entityList.end()){
		(*p).printEntity(0);
		p++;
	}
}
string formatCommand(string unformattedLine, int indent){
	string formattedLines = "\n * ";
	int lastPosition = 0;
	int i = 0;
	int isFirstLine  = 1;
	while (i != -1 && i < unformattedLine.length()){
		lastPosition = i;
		if (isFirstLine){
			i+=APPROX_LINE_LENGTH;
		}
		else i+=APPROX_LINE_LENGTH - indent*TAB_SIZE;
		i = unformattedLine.find(" ", i);

		if (i > 0 && i + 1 < unformattedLine.length()){
			if (!isFirstLine) for (int j = 0; j < indent; j++) {
				formattedLines.append("\t");
				}
			else {
				isFirstLine = 0;
			}
			formattedLines.append(unformattedLine.substr(lastPosition, i - lastPosition + 1));
			formattedLines.append("\n *");

		}
	}
	if (lastPosition < unformattedLine.length()){
		if (!isFirstLine) {for (int j = 0; j < indent; j++) {formattedLines.append("\t");}}
		formattedLines.append(unformattedLine.substr(lastPosition, unformattedLine.length() - lastPosition));
	}

	return formattedLines;
}

/* Contains the conversions for tags
 * could probably be much more efficient...
 */
string javaDocFormat(DoxygenEntity &doxygenEntity){
	if (doxygenEntity.typeOfEntity.compare("plainstring") == 0){
			return doxygenEntity.data;
	}
	else if (doxygenEntity.typeOfEntity.compare("brief") == 0){
			return doxygenEntity.data;
	}
	if (doxygenEntity.typeOfEntity.compare("detailed") == 0){
			return doxygenEntity.data;
	}
	else if (doxygenEntity.typeOfEntity.compare("b") == 0){
		return "<b>" + doxygenEntity.data + "</b>";
	}
	else if (doxygenEntity.typeOfEntity.compare("c") == 0){
		return "<tt>" + doxygenEntity.data + "</tt>";
	}
	return "";
}


string translateSubtree( DoxygenEntity &doxygenEntity){
	string returnedString;
	if (doxygenEntity.isLeaf){ return javaDocFormat(doxygenEntity) + " ";}
	else {
		returnedString += javaDocFormat(doxygenEntity);
		list<DoxygenEntity>::iterator p = doxygenEntity.entityList.begin();
		while (p != doxygenEntity.entityList.end()){
			returnedString+= translateSubtree(*p);
			p++;
		}
	}
	return returnedString;
}

string translateEntity(DoxygenEntity &doxyEntity){
	if(doxyEntity.typeOfEntity.compare("plainstring")== 0 || doxyEntity.typeOfEntity.compare("deprecated")== 0 || doxyEntity.typeOfEntity.compare("brief")== 0)
		return formatCommand(doxyEntity.data, 0) + "\n * ";
	else if(doxyEntity.typeOfEntity.compare("see") == 0){
		return formatCommand(string("@" + doxyEntity.typeOfEntity + "\t\t" + translateSubtree(doxyEntity)), 2);
	}
	else if(doxyEntity.typeOfEntity.compare("return")== 0
			|| doxyEntity.typeOfEntity.compare("author")== 0
			|| doxyEntity.typeOfEntity.compare("param")== 0
			|| doxyEntity.typeOfEntity.compare("since")== 0
			|| doxyEntity.typeOfEntity.compare("version")== 0
			|| doxyEntity.typeOfEntity.compare("exception") == 0
			|| doxyEntity.typeOfEntity.compare("deprecated") == 0){
		return formatCommand(string("@" + doxyEntity.typeOfEntity + "\t" + translateSubtree(doxyEntity)), 2);
	}
	else if(doxyEntity.typeOfEntity.compare("sa")== 0){
		return formatCommand(string("@see\t\t" + translateSubtree(doxyEntity)), 2);
	}

	return "";
}

string JavaDocConverter:: convertToJavaDoc(list <DoxygenEntity> entityList){


	entityList.sort(compare_DoxygenEntities);
    if(printSortedTree2){
	cout << "---RESORTED LIST---" << endl;
    printSortedTree(entityList);
    }

	string javaDocString = "/**";

	list<DoxygenEntity>::iterator entityIterator = entityList.begin();
	while (entityIterator != entityList.end()){
		javaDocString += translateEntity(*entityIterator);
		entityIterator++;
	}

	javaDocString += "\n */\n";
	cout << "\n---RESULT IN JAVADOC---" << endl;
	cout << javaDocString;
	return javaDocString;
}