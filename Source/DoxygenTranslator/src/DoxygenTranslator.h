#ifndef DOXYGENTRANSLATOR_H_
#define DOXYGENTRANSLATOR_H_

#include "swig.h"

class DoxygenTranslator
{
public:
	DoxygenTranslator();
	virtual ~DoxygenTranslator();
	char* convert(Node *n, char* doxygenBlob, char* option);
};
#endif /*DOXYGENTRANSLATOR_H_*/
