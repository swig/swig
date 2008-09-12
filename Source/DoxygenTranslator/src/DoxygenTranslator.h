/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * DoxygenTranslator.h
 *
 * Module to return documentation for nodes formatted for various documentation
 * systems.
 * ----------------------------------------------------------------------------- */

#ifndef DOXYGENTRANSLATOR_H_
#define DOXYGENTRANSLATOR_H_

#include "swig.h"
#include "DoxygenEntity.h"
#include <list>

/*
 * Describes the availible documentation systems
 * that can be translated to.
 */
enum DocumentationFormat {
  JavaDoc = 1,
  PyDoc = 2
};

/*
 * A class to translate doxygen comments attacted to parser nodes
 * into alternative formats for use in code generated for target languages.
 */
class DoxygenTranslator
{
public:
  /*
   * Virtual destructor.
   */
  virtual ~DoxygenTranslator(){}
  
  /*
   * Return the documentation for a given node formated for the correct 
   * documentation system.
   * @param node The node to extract and translate documentation for.
   * @param format The documentation format to output.
   * @param documentation The returned documentation string.
   * @return A bool to indicate if there was documentation to return for the node.
   */
  static bool getDocumentation(Node *node, DocumentationFormat format, String *&documentation);
  
protected:
  /*
   * Overridden in subclasses to return the documentation formatted for a given
   * documentation system.
   * @param node The node to extract and translate documentation for.
   * @param documentation The returned documentation string.
   * @return A bool to indicate if there was documentation to return for the node.
   */
  virtual bool getDocumentation(Node *node, String *&documentation) = 0;
  
  /*
   * Prints the details of a parsed entity list to stdout (for debugging).
   */
  void printTree(std::list<DoxygenEntity> &entityList);
};

#endif /*DOXYGENTRANSLATOR_H_*/
