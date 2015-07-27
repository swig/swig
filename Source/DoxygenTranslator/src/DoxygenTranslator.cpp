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

DoxygenTranslator::DoxygenTranslator(int flags) :
  m_flags(flags),
  parser((flags & debug_parser) != 0)
{}


DoxygenTranslator::~DoxygenTranslator() {
}


bool DoxygenTranslator::hasDocumentation(Node *node) {
  return getDoxygenComment(node) != NULL;
}


String *DoxygenTranslator::getDoxygenComment(Node *node) {
  return Getattr(node, "doxygen");
}


String *DoxygenTranslator::getDocumentation(Node *node) {
  
  if (!hasDocumentation(node)) {
    return NewString("");
  }
  
  return makeDocumentation(node);
}


void DoxygenTranslator::printTree(const DoxygenEntityList &entityList) {

  for (DoxygenEntityListCIt p = entityList.begin(); p != entityList.end(); p++) {
    p->printEntity(0);
  }
}
