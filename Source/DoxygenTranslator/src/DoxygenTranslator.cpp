

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

int testCommands(){
	string exampleArray[] = {
	"/**\n * \n * Random Line \n * \\@ \n * Random Line After */",
	"/**\n * \n * Random Line Before \n * \\b bold \n * Random Line After */",
	"/**\n * \n * Random Line \n * \\copydoc bold \n * Random Line After */",
	"/**\n * \n * Random Line \n * \n * \\addindex An Entire Line\n * \\addindex An Entire Line\n * Random Line After */",
	"/**\n * \n * Random Line \n * \n * \\return An Entire Paragraph \n * Including This Line \n * \n * Random Line After */",
	"/**\n * \n * Random Line \n * \\return An Entire Paragraph \n * Including This Line \n * \\author Shouldn't be part of return */",
	"/**\n * \n * Random Line \n * \\code this should continue \n * until here \\endcode \n * Random Line After */",
	"/**\n * \n * Random Line \n * \\param singleword then the rest of \n *  the description \n * \n * Random Line After */",
	"/**\n * \n * Random Line \n * \\page  singleword this should go til here \n * but not this */",
	"/**\n * \n * Random Line \n * \\page  singleword this should go til here \n * but not this */",
	"/**\n * \n * Random Line \n * \\category  singleword \n * but not this */",
	"/**\n * \n * Random Line \n * \\category  singleword oneword \n * but not this */",
	"/**\n * \n * Random Line \n * \\category  singleword oneword twoword \n * but not this */",
	"/**\n * \n * Random Line \n * \\dir singleword \n * but not this */",
	"/**\n * \n * Random Line \n * \\dir \n * but not this */",
	"/**\n * \n * Random Line \n * \\fakecommand details \n * but not this */"
	};
	//string exampleArrayUniques = {};
	DoxygenTranslator dT = DoxygenTranslator();
	for (int i = 0; i < 16; i ++ ){
		cout << "---ORIGINAL DOXYGEN--- " << endl << exampleArray[i] << endl;
		char *nonConstString = (char *)malloc(exampleArray[i].length()+1);
		strcpy(nonConstString, exampleArray[i].c_str());
		dT.convert(nonConstString, "JAVADOC");
	}
	return 1;
}
