/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * DoxygenTransWTokenizer.cpp
 *
 * The main class for translating blobs of Doxygen for SWIG
 * ----------------------------------------------------------------------------- */

//TODO DOH instead of STL?
//TODO Most commands are not fully implemented

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <list>
#include "DoxygenEntity.h"
#include "TokenList.h"
#define SIMPLECOMMAND 1
#define IGNOREDSIMPLECOMMAND 2
#define COMMANDWORD 3
#define IGNOREDCOMMANDWORD 4
#define COMMANDLINE 5
#define IGNOREDCOMMANDLINE 6
#define COMMANDPARAGRAPH 7
#define IGNORECOMMANDPARAGRAPH 8
#define COMMANDENDCOMMAND 9
#define COMMANDWORDPARAGRAPH 10
#define COMMANDWORDLINE 11
#define COMMANDWORDOWORDWORD 12
#define COMMANDOWORD 13
#define COMMANDERRORTHROW 14
#define COMMANDUNIQUE 15
using namespace std;


//////////////////////////////////////////
/*Set these to pick what internal functions
to test. */

//int testCommandParsingFunctions = 1;// not implemented

int testCodeCrawlingFunctions = 0;
int demonstrateParsing = 0;
int runExamples = 0;
int noisy = 0;			// set this to 1 for extra chatter from the parsing stage.
int addCommand(string commandName, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString);
//////////////////////////////////////////



/* Globals*/


// An array of all the commands and my generic description tag, plaindescription

string commandArray[] = { "a", "addindex", "addtogroup", "anchor", "arg", "attention",
  "author", "b", "brief", "bug", "c", "callgraph", "callergraph", "category",
  "class", "code", "cond", "copybrief", "copydetails", "copydoc", "date", "def",
  "defgroup", "deprecated", "details", "dir", "dontinclude", "dot", "dotfile", "e",
  "else", "elseif", "em", "endcode", "endcond", "enddot", "endhtmlonly", "endif",
  "endlatexonly", "endlink", "endmanonly", "endmsc", "endverbatim", "endxmlonly",
  "enum", "example", "exception", "f$", "f[", "f]", "f{", "f}", "file", "fn", "headerfile",
  "hideinitializer", "htmlinclude", "htmlonly", "if", "ifnot", "image", "include",
  "includelineno", "ingroup", "internal", "invariant", "interface", "latexonly", "li",
  "line", "link", "mainpage", "manonly", "msc", "n", "name", "namespace", "nosubgrouping",
  "note", "overload", "p", "package", "page", "par", "paragraph", "param", "post", "pre",
  "private", "privatesection", "property", "protected", "protectedsection", "protocol",
  "public", "publicsection", "ref", "relates", "relatesalso", "remarks", "return", "retval",
  "sa", "section", "see", "showinitializer", "since", "skip", "skipline", "struct", "subpage",
  "subsection", "subsubsection", "test", "throw", "todo", "tparam", "typedef", "union", "until",
  "var", "verbatim", "verbinclude", "version", "warning", "weakgroup", "xmlonly", "xrefitem",
  "$", "@", "//", "&", "~", "<", ">", "#", "%"
};


string sectionIndicators[] = { "attention", "author", "brief", "bug", "cond", "date", "deprecated", "details",
  "else", "elseif", "endcond", "endif", "exception", "if", "ifnot", "invariant", "note", "par", "param",
  "tparam", "post", "pre", "remarks", "return", "retval", "sa", "see", "since", "test", "throw", "todo",
  "version", "warning", "xrefitem"
};

/* All of the doxygen commands divided up by how they are parsed */
string simpleCommands[] = { "n", "$", "@", "//", "&", "~", "<", ">", "#", "%" };
string ignoredSimpleCommands[] = { "nothing at the moment" };

string commandWords[] = { "a", "b", "c", "e", "em", "p", "def", "enum", "example", "package",
  "relates", "namespace", "relatesalso", "anchor", "dontinclude", "include", "includelineno"
};
string ignoredCommandWords[] = { "copydoc", "copybrief", "copydetails", "verbinclude", "htmlinclude" };
string commandLines[] = { "addindex", "fn", "name", "line", "var", "skipline", "typedef", "skip", "until", "property" };
string ignoreCommandLines[] = { "nothing at the moment" };

string commandParagraph[] = { "return", "remarks", "since", "test", "sa", "see", "pre", "post", "details", "invariant",
  "deprecated", "date", "note", "warning", "version", "todo", "bug", "attention", "brief", "arg", "author"
};
string ignoreCommandParagraphs[] = { "nothing at the moment" };

