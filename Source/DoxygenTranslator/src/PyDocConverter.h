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
    string convertToPyDoc(Node *n, list <DoxygenEntity> entityList);
    ~PyDocConverter();
    void printSortedTree(list <DoxygenEntity> &entityList);

protected:
	std::string formatParam(Node *n, DoxygenEntity &doxygenEntity);
    std::string formatCommand(string unformattedLine, int indent);
    std::string pyDocFormat(DoxygenEntity &doxygenEntity);
    std::string translateSubtree( DoxygenEntity &doxygenEntity);
    std::string translateEntity(Node *n, DoxygenEntity &doxyEntity);
    
private:
    bool debug;
};

#endif /*PYDOCCONVERTER_H_*/
