/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * JavaDocConverter.h
 *
 * Module to return documentation for nodes formatted for JavaDoc
 * ----------------------------------------------------------------------------- */

#ifndef JAVADOCCONVERTER_H_
#define JAVADOCCONVERTER_H_

#include "DoxygenTranslator.h"

/*
 * A class to translate doxygen comments into JavaDoc style comments.
 */
class JavaDocConverter : public DoxygenTranslator {
public:
  JavaDocConverter() : debug(false) {
  }
  String *makeDocumentation(Node *node);

protected:
  std::string formatCommand(std::string unformattedLine, int indent);
  std::string translateEntity(DoxygenEntity & doxyEntity);
  std::string javaDocFormat(DoxygenEntity & doxygenEntity);
  std::string translateSubtree(DoxygenEntity & doxygenEntity);

private:
  bool debug;
};

#endif
