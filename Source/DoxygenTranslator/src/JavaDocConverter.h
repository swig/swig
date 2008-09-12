#ifndef JAVADOCCONVERTER_H_
#define JAVADOCCONVERTER_H_

#include <list>
#include <string>
#include "swig.h"
#include "DoxygenEntity.h"

class JavaDocConverter
{
public:

	JavaDocConverter();
	string convertToJavaDoc(Node *n, list <DoxygenEntity> entityList);
	~JavaDocConverter();
	void printSortedTree(list <DoxygenEntity> &entityList);
};

#endif /*JAVADOCCONVERTER_H_*/
