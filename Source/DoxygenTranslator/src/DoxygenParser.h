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
  std::list <DoxygenEntity> createTree(std::string doxygen);
};

#endif /*DOXYGENPARSER_H_*/
