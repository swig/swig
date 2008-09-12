#include "DoxygenParser.h"
#include "DoxygenTranslator.h"
#include <cstdlib>
#include <iostream>
#include <string>
#include "DoxygenEntity.h"
#include "JavaDocConverter.h"
#include "PyDocConverter.h"

DoxygenParser doxyParse;
JavaDocConverter jDC;
PyDocConverter pyDC;

DoxygenTranslator::DoxygenTranslator(){
	doxyParse = DoxygenParser();
    JavaDocConverter jDC = JavaDocConverter();
    PyDocConverter pyDC = PyDocConverter();
}

DoxygenTranslator::~DoxygenTranslator(){
	
}


char *DoxygenTranslator::convert(Node *n, char* doxygenBlob, char* option){
	
	list <DoxygenEntity> rootList = doxyParse.createTree(string(doxygenBlob));
	
	string returnedString;
	if(strcmp(option, "JAVADOC") == 0){
	    returnedString = jDC.convertToJavaDoc(n, rootList);
	}
	else if(strcmp(option, "PYDOC") == 0){
	    returnedString = pyDC.convertToPyDoc(n, rootList);
	}
	else cout << "Option not current supported.\n";
	char *nonConstString;
	nonConstString = (char *)malloc(returnedString.length() + 1);
	strcpy(nonConstString, returnedString.c_str());
	return nonConstString;
}

int testCommands(){
	string exampleArray[] = {
	"/**\n * Random Line \n * \\@ \n * Random Line After */",
	"/**\n *  Random Line Before \n * \n * \\b bold \n * Random Line After */",
	"/**\n *  Random Line \n * \n *\\copydoc bold \n * Random Line After */",
	"/**\n *  Random Line \n * \n * \\addindex An Entire Line\n * \\addindex An Entire Line\n * Random Line After */",
	"/**\n *  Random Line \n * \n * \\return An Entire Paragraph \n * Including This Line \n * \n * Random Line After */",
	"/**\n *  Random Line \n * \n * \\return An Entire Paragraph \n * Including This Line \n * \\author Shouldn't be part of return */",
	"/**\n *  Random Line \n * \n * \\code this should continue \n * until here \\endcode \n * Random Line After */",
	"/**\n *  Random Line \n * \n * \\param singleword then the rest of \n *  the description \n * \n * Random Line After */",
	"/**\n *  Random Line \n * \n * \\page  singleword this should go til here \n * but not this */",
	"/**\n *  Random Line \n * \n * \\page  singleword this should go til here \n * but not this */",
	"/**\n *  Random Line \n * \n * \\category  singleword \n * but not this */",
	"/**\n *  Random Line \n * \n * \\category  singleword oneword \n * but not this */",
	"/**\n *  Random Line \n * \n * \\category  singleword oneword twoword \n * but not this */",
	"/**\n *  Random Line \n * \n * \\dir singleword \n * but not this */",
	"/**\n *  Random Line \n * \n * \\dir \n * but not this */",
	"/**\n *  Random Line \n * \n * \\fakecommand details \n * but not this */"
	};
	//string exampleArrayUniques = {};
	DoxygenTranslator dT = DoxygenTranslator();
	for (int i = 0; i < 16; i ++ ){
		//cout << "---ORIGINAL DOXYGEN--- " << endl << exampleArray[i] << endl;
		char *nonConstString = (char *)malloc(exampleArray[i].length()+1);
		strcpy(nonConstString, exampleArray[i].c_str());
		char * result = dT.convert(NULL, nonConstString, "JAVADOC");
		free(nonConstString);
		free(result);
	}
	return 1;
}

//int main(int argc, char *argv[]){
	//string doxygenString1 = "//! \\brief a brief description \n\n A normal member taking two arguments and returning an \\b integer value. This is a very long description for the simple purpose of showing off formatting. Let's make it a bit longer just to be sure. \n/*!\n \\param a an \\b integer argument.\n \\return The test results\n \\param s a constant character pointer. Let's also make this a very long description! \n \\bug this command should, for now, be totally ignored\n \\author cheryl foil\n \\sa Test(), ~Test(), testMeToo() and publicVar()\n */";
	//cout << "---ORIGINAL DOXYGEN--- " << endl << doxygenString1 << endl;
	//char *nonConstString = (char *)malloc(doxygenString1.length()+1);
	//strcpy(nonConstString, doxygenString1.c_str());
	//DoxygenTranslator dT = DoxygenTranslator();
	//char *result = dT.convert("/**\n * \n * Random Line \n * \n * \\name An Entire Line \n * NOT This Line \n * \n * Random Line After */", "JAVADOC");
	//result = dT.convert(nonConstString, "JAVADOC");
	//cout << "End";
	//list <DoxygenEntity> rootList = doxyParse.createTree(doxygenString1);
    //JavaDocConverter jDC = JavaDocConverter();
    //jDC.convertToJavaDoc(rootList);
	//testCommands();
	//return 1;
//}



