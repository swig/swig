/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
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
#include "DoxygenParser.h"
#include <list>
#include <string>


/*
 * This is a base class for translator classes. It defines the basic interface
 * for translators, which convert Doxygen comments into alternative formats for
 * target languages.
 */
class DoxygenTranslator {
public:
  /*
   * Constructor
   */
  DoxygenTranslator(bool debugTranslator = false, bool debugParser = false);

  /*
   * Virtual destructor.
   */
  virtual ~DoxygenTranslator();

  /*
   * Return the documentation for a given node formated for the correct 
   * documentation system.
   */
  String *getDocumentation(Node *node);

  /*
   * Returns truem is the specified node has comment attached.
   */
  bool hasDocumentation(Node *node);

  /*
   * Get original comment string in Doxygen-format.
   */
  String *getDoxygenComment(Node *node);

protected:
  bool debug;
  DoxygenParser parser;

  /*
   * Returns the documentation formatted for a target language.
   */
  virtual String *makeDocumentation(Node *node) = 0;
  
  /*
   * Prints the details of a parsed entity list to stdout (for debugging).
   */
  void printTree(const DoxygenEntityList &entityList);
  
};

#endif
