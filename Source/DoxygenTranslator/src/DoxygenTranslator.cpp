/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * DoxygenTranslator.cpp
 *
 * Module to return documentation for nodes formatted for various documentation
 * systems.
 * ----------------------------------------------------------------------------- */

#include "DoxygenTranslator.h"
#include "JavaDocConverter.h"
#include "PyDocConverter.h"

bool DoxygenTranslator::getDocumentation(Node *node, DocumentationFormat format, String *&documentation) {
  switch (format) {
  case JavaDoc:
    return JavaDocConverter().getDocumentation(node, documentation);
  case PyDoc:
    return PyDocConverter().getDocumentation(node, documentation);
  default:
    return false;
  }
}

void DoxygenTranslator::printTree(std::list < DoxygenEntity > &entityList) {
  std::list < DoxygenEntity >::iterator p = entityList.begin();
  while (p != entityList.end()) {
    (*p).printEntity(0);
    p++;
  }
}