string commandEndCommands[] = { "code", "dot", "msc", "f$", "f[", "f{environment}{", "htmlonly", "latexonly", "manonly",
  "verbatim", "xmlonly", "cond", "if", "ifnot", "link"
};
string commandWordParagraphs[] = { "param", "tparam", "throw", "retval", "exception" };
string commandWordLines[] = { "page", "subsection", "subsubsection", "section", "paragraph", "defgroup" };
string commandWordOWordOWords[] = { "category", "class", "protocol", "interface", "struct", "union" };
string commandOWords[] = { "dir", "file", "cond" };

string commandErrorThrowings[] = { "annotatedclasslist", "classhierarchy", "define", "functionindex", "header",
  "headerfilelist", "inherit", "l", "postheader", "private", "privatesection", "protected",
  "protectedsection", "public", "publicsection", "endcode", "enddot", "endmsc", "endhtmlonly",
  "endlatexonly", "endmanonly", "endlink", "endverbatim", "endxmlonly", "f]", "f}", "endcond",
  "endif"
};

string commandUniques[] = { "xrefitem", "ingroup", "par", "headerfile", "overload", "weakgroup", "ref",
  "subpage", "dotfile", "image", "addtogroup", "li"
};

 //int startIndex = 0;
int isNewLine = 0;
int briefDescExists = 0;

 /* Entity list is the root list.
  * it is arranged this way to help documentation modules,
  * such as the javaDoc one, "sort" entities where they need to.
  */

list < DoxygenEntity > rootList;

/* General (untested) assist methods */

string StringToLower(string stringToConvert)
{
  //change each element of the string to lower case

  for (unsigned int i = 0; i < stringToConvert.length(); i++) {
    stringToConvert[i] = tolower(stringToConvert[i]);
  }
  return stringToConvert;	//return the converted string
}

int findCommand(string smallString) {

  smallString = StringToLower(smallString);
  int a;
  for (int i = 0; i < sizeof(commandArray) / sizeof(*commandArray); i++) {
    if ((a = smallString.compare(commandArray[i])) == 0) {
      return 101 + i;
    }


  }
  return -1;
}

int commandBelongs(string theCommand) {
  string smallString = StringToLower(theCommand);
  //cout << " Looking for command " << theCommand << endl;
  int i = 0;
  for (i = 0; i < sizeof(simpleCommands) / sizeof(*simpleCommands); i++) {
    if (smallString.compare(simpleCommands[i]) == 0) {
      return SIMPLECOMMAND;
    }
  }
  for (i = 0; i < sizeof(ignoredSimpleCommands) / sizeof(*ignoredSimpleCommands); i++) {
    if (smallString.compare(ignoredSimpleCommands[i]) == 0) {
      return IGNOREDSIMPLECOMMAND;
    }
  }
  for (i = 0; i < sizeof(commandWords) / sizeof(*commandWords); i++) {
    if (smallString.compare(commandWords[i]) == 0) {
      return COMMANDWORD;
    }
  }
  for (i = 0; i < sizeof(ignoredCommandWords) / sizeof(*ignoredCommandWords); i++) {
    if (smallString.compare(ignoredCommandWords[i]) == 0) {
      return IGNOREDCOMMANDWORD;
    }
  }
  for (i = 0; i < sizeof(commandLines) / sizeof(*commandLines); i++) {
    if (smallString.compare(commandLines[i]) == 0) {
      return COMMANDLINE;
    }
  }
  for (i = 0; i < sizeof(ignoreCommandLines) / sizeof(*ignoreCommandLines); i++) {
    if (smallString.compare(ignoreCommandLines[i]) == 0) {
      return IGNOREDCOMMANDLINE;
    }
  }
  for (i = 0; i < sizeof(commandParagraph) / sizeof(*commandParagraph); i++) {
    if (smallString.compare(commandParagraph[i]) == 0) {
      return COMMANDPARAGRAPH;
    }
  }
  /* IgnoreCommandParagraph */
  for (i = 0; i < sizeof(ignoreCommandParagraphs) / sizeof(*ignoreCommandParagraphs); i++) {
    if (smallString.compare(ignoreCommandParagraphs[i]) == 0) {
      return IGNORECOMMANDPARAGRAPH;
    }
  }
  for (i = 0; i < sizeof(commandEndCommands) / sizeof(*commandEndCommands); i++) {
    if (smallString.compare(commandEndCommands[i]) == 0) {
      return COMMANDENDCOMMAND;
    }
  }
  for (i = 0; i < sizeof(commandWordParagraphs) / sizeof(*commandWordParagraphs); i++) {
    if (smallString.compare(commandWordParagraphs[i]) == 0) {
      return COMMANDWORDPARAGRAPH;
    }
  }
  for (i = 0; i < sizeof(commandWordLines) / sizeof(*commandWordLines); i++) {
    if (smallString.compare(commandWordLines[i]) == 0) {
      return COMMANDWORDLINE;
    }
  }
  for (i = 0; i < sizeof(commandWordOWordOWords) / sizeof(*commandWordOWordOWords); i++) {
    if (smallString.compare(commandWordOWordOWords[i]) == 0) {
      return COMMANDWORDOWORDWORD;
    }
  }
  for (i = 0; i < sizeof(commandOWords) / sizeof(*commandOWords); i++) {
    if (smallString.compare(commandOWords[i]) == 0) {
      return COMMANDOWORD;
    }
  }
  for (i = 0; i < sizeof(commandErrorThrowings) / sizeof(*commandErrorThrowings); i++) {
    if (smallString.compare(commandErrorThrowings[i]) == 0) {
      return COMMANDERRORTHROW;
    }
  }
  for (i = 0; i < sizeof(commandUniques) / sizeof(*commandUniques); i++) {
    if (smallString.compare(commandUniques[i]) == 0) {
      return COMMANDUNIQUE;
    }
  }

  return 0;

}

 /* isSectionIndicator returns a boolean if the command is a section indicator
  * This is a helper method for finding the end of a paragraph
  * by Doxygen's terms
  */
