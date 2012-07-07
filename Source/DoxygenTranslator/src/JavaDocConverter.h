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
#include <map>

/*
 * A class to translate doxygen comments into JavaDoc style comments.
 */
class JavaDocConverter : public DoxygenTranslator {
public:
  JavaDocConverter();
  String *makeDocumentation(Node *node);

protected:
  std::string formatCommand(std::string unformattedLine, int indent);
  std::string javaDocFormat(DoxygenEntity & doxygenEntity);
  std::string translateSubtree(DoxygenEntity & doxygenEntity);
  void translateEntity(DoxygenEntity &tag, std::string &translatedComment);
  
  /*
   * Typedef for the function that handles one tag
   */
  typedef void (*tagHandler)(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);
  /*
   * Here comes various tag handlers
   */
  static void handleTagC(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);
  static void handleTagB(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);
  static void handleTagThrow(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);
  static void handleTagSeeAll(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);
  /*
   * Print the name of tag to the output, used for escape-commands
   */
  static void handleTagChar(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);
  /*
   * Do not translate and print as-is
   */
  static void handleTagSame(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);
  /*
   * Print only the content and strip original tag
   */
  static void handleParagraph(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);
  /*
   * Print only data part of code
   */
  static void handlePlainString(JavaDocConverter *converter, DoxygenEntity &tag, std::string &translatedComment);

private:
  bool debug;
  static std::map<std::string, tagHandler> tagHandlers;
  static std::map<std::string, std::string> escapeTable;
  void fillStaticTables();
};

#endif
