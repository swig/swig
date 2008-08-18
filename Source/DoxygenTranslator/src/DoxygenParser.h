#ifndef DOXYGENPARSER_H_
#define DOXYGENPARSER_H_
#include <string>
#include <list>
#include "DoxygenEntity.h"
class DoxygenParser
{
public:
	DoxygenParser();
	virtual ~DoxygenParser();
	list <DoxygenEntity> createTree(string doxygen);
};

#endif /*DOXYGENPARSER_H_*/