int isSectionIndicator(string smallString) {
  smallString = StringToLower(smallString);

  for (int i = 0; i < sizeof(sectionIndicators) / sizeof(*sectionIndicators); i++) {
    if (smallString.compare(sectionIndicators[i]) == 0) {
      return 1;
    }
  }
  return 0;
}


 /* HELPER METHODS
  * To test these, change the flags at the top of this class
  */

 /* Tiny method to compartmentalise the removal of all optional comment fluff such as ///
  * or **** that often occurs before commment blobs.
  */
int clearFluff(int &startInd, string doxygenString) {
  int startIndex = startInd;
  int amountRemoved = 0;

  while (doxygenString[startIndex] == '/' || doxygenString[startIndex] == '!' || doxygenString[startIndex] == '*'
	 || doxygenString[startIndex] == '\n' || doxygenString[startIndex] == ' ' || doxygenString[startIndex] == '\t') {
    startIndex++;
    amountRemoved++;
  }
  startInd = startIndex;
  return startIndex;
}

 /* Returns the next word ON THE CURRENT LINE ONLY
  * if a new line is encountered, returns a blank string.
  * Updates the index it is given after completion.
  */

string getNextWord(int &startInd, string doxygenString) {
  int startIndex = startInd;
  string nextWord;
  while (startIndex < doxygenString.length() && (doxygenString[startIndex] == '/' || doxygenString[startIndex] == ' '
						 || doxygenString[startIndex] == '*' || doxygenString[startIndex] == '\n' || doxygenString[startIndex] == '\t'
						 || doxygenString[startIndex] == '!')) {
    if (doxygenString[startIndex] == '\n') {
      startInd = startIndex;
      return nextWord;
    }
    startIndex++;
    //cout << "Start Index" << startIndex << endl;
  }
  //cout << doxygenString[startIndex] << endl;
  int endIndex = startIndex;

  while (endIndex < doxygenString.length() && (doxygenString[endIndex] != '\n' && doxygenString[endIndex] != ' ')) {
    endIndex++;
    //cout << "End Index " << endIndex << endl;
  }
  nextWord = doxygenString.substr(startIndex, endIndex - startIndex);
  startInd = endIndex;
  //cout << "Next Word :" << nextWord << ":" << endl;
  return nextWord;
}

 /* Returns the string remaining on a line
  * and moved the index to the NEXT line
  * returns "" if nothing on the current line.
  */
string getOneLine(int &startInd, string doxygenString) {
  int startIndex = startInd;
  while (doxygenString[startIndex] == '/' || doxygenString[startIndex] == ' '
	 || doxygenString[startIndex] == '*' || doxygenString[startIndex] == '\n' || doxygenString[startIndex] == '!' || doxygenString[startIndex] == '\t') {
    if (doxygenString[startIndex] == '\n')
      return "";
    startIndex++;
  }

  int endIndex = startIndex;
  while ((endIndex != doxygenString.length()) && (doxygenString[endIndex] != '\n')) {
    endIndex++;
    //cout << doxygenString[endIndex] << "End Index: " << endIndex << endl;
  }
  string returnedLine = doxygenString.substr(startIndex, endIndex - startIndex);
  if (doxygenString[endIndex] == '\n' && (endIndex < doxygenString.length()))
    endIndex++;
  startInd = endIndex;
  return returnedLine;
}

