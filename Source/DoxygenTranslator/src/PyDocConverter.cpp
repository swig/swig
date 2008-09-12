#include "PyDocConverter.h"
#include <iostream>
#include <sstream>

#define APPROX_LINE_LENGTH 64//characters per line allowed
#define TAB_SIZE 8//characters per line allowed

//TODO {@link} {@linkplain} {@docRoot}, and other useful doxy commands that are not a pydoc tag
PyDocConverter::PyDocConverter()
{
    debug = 1;
}

PyDocConverter::~PyDocConverter()
{
}

/* Sorts entities by pyDoc standard order for commands
 * NOTE: will not behave entirely properly until "First level" comments
 * such as brief descriptions are TAGGED as such
 */
bool compare_DoxygenEntities(DoxygenEntity first, DoxygenEntity second);
 
void PyDocConverter::printSortedTree(list <DoxygenEntity> &entityList){
	list<DoxygenEntity>::iterator p = entityList.begin();
	while (p != entityList.end()){
		(*p).printEntity(0);
		p++;
	}
}

string PyDocConverter::formatParam(Node *n, DoxygenEntity &doxygenEntity) {
	string result;
	ParmList *plist = CopyParmList(Getattr(n, "parms"));
	Parm *p = NULL;
	
	DoxygenEntity& paramNameEntity = *doxygenEntity.entityList.begin();
	DoxygenEntity& paramDescriptionEntity = *(++doxygenEntity.entityList.begin());
	
	for (p = plist; p;) {
		if(Char(Getattr(p, "name")) == paramNameEntity.data) {
			std::string name = Char(Swig_name_make(n, 0, Getattr(p, "name"), 0, 0));
			std::string type = Char(Swig_name_make(n, 0, Getattr(p, "type"), 0, 0));
			
			std::ostringstream parameterDocString;
			
			parameterDocString << std::endl << name << " (" << type << "): ";
			parameterDocString << paramDescriptionEntity.data;
			
			result = parameterDocString.str();
			break;
		}
		p = Getattr(p, "tmap:in") ? Getattr(p, "tmap:in:next") : nextSibling(p);
	}

	Delete(plist);
	return result;
}

string PyDocConverter::formatCommand(string unformattedLine, int indent){
	string formattedLines = "\n";
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
			formattedLines.append("\n");

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
string PyDocConverter::pyDocFormat(DoxygenEntity &doxygenEntity){
	if(doxygenEntity.typeOfEntity.compare("partofdescription") == 0){
				return doxygenEntity.data;
		}
	if (doxygenEntity.typeOfEntity.compare("plainstring") == 0){
			return  doxygenEntity.data;
	}
	else if (doxygenEntity.typeOfEntity.compare("b") == 0){
		return "<b>" + doxygenEntity.data + "</b>";
	}
	else if (doxygenEntity.typeOfEntity.compare("c") == 0){
		return "<tt>" + doxygenEntity.data + "</tt>";
	}
	else if (doxygenEntity.typeOfEntity.compare("@") == 0){
		return "@";
	}
	else if (doxygenEntity.typeOfEntity.compare("\\") == 0){
		return "\\";
	}
	else if (doxygenEntity.typeOfEntity.compare("<") == 0){
		return "&lt;";
	}
	else if (doxygenEntity.typeOfEntity.compare(">") == 0){
		return "&gt;";
	}
	else if (doxygenEntity.typeOfEntity.compare("&") == 0){
		return "&amp;";
	}
	else if (doxygenEntity.typeOfEntity.compare("#") == 0){
		return "#";
	}
	else if (doxygenEntity.typeOfEntity.compare("%") == 0){
		return "%";
	}
	else if (doxygenEntity.typeOfEntity.compare("~") == 0){
		return "~";
	}
	return "";
}


string PyDocConverter::translateSubtree( DoxygenEntity &doxygenEntity){
	string returnedString;
	if (doxygenEntity.isLeaf){ return pyDocFormat(doxygenEntity) + " ";}
	else {
		returnedString += pyDocFormat(doxygenEntity);
		list<DoxygenEntity>::iterator p = doxygenEntity.entityList.begin();
		while (p != doxygenEntity.entityList.end()){
			returnedString+= translateSubtree(*p);
			p++;
		}
	}
	return returnedString;
}

string PyDocConverter::translateEntity(Node *n, DoxygenEntity &doxyEntity){
	if(doxyEntity.typeOfEntity.compare("partofdescription")== 0) return formatCommand(string(translateSubtree(doxyEntity)), 0);
	if ((doxyEntity.typeOfEntity.compare("brief") == 0)||(doxyEntity.typeOfEntity.compare("details") == 0)){
		return formatCommand(string(translateSubtree(doxyEntity)), 0) + "\n * ";}
	else if(doxyEntity.typeOfEntity.compare("plainstring")== 0 
			|| doxyEntity.typeOfEntity.compare("deprecated")== 0 
			|| doxyEntity.typeOfEntity.compare("brief")== 0)
		return formatCommand(doxyEntity.data, 0) + "\n * ";
	else if(doxyEntity.typeOfEntity.compare("see") == 0){
		return formatCommand(string("@" + doxyEntity.typeOfEntity + "\t\t" + translateSubtree(doxyEntity)), 2);
	}
	else if(doxyEntity.typeOfEntity.compare("param") == 0) {
		return formatParam(n, doxyEntity);
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
	else return formatCommand(pyDocFormat(doxyEntity), 0 );
	return "";
}

string PyDocConverter::convertToPyDoc(Node *n, list <DoxygenEntity> entityList){
	entityList.sort(compare_DoxygenEntities);
	
    if(debug){
	    cout << "---RESORTED LIST---" << endl;
        printSortedTree(entityList);
    }

	string pyDocString = "\"\"\"";

	list<DoxygenEntity>::iterator entityIterator = entityList.begin();
	while (entityIterator != entityList.end()){
		pyDocString += translateEntity(n, *entityIterator);
		entityIterator++;
	}

	pyDocString += "\n\"\"\"\n";
	
	if(debug){
	    cout << "\n---RESULT IN PYDOC---" << endl;
	    cout << pyDocString; 
	}
	
	return pyDocString;
}