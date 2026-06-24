/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * swiftdoc.h
 *
 * Module to return documentation for nodes formatted for Swift markup
 * (the markdown-based "Swift Markup" understood by Xcode / DocC / SourceKit).
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_SWIFTDOC_H
#define SWIG_SWIFTDOC_H

#include "doxytranslator.h"
#include <map>
#include <string>

/*
 * Maps a wrapped function's original C++ name to the Swift name it was renamed to
 * by the swift module's -autorename option (e.g. "GetVersion" -> "getVersion").
 * Populated by the swift module (Source/Modules/swift.cxx) and consulted by the
 * doc translator so that function references in Doxygen comments use the renamed
 * Swift name.  Only renamed functions are recorded, so type names never match.
 */
extern std::map<std::string, std::string> swiftRenamedSymbols;

/*
 * A class to translate Doxygen comments into Swift documentation comments.
 *
 * The output is a /** ... *\/ block comment whose body is Swift Markup: a markdown
 * summary/description followed by field callouts such as `- Parameter x:`,
 * `- Returns:`, `- Throws:`, `- Note:`, etc.  Every Doxygen command is handled so
 * that no markup is lost or emitted verbatim in a way Swift would not understand.
 */
class SwiftDocConverter : public DoxygenTranslator {
public:
  SwiftDocConverter(int flags = 0);
  String *makeDocumentation(Node *node);

protected:
  /* Translate every entity in a subtree, returning the rendered Swift markup. */
  std::string translateSubtree(DoxygenEntity &doxygenEntity);

  /* Translate one entity with the handler registered for its command. */
  void translateEntity(DoxygenEntity &tag, std::string &translatedComment);

  /* Move trailing line endings of child entities up to the parent (as in javadoc). */
  int shiftEndlinesUpTree(DoxygenEntity &root, int level = 0);

  typedef void (SwiftDocConverter::*tagHandler)(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* Wrap the command content in a markdown inline marker (arg is e.g. "*", "**", "`"). */
  void handleTagEmphasis(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* Render the command content as a markdown list item ("- ..."). */
  void handleTagListItem(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* Output a single literal character (arg overrides the command text if non-empty). */
  void handleTagChar(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* Strip the command, emit only its content. */
  void handleParagraph(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* Emit the raw text of a plain-string entity. */
  void handlePlainString(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* Emit a newline inside the comment body. */
  void handleNewLine(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* Emit a Swift callout ("- <arg>") followed by the command content, e.g. "- Note:". */
  void handleTagMessage(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@param`/`@tparam` -> "- Parameter <name>:". */
  void handleTagParam(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@return`/`@returns`/`@result` -> "- Returns:". */
  void handleTagReturn(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@throw`/`@throws`/`@exception` -> "- Throws:". */
  void handleTagThrows(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@see`/`@sa` -> "- SeeAlso:". */
  void handleTagSee(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@ref` -> rendered as inline code referencing the anchor/symbol. */
  void handleTagRef(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@link ... @endlink` -> rendered as inline code plus following text. */
  void handleTagLink(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@code`/`@verbatim` -> a fenced markdown code block. */
  void handleTagCode(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `\f$ \f[ \f{` LaTeX formulae -> emitted verbatim (best effort). */
  void handleTagVerbatim(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@if/@ifnot/@else/@elseif` -> emit the conditional content with a marker. */
  void handleTagIf(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@par [title]` -> a titled paragraph. */
  void handleTagPar(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* `@image html file ["title"]` -> a markdown image. */
  void handleTagImage(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* HTML tags recognised by Doxygen (<b>, <i>, <ul>, <li>, <br>, ...) -> markdown. */
  void handleDoxyHtmlTag(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

  /* HTML entities (&lt; &amp; &copy; ...) -> the literal (Unicode) character. */
  void handleHtmlEntity(DoxygenEntity &tag, std::string &translatedComment, std::string &arg);

private:
  Node *currentNode;
  // pending emphasis/markers opened by HTML tags, so a matching close emits the same marker
  static std::map<std::string, std::pair<tagHandler, std::string> > tagHandlers;
  void fillStaticTables();

  bool paramExists(std::string param);
  std::string indentAndInsertAsterisks(const std::string &doc);
};

#endif
