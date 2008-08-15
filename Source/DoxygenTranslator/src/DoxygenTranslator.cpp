

#include "DoxygenParser.h"
#include "DoxygenTranslator.h"
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <list>
#include "DoxygenEntity.h"
#include "TokenList.h"
#include "JavaDocConverter.h"

DoxygenParser doxyParse;
JavaDocConverter jDC;

DoxygenTranslator::DoxygenTranslator(){
	doxyParse = DoxygenParser();
    JavaDocConverter jDC = JavaDocConverter();
}

DoxygenTranslator::~DoxygenTranslator(){
	
}


char *DoxygenTranslator::convert(char* doxygenBlob, char* option){
	
	list <DoxygenEntity> rootList = doxyParse.createTree(string(doxygenBlob));
	rootList = doxyParse.createTree(string(doxygenBlob));
	string returnedString;
	if(strcmp(option, "JAVADOC") == 0){
	    returnedString = jDC.convertToJavaDoc(rootList);
	}
	else cout << "Option not current supported.\n";
	char *nonConstString;
	nonConstString = (char *)malloc(returnedString.length() + 1);
	strcpy(nonConstString, returnedString.c_str());
	return nonConstString;
}