/* Returns a properly formatted (all doxygen *, //! etc removed)
 * up til ANY command or end of paragraph is encountered. Has all the same issues as
 * getStringTilEndOfParagraph formatting wise.
 */
string getStringTilCommand(int &startInd, string doxygenString) {
  if (startInd >= doxygenString.length())
    return "";
  int startIndex = startInd;
  int endIndex = startInd;
  string description;
  /* Find the End of the description */
  int keepLooping = 1;
  int spareIndex = 0;
  int counter;
  int finalIndex;
  while (keepLooping) {
    if (endIndex >= doxygenString.length()) {
      finalIndex = endIndex;
      keepLooping = 0;
    } else if (doxygenString[endIndex] == '\n') {
      //cout << "1 ";
      counter = endIndex;
      if (keepLooping && endIndex < doxygenString.length() - 1) {
	counter++;
	//cout << "Counter :" << counter << endl;
	while (keepLooping && endIndex < doxygenString.length() && (doxygenString[counter] == ' ' ||
								    doxygenString[counter] == '*' || doxygenString[counter] == '\n'
								    || doxygenString[counter] == '/' || doxygenString[counter] == '!'
								    || doxygenString[startIndex] == '\t')) {
	  if (doxygenString[counter] == '\n') {
	    //cout << "Blank line found" << endl;
	    keepLooping = 0;
	    finalIndex = counter;
	  } else {
	    counter++;
	  }
	}

      }
      //endIndex = counter;
    } else if (doxygenString[endIndex] == '\\' || doxygenString[endIndex] == '@') {
      finalIndex = endIndex;
      keepLooping = 0;
    } else if (endIndex < doxygenString.length() - 2 && string("**/").compare(doxygenString.substr(endIndex, endIndex + 2)) == 0) {
      finalIndex = endIndex;
      //cout << "3 ";
      keepLooping = 0;
    }
    if (keepLooping) {
      //cout << "4 ";
      endIndex++;
    }
  }
  //cout << "Done with EndIndex" << endl;
  while (doxygenString[startIndex] == '!' || doxygenString[startIndex] == ' '
	 || doxygenString[startIndex] == '/' || doxygenString[startIndex] == '*' || doxygenString[startIndex] == '\t')
    startIndex++;

  for (int i = startIndex; i < endIndex; i++) {

    if (doxygenString[i] == '\n') {

      while ((doxygenString[i] == '\n' || doxygenString[startIndex] == '\t' || doxygenString[i] == ' '
	      || doxygenString[i] == '*' || doxygenString[i] == '/') && endIndex < doxygenString.length() - 1) {
	i++;
      }
      description.append(" ");
    }
    description.push_back(doxygenString[i]);
    //cout << doxygenString[i];
  }
  //if(noisy) cout << "Final Index is: " << finalIndex << endl;
  startInd = finalIndex;
  return description;
}


/* Returns a Paragraph- defined in Doxygen to be a paragraph of text
 * seperate by either a structural command or a blank line
 * This method is VERY messy currently
 */
 //TODO fix getStringTilEndOfParagraph to be more forgiving, work on ' ' characters
