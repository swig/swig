#ifndef PYDOCCONVERTER_H_
#define PYDOCCONVERTER_H_

#include <list>
#include <string>
#include "swig.h"
#include "DoxygenEntity.h"

class PyDocConverter
{
public:
  PyDocConverter();
  std::string convertToPyDoc(Node *n, std::list <DoxygenEntity> entityList);
  ~PyDocConverter();
  void printSortedTree(std::list <DoxygenEntity> &entityList);

protected:
  std::string formatParam(Node *n, DoxygenEntity &doxygenEntity);
  std::string formatCommand(std::string unformattedLine, int indent);
  std::string pyDocFormat(DoxygenEntity &doxygenEntity);
  std::string translateSubtree( DoxygenEntity &doxygenEntity);
  std::string translateEntity(Node *n, DoxygenEntity &doxyEntity);
    
private:
  bool debug;
};

#endif /*PYDOCCONVERTER_H_*/
