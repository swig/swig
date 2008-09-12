/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * DoxygenTranslator.cpp
 *
 * Module to return documentation for nodes formatted for various documentation
 * systems.
 * ----------------------------------------------------------------------------- */

#include "DoxygenTranslator.h"
#include "JavaDocConverter.h"
#include "PyDocConverter.h"

bool DoxygenTranslator::getDocumentation(Node *node, DocumentationFormat format, String *&documentation){
  switch(format){
    case JavaDoc:   
      return JavaDocConverter().getDocumentation(node, documentation);
    case PyDoc:   
      return PyDocConverter().getDocumentation(node, documentation);
    default:
      return false;
  }
}

void DoxygenTranslator::printTree(std::list<DoxygenEntity> &entityList){  
  std::list<DoxygenEntity>::iterator p = entityList.begin();
  while (p != entityList.end()){
    (*p).printEntity(0);
    p++;
  }
}