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

DoxygenTranslator::DoxygenTranslator(bool debugTranslator, bool debugParser)
: debug(debugTranslator), parser(debugParser) {
}
DoxygenTranslator::~DoxygenTranslator() {
}

bool DoxygenTranslator::hasDocumentation(Node *node) {
  return getDoxygenComment(node);
}

String *DoxygenTranslator::getDoxygenComment(Node *node) {
  return Getattr(node, "DoxygenComment");
}


String *DoxygenTranslator::getDocumentation(Node *node) {
  
  if (!hasDocumentation(node))
    return 0;
  
  return makeDocumentation(node);
}

void DoxygenTranslator::printTree(std::list < DoxygenEntity > &entityList) {
  std::list < DoxygenEntity >::iterator p = entityList.begin();
  while (p != entityList.end()) {
    (*p).printEntity(0);
    p++;
  }
}