string getStringTilEndOfParagraph(int &startInd, string doxygenString) {
  if (startInd >= doxygenString.length())
    return "";
  int startIndex = startInd;
  int endIndex = startInd;
  string description;
  /* Find the End of the description */
  int keepLooping = 1;
  int spareIndex = 0;
  int counter;
  int finalIndex;
  while (keepLooping) {
    if (endIndex >= doxygenString.length()) {
      finalIndex = endIndex;
      keepLooping = 0;
    } else if (doxygenString[endIndex] == '\n') {
      //cout << "1 ";
      counter = endIndex;
      if (keepLooping && endIndex < doxygenString.length() - 1) {
	counter++;
	//cout << "Counter :" << counter << endl;
	while (keepLooping && endIndex < doxygenString.length() && (doxygenString[counter] == ' ' ||
								    doxygenString[counter] == '*' || doxygenString[startIndex] == '\t'
								    || doxygenString[counter] == '\n' || doxygenString[counter] == '/'
								    || doxygenString[counter] == '!')) {
	  if (doxygenString[counter] == '\n') {
	    //cout << "Blank line found" << endl;
	    keepLooping = 0;
	    finalIndex = counter;
	  } else {
	    counter++;
	  }
	}

      }
      //endIndex = counter;
    }
    //todo this fix for not immediately exciting while parsing a paragraph seems somewhat cheap
    else if (endIndex != startInd && doxygenString[endIndex] == '\\' || doxygenString[endIndex] == '@') {
      spareIndex = endIndex + 1;

      if (isSectionIndicator(getNextWord(spareIndex, doxygenString))) {
	keepLooping = 0;
	finalIndex = endIndex;
      }
    } else if (endIndex < doxygenString.length() - 1 && string("*/").compare(doxygenString.substr(endIndex, endIndex + 1)) == 0) {
      keepLooping = 0;
      finalIndex = endIndex;
    }
    if (keepLooping) {
      endIndex++;
    }
  }
  //cout << "Done with EndIndex" << endl;
  while (doxygenString[startIndex] == '!' || doxygenString[startIndex] == ' ' || doxygenString[startIndex] == '\t'
	 || doxygenString[startIndex] == '/' || doxygenString[startIndex] == '*')
    startIndex++;

  for (int i = startIndex; i < endIndex; i++) {

    if (doxygenString[i] == '\n') {

      while ((doxygenString[i] == '\n' || doxygenString[startIndex] == '\t' || doxygenString[i] == ' ' || doxygenString[startIndex] == '!'
	      || doxygenString[i] == '*' || doxygenString[i] == '/') && endIndex < doxygenString.length() - 1) {
	i++;
      }
      description.append(" ");
    }
    description.push_back(doxygenString[i]);
    //cout << doxygenString[i];
  }
  startInd = finalIndex;
  return description;
}

 /* This method is for a specific form of doxygen command
  * that begins with a \command and ends in \endcommand
  * such as \code and \endcode. The proper usage is
  * progressTilEndCommand("endcode", index)
  * currently this method does NOT process what is in between the two commands
  */
 //TODO Make progressTilCommand return a formatted string
int progressTilEndCommand(string theCommand, int &startInd, string doxygenString) {
  int endIndex = startInd;
  while (endIndex < doxygenString.length()) {
    if (doxygenString[endIndex] == '\\' || doxygenString[endIndex] == '@') {
      //cout << doxygenString.substr(endIndex + 1 , theCommand.length())<< endl;
      if (theCommand.compare(doxygenString.substr(endIndex + 1, theCommand.length())) == 0) {
	startInd = endIndex + theCommand.length() + 1;
	return 1;
      }
    }
    endIndex++;
  }
  //End command not found
  return 0;
}

 /* A specialty method for commands such as \arg that end at the end of a paragraph OR when another \arg is encountered
  */

string getStringTilAnyCommand(string theCommand, int &startInd, string doxygenString) {
  if (startInd >= doxygenString.length())
    return "";
  int startIndex = startInd;
  int endIndex = startInd;
  string description;
  /* Find the End of the description */
  int keepLooping = 1;
  int spareIndex = 0;
  int counter;
  int finalIndex;
  while (keepLooping) {
    if (endIndex >= theCommand.length()) {
      finalIndex = endIndex;
      keepLooping = 0;
    } else if (doxygenString[endIndex] == '\n') {
      //cout << "1 ";
      counter = endIndex;
      if (keepLooping && endIndex < doxygenString.length() - 1) {
	counter++;
	//cout << "Counter :" << counter << endl;
	while (keepLooping && endIndex < doxygenString.length() && (doxygenString[counter] == ' ' ||
								    doxygenString[counter] == '*' || doxygenString[counter] == '\n'
								    || doxygenString[counter] == '/' || doxygenString[counter] == '!'
								    || doxygenString[startIndex] == '\t')) {
	  if (doxygenString[counter] == '\n') {
	    //cout << "Blank line found" << endl;
	    keepLooping = 0;
	    finalIndex = counter;
	  } else {
	    counter++;
	  }
	}

      }
      //endIndex = counter;
    } else if (doxygenString[endIndex] == '\\' || doxygenString[endIndex] == '@') {
      //cout << "2 ";
      spareIndex = endIndex;
      if (endIndex + theCommand.length() < theCommand.length()
	  && theCommand.compare(doxygenString.substr(endIndex, theCommand.length())) == 0)
	keepLooping = 0;
    } else if (endIndex < doxygenString.length() - 1 && string("*/").compare(doxygenString.substr(endIndex, endIndex + 1)) == 0) {
      //cout << "3 ";
      keepLooping = 0;
    }
    if (keepLooping) {
      //cout << "4 ";
      endIndex++;
    }
  }
  //cout << "Done with EndIndex" << endl;
  while (doxygenString[startIndex] == '!' || doxygenString[startIndex] == ' '
	 || doxygenString[startIndex] == '/' || doxygenString[startIndex] == '*' || doxygenString[startIndex] == '\t')
    startIndex++;

  for (int i = startIndex; i < endIndex; i++) {

    if (doxygenString[i] == '\n') {

      while ((doxygenString[i] == '\n' || doxygenString[i] == ' ' || doxygenString[startIndex] == '\t'
	      || doxygenString[i] == '*' || doxygenString[i] == '/') && endIndex < doxygenString.length() - 1) {
	i++;
      }
      description.append(" ");
    }
    description.push_back(doxygenString[i]);
    //cout << doxygenString[i];
  }
  startInd = finalIndex;
  return description;
}


 /* prints the parse tree
  *
  */
