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
  std::string convertToJavaDoc(Node *n, std::list <DoxygenEntity> entityList);
  ~JavaDocConverter();
  void printSortedTree(std::list <DoxygenEntity> &entityList);
};

#endif /*JAVADOCCONVERTER_H_*/
