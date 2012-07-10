/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * DoxygenParser.h
 * ----------------------------------------------------------------------------- */

#ifndef DOXYGENPARSER_H_
#define DOXYGENPARSER_H_
#include <string>
#include <list>
#include <map>
#include <set>
#include "DoxygenEntity.h"
#include "TokenList.h"
class DoxygenParser {
public:
  DoxygenParser();
  virtual ~DoxygenParser();
  std::list < DoxygenEntity > createTree(std::string doxygen, std::string fileName, int lineNumber);
private:
  
  /*
   *Changes a std::string to all lower case
   */
  std::string StringToLower(std::string stringToConvert);

  /* 
   * Finds out if a command exists (is a possible command)
   * returns -1 if no match is found
   */
  int findCommand(std::string smallString);
  /* 
   * isSectionIndicator returns a boolean if the command is a section indicator
   * This is a helper method for finding the end of a paragraph
   * by Doxygen's terms
   */
  int isSectionIndicator(std::string smallString);
  /*
   * Determines how a command should be handled (what group it belongs to
   * for parsing rules
   */
  int commandBelongs(std::string theCommand);

  /*
   *prints the parse tree
   */
  void printTree(std::list < DoxygenEntity > &rootList);

  /*
   * Returns the next word ON THE CURRENT LINE ONLY
   * if a new line is encountered, returns a blank std::string.
   * Updates the index it is given if success.
   */
  std::string getNextWord(TokenList & tokList);

  /* 
   * Returns the location of the end of the line as
   * an iterator.
   */
  std::list < Token >::iterator getOneLine(TokenList & tokList);

  /*
   * Returns a properly formatted std::string
   * up til ANY command or end of line is encountered.
   */
  std::string getStringTilCommand(TokenList & tokList);

  /*
   * Returns a properly formatted std::string
   * up til the command specified is encountered
   */
  //TODO check that this behaves properly for formulas
  std::string getStringTilEndCommand(std::string theCommand, TokenList & tokList);

  /*
   * Returns the end of a Paragraph as an iterator-
   * Paragraph is defined in Doxygen to be a paragraph of text
   * separated by either a structural command or a blank line
   */
  std::list < Token >::iterator getEndOfParagraph(TokenList & tokList);

  /*
   * Returns the end of a section, defined as the first blank line OR first encounter of the same 
   * command. Example of this behaviour is \arg
   * if no end is encountered, returns the last token of the std::list.
   */
  std::list < Token >::iterator getEndOfSection(std::string theCommand, TokenList & tokList);

  /*
   * This method is for returning the end of a specific form of doxygen command
   * that begins with a \command and ends in \endcommand
   * such as \code and \endcode. The proper usage is
   * progressTilEndCommand("endcode", tokenList);
   * If the end is never encountered, it returns the end of the std::list.
   */
  std::list < Token >::iterator getEndCommand(std::string theCommand, TokenList & tokList);
  /*
   * A specialty method for commands such as \arg that end at the end of a paragraph OR when another \arg is encountered
   */
  //TODO getTilAnyCommand
  std::list < Token >::iterator getTilAnyCommand(std::string theCommand, TokenList & tokList);

  /*
   * Method for Adding a Simple Command
   * Format: @command
   * Plain commands, such as newline etc, they contain no other data
   *  \n \\ \@ \& \$ \# \< \> \%
   */
  int addSimpleCommand(std::string theCommand, std::list < DoxygenEntity > &doxyList);
  /*
   * NOT INCLUDED Simple Commands
   * Format: @command
   * Plain commands, such as newline etc, they contain no other data
   */
  int ignoreSimpleCommand(std::string theCommand, std::list < DoxygenEntity > &doxyList);
  /*
   * CommandWord
   * Format: @command <word>
   * Commands with a single WORD after then such as @b
   * "a", "b", "c", "e", "em", "p", "def", "enum", "example", "package", 
   * "relates", "namespace", "relatesalso","anchor", "dontinclude", "include", "includelineno"
   */
  int addCommandWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * NOT INCLUDED CommandWord
   * Format: @command <word>
   * Commands with a single WORD after then such as @b
   * "copydoc", "copybrief", "copydetails", "verbinclude", "htmlinclude"
   */
  int ignoreCommandWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * CommandLine
   * Format: @command (line)
   * Commands with a single LINE after then such as @var
   * "addindex", "fn", "name", "line", "var", "skipline", "typedef", "skip", "until", "property"
   */
  int addCommandLine(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * NOT INCLUDED CommandLine
   * Format: @command (line)
   * Commands with a single LINE after then such as @var
   */
  int ignoreCommandLine(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * CommandParagraph
   * Format: @command {paragraph}
   * Commands with a single paragraph after then such as @return
   * "return", "remarks", "since", "test", "sa", "see", "pre", "post", "details", "invariant", 
   * "deprecated", "date", "note", "warning", "version", "todo", "bug", "attention", "brief", "arg", "author"
   */
  int addCommandParagraph(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * CommandParagraph
   * Format: @command {paragraph}
   * Commands with a single LINE after then such as @var
   */
  int ignoreCommandParagraph(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * Command EndCommand
   * Format: @command and ends at @endcommand
   * Commands that take in a block of text such as @code
   * "code", "dot", "msc", "f$", "f[", "f{environment}{", "htmlonly", "latexonly", "manonly", 
   * "verbatim", "xmlonly", "cond", "if", "ifnot", "link"
   * Returns 1 if success, 0 if the endcommand is never encountered.
   */
  int addCommandEndCommand(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * CommandWordParagraph
   * Format: @command <word> {paragraph}
   * Commands such as param
   * "param", "tparam", "throw", "throws", "retval", "exception"
   */
  int addCommandWordParagraph(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * CommandWordLine
   * Format: @command <word> (line)
   * Commands such as param
   * "page", "subsection", "subsubsection", "section", "paragraph", "defgroup"
   */
  int addCommandWordLine(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * Command Word Optional Word Optional Word
   * Format: @command <word> [<header-file>] [<header-name>]
   * Commands such as class
   * "category", "class", "protocol", "interface", "struct", "union"
   */
  int addCommandWordOWordOWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * Command Optional Word
   * Format: @command [<word>]
   * Commands such as dir
   * "dir", "file", "cond"
   */
  int addCommandOWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   * Commands that should not be encountered (such as PHP only)
   * goes til the end of line then returns
   */
  int addCommandErrorThrow(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /*
   *Adds the unique commands- different process for each unique command
   */
  int addCommandUnique(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList);
  /* 
   * The actual "meat" of the doxygen parser. This is not yet fully implemented
   * with my current design- however the skeletal outline is contained in
   * the file Skeleton
   */
  int addCommand(std::string commandString, TokenList & tokList, std::list < DoxygenEntity > &doxyList);

  std::list < DoxygenEntity > parse(std::list < Token >::iterator endParsingIndex, TokenList & tokList, bool root=false);
  
  /*
   * Fill static doxygenCommands and sectionIndicators containers
   */
  void fillTables();
  
  /*
   * Whether to print lots of debug info during parsing
   */
  bool noisy;
  
  /* 
   * Map of Doxygen commands to determine if a string is a
   * command and how it needs to be parsed 
   */
  static std::map<std::string, DoxyCommandEnum> doxygenCommands;
  
  static std::set<std::string> doxygenSectionIndicators;
};

#endif

