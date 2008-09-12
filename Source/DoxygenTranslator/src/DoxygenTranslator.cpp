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
	
  std::list <DoxygenEntity> rootList = doxyParse.createTree(std::string(doxygenBlob));
  std::string returnedString;
  
  if(strcmp(option, "JAVADOC") == 0)
    returnedString = jDC.convertToJavaDoc(n, rootList);
  else if(strcmp(option, "PYDOC") == 0)
    returnedString = pyDC.convertToPyDoc(n, rootList);
  else 
    std::cout << "Option not current supported." << std::endl;
	
  char *nonConstString;
  nonConstString = (char *)malloc(returnedString.length() + 1);
  strcpy(nonConstString, returnedString.c_str());
  
  return nonConstString;
}

