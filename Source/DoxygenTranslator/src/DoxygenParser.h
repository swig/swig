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

class DoxygenParser {
private:

    /** This class contains parts of Doxygen comment as a token. */
    class Token {
    public:
        // typedef enum {COMMAND, PLAINSTRING, END_LINE, PARAGRAPH_END} ETokenType;
        DoxyCommandEnum m_tokenType;
        std::string m_tokenString;		/* the data , such as param for @param */

        Token(DoxyCommandEnum tType, std::string tString) :
            m_tokenType(tType),
            m_tokenString(tString) {}

        std::string toString() const {

            switch (m_tokenType) {
            case END_LINE:
                return "{END OF LINE}";
            case PARAGRAPH_END:
                return "{END OF PARAGRAPH}";
            case PLAINSTRING:
                return "{PLAINSTRING :" + m_tokenString + "}";
            case COMMAND:
                return "{COMMAND : " + m_tokenString + "}";
            default:
                return "";
            }
        }
    };


    typedef std::list<Token> TokenList;
    typedef TokenList::const_iterator TokenListCIt;
    typedef TokenList::iterator TokenListIt;

    TokenList m_tokenList;
    TokenListCIt m_tokenListIt;
    std::string m_fileName;
    int m_fileLineNo;

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

  /*
   *Changes a std::string to all lower case
   */
  std::string stringToLower(const std::string &stringToConvert);

  /* 
   * Finds out if a command exists (is a possible command)
   * returns -1 if no match is found
   */
  bool findCommand(const std::string &smallString);
  /* 
   * isSectionIndicator returns a boolean if the command is a section indicator
   * This is a helper method for finding the end of a paragraph
   * by Doxygen's terms
   */
  bool isSectionIndicator(const std::string &smallString);
  /*
   * Determines how a command should be handled (what group it belongs to
   * for parsing rules
   */
  int commandBelongs(const std::string &theCommand);

  /*
   *prints the parse tree
   */
  void printTree(const std::list <DoxygenEntity> &rootList);

  /*
   * Returns the next word ON THE CURRENT LINE ONLY
   * if a new line is encountered, returns a blank std::string.
   * Updates the index it is given if success.
   */
  std::string getNextWord(const TokenList &tokList);

  /* 
   * Returns the location of the end of the line as
   * an iterator.
   */
  TokenListCIt getOneLine(const TokenList &tokList);

  /*
   * Returns a properly formatted std::string
   * up til ANY command or end of line is encountered.
   */
  std::string getStringTilCommand(const TokenList &tokList);

  /*
   * Returns a properly formatted std::string
   * up til the command specified is encountered
   */
  //TODO check that this behaves properly for formulas
  std::string getStringTilEndCommand(const std::string &theCommand,
		  	  	  	  	  	  	  	  	const TokenList &tokList);

  /*
   * Returns the end of a Paragraph as an iterator-
   * Paragraph is defined in Doxygen to be a paragraph of text
   * separated by either a structural command or a blank line
   */
  TokenListCIt getEndOfParagraph(const TokenList &tokList);

  /*
   * Returns the end of a section, defined as the first blank line OR first encounter of the same 
   * command. Example of this behaviour is \arg
   * if no end is encountered, returns the last token of the std::list.
   */
  TokenListCIt getEndOfSection(const std::string &theCommand,
		                         const TokenList &tokList);

  /*
   * This method is for returning the end of a specific form of doxygen command
   * that begins with a \command and ends in \endcommand
   * such as \code and \endcode. The proper usage is
   * progressTilEndCommand("endcode", tokenList);
   * If the end is never encountered, it returns the end of the std::list.
   */
  TokenListCIt getEndCommand(const std::string &theCommand,
		                       const TokenList &tokList);
  /*
   * A specialty method for commands such as \arg that end at the end of a paragraph OR when another \arg is encountered
  //TODO getTilAnyCommand
  TokenListCIt getTilAnyCommand(const std::string &theCommand,
                                  const TokenList &tokList);
   */

