/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
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
class JavaDocConverter : public DoxygenTranslator
{
public:
  JavaDocConverter() : debug( true ){}
  virtual bool getDocumentation(Node *node, String *&documentation);
  
protected:
  std::string formatCommand(std::string unformattedLine, int indent);
  std::string translateEntity(DoxygenEntity &doxyEntity);
  std::string javaDocFormat(DoxygenEntity &doxygenEntity);
  std::string translateSubtree( DoxygenEntity &doxygenEntity);
  
private:
  bool debug;
};

#endif /*JAVADOCCONVERTER_H_*/
