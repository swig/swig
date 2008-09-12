#ifndef PYDOCCONVERTER_H_
#define PYDOCCONVERTER_H_

#include <list>
#include <string>
#include "swig.h"
#include "DoxygenEntity.h"

#define DOC_STRING_LENGTH	  64  // characters per line allowed
#define DOC_PARAM_STRING_LENGTH	  30  // characters reserved for param name / type

class PyDocConverter
{
public:
  PyDocConverter();
  std::string convertToPyDoc(Node *n, std::list <DoxygenEntity> entityList);
  ~PyDocConverter();
  void printTree(std::list <DoxygenEntity> &entityList);

protected:
  std::string formatParam(Node *n, DoxygenEntity &doxygenEntity);
  std::string formatCommand(std::string unformattedLine, int indent, int maxWidth = DOC_STRING_LENGTH);
  std::string translateSubtree( DoxygenEntity &doxygenEntity);
  std::string translateEntity(Node *n, DoxygenEntity &doxyEntity);
    
private:
  bool debug;
};

#endif /*PYDOCCONVERTER_H_*/
