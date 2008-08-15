#ifndef DOXYGENPARSER_H_
#define DOXYGENPARSER_H_
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <list>
#include "DoxygenEntity.h"
#include "TokenList.h"
#include "JavaDocConverter.h"
class DoxygenParser
{
public:
	DoxygenParser();
	virtual ~DoxygenParser();
	list <DoxygenEntity> createTree(string doxygen);
};

#endif /*DOXYGENPARSER_H_*/
