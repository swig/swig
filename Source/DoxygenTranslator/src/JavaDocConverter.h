 #include <list>
 #include <string>
 #include "DoxygenEntity.h"
#ifndef JAVADOCCONVERTER_H_
#define JAVADOCCONVERTER_H_

class JavaDocConverter
{
public:

	JavaDocConverter();
	string convertToJavaDoc(list <DoxygenEntity> entityList);
	~JavaDocConverter();
	void printSortedTree(list <DoxygenEntity> &entityList);
};

#endif /*JAVADOCCONVERTER_H_*/
