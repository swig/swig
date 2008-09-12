/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * PyDocConverter.h
 *
 * Module to return documentation for nodes formatted for PyDoc
 * ----------------------------------------------------------------------------- */

#ifndef PYDOCCONVERTER_H_
#define PYDOCCONVERTER_H_

#include <list>
#include <string>
#include "swig.h"
#include "DoxygenEntity.h"
#include "DoxygenTranslator.h"

#define DOC_STRING_LENGTH	  64  // characters per line allowed
#define DOC_PARAM_STRING_LENGTH	  30  // characters reserved for param name / type

class PyDocConverter : public DoxygenTranslator
{
public:
  PyDocConverter();
  bool getDocumentation(Node *node, String *&documentation);
  
protected:
  /*
   * Format the doxygen comment relating to a function or method parameter
   * @param node The parse tree node that the parameter relates to.
   * @param doxygenEntity The doxygen entity relating to the parameter docstring.
   */
  std::string formatParam(Node *node, DoxygenEntity &doxygenEntity);
  
  /*
   * Format the doxygen comment relating to the return value for a method or function.
   * @param node The parse tree node that the parameter relates to.
   * @param doxygenEntity The doxygen entity relating to the parameter docstring.
   */
  std::string formatReturnDescription(Node *node, DoxygenEntity &doxygenEntity);
  
  /*
   * Format a string so it is justified and split over several lines 
   * not exeeding a given length.
   * @param unformattedLine The string to justify and split.
   * @param indent An optional number of spaces to indent each line by.
   * @param maxWidth The approximate maximum line width.
   */
  std::string justifyString(std::string unformattedLine, int indent = 0, int maxWidth = DOC_STRING_LENGTH);
  
  std::string translateSubtree( DoxygenEntity &doxygenEntity);
  std::string translateEntity(Node *n, DoxygenEntity &doxyEntity);
    
private:
  bool debug;
};

#endif /*PYDOCCONVERTER_H_*/