  /*
   * Method for Adding a Simple Command
   * Format: @command
   * Plain commands, such as newline etc, they contain no other data
   *  \n \\ \@ \& \$ \# \< \> \%
   */
  int addSimpleCommand(const std::string &theCommand,
		                 std::list < DoxygenEntity > &doxyList);
  /*
   * CommandWord
   * Format: @command <word>
   * Commands with a single WORD after then such as @b
   * "a", "b", "c", "e", "em", "p", "def", "enum", "example", "package", 
   * "relates", "namespace", "relatesalso","anchor", "dontinclude", "include", "includelineno"
   */
  int addCommandWord(const std::string &theCommand,
		               const TokenList &tokList,
		               std::list < DoxygenEntity > &doxyList);
  /*
   * CommandLine
   * Format: @command (line)
   * Commands with a single LINE after then such as @var
   * "addindex", "fn", "name", "line", "var", "skipline", "typedef", "skip", "until", "property"
   */
  int addCommandLine(const std::string &theCommand,
		               const TokenList &tokList,
		               std::list < DoxygenEntity > &doxyList);
  /*
   * CommandParagraph
   * Format: @command {paragraph}
   * Commands with a single paragraph after then such as @return
   * "return", "remarks", "since", "test", "sa", "see", "pre", "post", "details", "invariant", 
   * "deprecated", "date", "note", "warning", "version", "todo", "bug", "attention", "brief", "arg", "author"
   */
  int addCommandParagraph(const std::string &theCommand,
		  	  	  	  	     const TokenList &tokList,
		                     std::list < DoxygenEntity > &doxyList);
  /*
   * Command EndCommand
   * Format: @command and ends at @endcommand
   * Commands that take in a block of text such as @code
   * "code", "dot", "msc", "f$", "f[", "f{environment}{", "htmlonly", "latexonly", "manonly", 
   * "verbatim", "xmlonly", "cond", "if", "ifnot", "link"
   * Returns 1 if success, 0 if the endcommand is never encountered.
   */
  int addCommandEndCommand(const std::string &theCommand,
		                      const TokenList & tokList,
		                      std::list < DoxygenEntity > &doxyList);
  /*
   * CommandWordParagraph
   * Format: @command <word> {paragraph}
   * Commands such as param
   * "param", "tparam", "throw", "throws", "retval", "exception"
   */
  int addCommandWordParagraph(const std::string &theCommand,
		  	  	  	  	  	      const TokenList & tokList,
		  	  	  	  	  	      std::list < DoxygenEntity > &doxyList);
  /*
   * CommandWordLine
   * Format: @command <word> (line)
   * Commands such as param
   * "page", "subsection", "subsubsection", "section", "paragraph", "defgroup"
   */
  int addCommandWordLine(const std::string &theCommand,
                            const TokenList &tokList,
                            std::list < DoxygenEntity > &doxyList);
  /*
   * Command Word Optional Word Optional Word
   * Format: @command <word> [<header-file>] [<header-name>]
   * Commands such as class
   * "category", "class", "protocol", "interface", "struct", "union"
   */
  int addCommandWordOWordOWord(const std::string &theCommand, const TokenList &tokList,
                                   std::list < DoxygenEntity > &doxyList);
  /*
   * Command Optional Word
   * Format: @command [<word>]
   * Commands such as dir
   * "dir", "file", "cond"
   */
  int addCommandOWord(const std::string &theCommand,
                         const TokenList &tokList,
                         std::list < DoxygenEntity > &doxyList);
  /*
   * Commands that should not be encountered (such as PHP only)
   * goes til the end of line then returns
   */
  int addCommandErrorThrow(const std::string &theCommand,
                              const TokenList &tokList,
                              std::list < DoxygenEntity > &doxyList);
  /*
   *Adds the unique commands- different process for each unique command
   */
  int addCommandUnique(const std::string &theCommand, const TokenList &tokList, std::list < DoxygenEntity > &doxyList);
  /* 
   * The actual "meat" of the doxygen parser. Calls the correct addCommand* function
   */
  int addCommand(const std::string &commandString,
                   const TokenList &tokList,
                   std::list < DoxygenEntity > &doxyList);

  std::list < DoxygenEntity > parse(TokenListCIt endParsingIndex,
		                                const TokenList &tokList,
		                                bool root = false);
  
  /*
   * Fill static doxygenCommands and sectionIndicators containers
   */
  void fillTables();
  
  TokenList tokenizeDoxygenComment(const std::string &doxygenComment,
		                              const std::string &fileName,
		                              int fileLine);
  void printList();
  void printListError(int warningType, const std::string &message);

public:
  DoxygenParser(bool noisy = false);
  virtual ~DoxygenParser();
  std::list < DoxygenEntity > createTree(const std::string &doxygen,
		  	  	  	  	  	  	  	  	     const std::string &fileName,
		  	  	  	  	  	  	  	  	     int lineNumber);
};

#endif