void printTree() {

  list < DoxygenEntity >::iterator p = rootList.begin();
  while (p != rootList.end()) {
    (*p).printEntity(0);
    p++;
  }

}



list < DoxygenEntity > parse(int startInd, string doxygenString) {
  string currWord;
  int startIndex = startInd;
  int savedIndex;
  list < DoxygenEntity > aNewList;
  int endIndex = doxygenString.length();
  int currCommand;
  while (startIndex < endIndex) {
    savedIndex = startIndex;
    currWord = getNextWord(startIndex, doxygenString);
    if (noisy)
      cout << "Parsing for phrase starting in:" << currWord << endl;
    if (currWord == "") {
      if (startIndex < endIndex)
	startIndex++;
    } else if (currWord[0] == '\\' || currWord[0] == '@') {
      currWord = currWord.substr(1, currWord.length() - 1);
      currCommand = findCommand(currWord);
      if (currCommand < 0) {
	if (noisy)
	  cout << "BAD COMMAND: " << currWord << endl;
      }
      //cout << "Command: " << currWord << " " << currCommand << endl;
      else
	addCommand(currWord, startIndex, aNewList, doxygenString);
    } else {
      startIndex = savedIndex;
      addCommand(string("plainstd::string"), startIndex, aNewList, doxygenString);

    }
  }

  return aNewList;
}

 /*  Method for Adding a Simple Command
  * Format: @command
  * Plain commands, such as newline etc, they contain no other data
  *  \n \\ \@ \& \$ \# \< \> \%
  */
int addSimpleCommand(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {

  if (noisy)
    cout << "Parsing " << theCommand << endl;
  doxyList.push_back(DoxygenEntity(theCommand));
  return 1;
}

  /* NOT INCLUDED Simple Commands
   * Format: @command
   * Plain commands, such as newline etc, they contain no other data
   */
int ignoreSimpleCommand(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {

  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  return 1;
}

  /* CommandWord
   * Format: @command <word>
   * Commands with a single WORD after then such as @b
   * "a", "b", "c", "e", "em", "p", "def", "enum", "example", "package", 
   * "relates", "namespace", "relatesalso","anchor", "dontinclude", "include", "includelineno"
   */
int addCommandWord(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  string name = getNextWord(startInd, doxygenString);
  if (!name.empty()) {
    doxyList.push_back(DoxygenEntity(theCommand, name));
    return 1;
  } else
    cout << "No word followed " << theCommand << " command. Not added" << endl;
  return 0;
}

  /* NOT INCLUDED CommandWord
   * Format: @command <word>
   * Commands with a single WORD after then such as @b
   * "copydoc", "copybrief", "copydetails", "verbinclude", "htmlinclude"
   */
int ignoreCommandWord(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  string name = getNextWord(startInd, doxygenString);
  if (!name.empty()) {
    return 1;
  } else
    cout << "WARNING: No word followed " << theCommand << " command." << endl;
  return 0;
}

  /* CommandLine
   * Format: @command (line)
   * Commands with a single LINE after then such as @var
   * "addindex", "fn", "name", "line", "var", "skipline", "typedef", "skip", "until", "property"
   */
int addCommandLine(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  string line = getOneLine(startInd, doxygenString);
  if (!line.empty()) {
    int placement = 0;
    list < DoxygenEntity > aNewList;
    aNewList = parse(placement, line);
    doxyList.push_back(DoxygenEntity(theCommand, aNewList));
    return 1;
  } else
    cout << "No line followed " << theCommand << " command. Not added" << endl;
  return 0;
}

  /* NOT INCLUDED CommandLine
   * Format: @command (line)
   * Commands with a single LINE after then such as @var
   * 
   */
int ignoreCommandLine(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  string line = getOneLine(startInd, doxygenString);
  if (!line.empty()) {
    return 1;
  } else
    cout << "WARNING: No line followed " << theCommand << " command." << endl;
  return 0;
}

  /* CommandParagraph
   * Format: @command {paragraph}
   * Commands with a single paragraph after then such as @return
   * "return", "remarks", "since", "test", "sa", "see", "pre", "post", "details", "invariant", 
   * "deprecated", "date", "note", "warning", "version", "todo", "bug", "attention", "brief", "arg", "author"
   */
int addCommandParagraph(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  string restOfParagraph = getStringTilEndOfParagraph(startInd, doxygenString);
  if (!restOfParagraph.empty()) {
    int placement = 0;
    list < DoxygenEntity > aNewList;
    aNewList = parse(placement, restOfParagraph);
    doxyList.push_back(DoxygenEntity(theCommand, aNewList));
    return 1;
  } else
    cout << "No line followed " << theCommand << " command. Not added" << endl;
  return 0;
}

  /* CommandParagraph
   * Format: @command {paragraph}
   * Commands with a single LINE after then such as @var
   * 
   */
int ignoreCommandParagraph(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  string restOfParagraph = getStringTilEndOfParagraph(startInd, doxygenString);
  if (!restOfParagraph.empty()) {
    return 1;
  } else
    cout << "WARNING: No line followed " << theCommand << " command." << endl;
  return 0;
}

  /* Command EndCommand
   * Format: @command and ends at @endcommand
   * Commands that take in a block of text such as @code
   * "code", "dot", "msc", "f$", "f[", "f{environment}{", "htmlonly", "latexonly", "manonly", 
   * "verbatim", "xmlonly", "cond", "if", "ifnot", "link"
   * Returns 1 if success, 0 if the endcommand is never encountered.
   */

int ignoreCommandEndCommand(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  return progressTilEndCommand("end" + theCommand, startInd, doxygenString);

}

  /* CommandWordParagraph
   * Format: @command <word> {paragraph}
   * Commands such as param
   * "param", "tparam", "throw", "retval", "exception"
   */
int addCommandWordParagraph(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  string name = getNextWord(startInd, doxygenString);
  if (name.empty()) {
    cout << "No word followed " << theCommand << " command. Not added" << endl;
    return 0;
  }
  string restOfParagraph = getStringTilEndOfParagraph(startInd, doxygenString);
  int placement = 0;
  if (!restOfParagraph.empty()) {
    list < DoxygenEntity > aNewList;
    aNewList = parse(placement, restOfParagraph);
    aNewList.push_front(DoxygenEntity("plainstd::string", name));
    doxyList.push_back(DoxygenEntity(theCommand, aNewList));
    return 1;
  } else
    cout << "No paragraph followed " << theCommand << " command. Not added" << endl;
  return 0;
}

  /* CommandWordLine
   * Format: @command <word> (line)
   * Commands such as param
   * "page", "subsection", "subsubsection", "section", "paragraph", "defgroup"
   */
int addCommandWordLine(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  string name = getNextWord(startInd, doxygenString);
  if (name.empty()) {
    cout << "No word followed " << theCommand << " command. Not added" << endl;
    return 0;
  }
  string restOfLine = getStringTilEndOfParagraph(startInd, doxygenString);
  int placement = 0;
  if (!restOfLine.empty()) {
    list < DoxygenEntity > aNewList;
    aNewList = parse(placement, restOfLine);
    aNewList.push_front(DoxygenEntity("plainstd::string", name));
    doxyList.push_back(DoxygenEntity(theCommand, aNewList));
    return 1;
  } else
    cout << "No line followed " << theCommand << " command. Not added" << endl;
  return 0;
}

  /* Command Word Optional Word Optional Word
   * Format: @command <word> [<header-file>] [<header-name>]
   * Commands such as class
   * "category", "class", "protocol", "interface", "struct", "union"
   */
int addCommandWordOWordOWord(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  string name = getNextWord(startInd, doxygenString);
  if (name.empty()) {
    cout << "No word followed " << theCommand << " command. Not added" << endl;
    return 0;
  }
  string headerfile = getNextWord(startInd, doxygenString);
  string headername = getNextWord(startInd, doxygenString);
  list < DoxygenEntity > aNewList;
  aNewList.push_back(DoxygenEntity("plainstd::string", name));
  if (!headerfile.empty())
    aNewList.push_back(DoxygenEntity("plainstd::string", headerfile));
  if (!headername.empty())
    aNewList.push_back(DoxygenEntity("plainstd::string", headername));
  doxyList.push_back(DoxygenEntity(theCommand, aNewList));
  return 1;
}

  /* Command Optional Word
   * Format: @command [<word>]
   * Commands such as dir
   * "dir", "file", "cond"
   */
int addCommandOWord(string theCommand, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  string name = getNextWord(startInd, doxygenString);
  doxyList.push_back(DoxygenEntity(theCommand, name));
  return 1;
}

 /* The actual "meat" of the doxygen parser. This is not yet fully implemented
  * with my current design- however the skeletal outline is contained in
  * the file Skeleton
  */


int addCommand(string commandString, int &startInd, list < DoxygenEntity > &doxyList, string doxygenString) {
  string theCommand = StringToLower(commandString);
  string voidArray[] = { "" };
  /* @command */


  if (theCommand.compare("plainstd::string") == 0) {
    string nextPhrase = getStringTilCommand(startInd, doxygenString);
    if (noisy)
      cout << "Parsing plain string :" << nextPhrase << endl;
    doxyList.push_back(DoxygenEntity("plainstd::string", nextPhrase));
    return 1;
  }
  int commandNumber = commandBelongs(theCommand);
  if (commandNumber == SIMPLECOMMAND) {
    return addSimpleCommand(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == IGNOREDSIMPLECOMMAND) {
    return ignoreSimpleCommand(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDWORD) {
    return addCommandWord(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == IGNOREDCOMMANDWORD) {
    return ignoreCommandWord(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDLINE) {
    return addCommandLine(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == IGNOREDCOMMANDLINE) {
    return ignoreCommandLine(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDPARAGRAPH) {
    return addCommandParagraph(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == IGNORECOMMANDPARAGRAPH) {
    return ignoreCommandParagraph(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDENDCOMMAND) {
    return ignoreCommandEndCommand(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDWORDPARAGRAPH) {
    return addCommandWordParagraph(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDWORDLINE) {
    return addCommandWordLine(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDWORDOWORDWORD) {
    return addCommandWordOWordOWord(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDOWORD) {
    return addCommandOWord(theCommand, startInd, doxyList, doxygenString);
  }
  if (commandNumber == COMMANDERRORTHROW) {
    return 0;
  }
  if (commandNumber == COMMANDUNIQUE) {
    return 0;
  }

  return 0;
}

int weirdTest() {
  string doxygenString = "this is a test.";
  string restOfParagraph;
  int startIndex = 0;
  restOfParagraph = getStringTilEndOfParagraph(startIndex, doxygenString);
  cout << restOfParagraph << " " << startIndex << endl;

  startIndex = 0;
  restOfParagraph = getStringTilCommand(startIndex, doxygenString);
  cout << restOfParagraph << " " << startIndex << endl;
}



int doRunExamples() {
  string line;
  string filename;
  string exampleNames[] = { "Examples/Example1", "Examples/Example2", "Examples/Example3", "Examples/Example4", "Examples/Example5" };
  int placement;
  string doxygenString;
  ifstream doxCommentFile;
  for (int i = 0; i < 5; i++) {
    doxCommentFile.open(exampleNames[i].c_str());
    doxCommentFile >> doxygenString;
    while (getline(doxCommentFile, line)) {
      doxygenString += line + "\n";
    }
    doxCommentFile.close();
    placement = 0;
    cout << "---RAW CODE---" << endl << doxygenString << endl << endl;
    //clearFluff(placement, doxygenString);
    //rootList = parse(placement, doxygenString);
    TokenList tokList = TokenList(doxygenString);
    tokList.printList();
    cout << "---THE TREE---" << endl;
    printTree();
  }
  return 1;
}


 /* Returns a parse tree for a string */
int main(int argc, char *argv[]) {
  //weirdTest();
  if (testCodeCrawlingFunctions)
    testCCF();
  if (runExamples)
    doRunExamples();
  if (demonstrateParsing) {
    string doxygenString =
	"//! A normal member taking two arguments and returning an integer value.\n/*!\n \\param a an integer argument. \\param s a constant character pointer\n \\return The test results\n  \\sa Test(), ~Test(), testMeToo() and publicVar()\n */";
    //string doxygenString = " /** This is a small sentence.\n *\n@param x this is a parameter. \n \n This is a line with a @b bold letter \n * \n  @brief small @b description. \n\n * **/";
    //string doxygenString = "This is a description.";
    int placement = 0;
    clearFluff(placement, doxygenString);
    rootList = parse(placement, doxygenString);
    cout << "---THE TREE---" << endl;
    printTree();
  }
  string doxygenString2 =
      "//! A normal member taking two arguments and returning an integer value.\n/*!\n \\param a an integer argument. \\param s a constant character pointer\n\n\n\n \\return The test results\n  \\sa Test(), ~Test(), testMeToo() and publicVar()\n */";
  TokenList tokList = TokenList(doxygenString2);
  tokList.printList();
  return 1;
}
