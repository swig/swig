#include "DoxygenParser.h"
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
#define  END_LINE 101
#define PARAGRAPH_END 102
#define  PLAINSTRING 103
#define  COMMAND  104
using namespace std;


DoxygenParser::DoxygenParser()
{
}

DoxygenParser::~DoxygenParser()
{
}

//////////////////////////////////////////
int noisy = 0; // set this to 1 for extra chatter from the parsing stage.
int addCommand(string currCommand, TokenList &tokList,  list <DoxygenEntity> &aNewList);
list <DoxygenEntity> parse(list<Token>::iterator endParsingIndex, TokenList &tokList);

//////////////////////////////////////////


string commandArray[] = {"a", "addindex", "addtogroup", "anchor", "arg", "attention",
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
		"$", "@", "\\","&", "~", "<", ">", "#", "%"};


string sectionIndicators[] = { "attention", "author", "brief", "bug", "cond", "date", "deprecated", "details",
		"else", "elseif", "endcond", "endif", "exception", "if", "ifnot", "invariant", "note", "par", "param",
		"tparam", "post" , "pre", "remarks", "return", "retval", "sa", "see", "since", "test", "throw", "todo",
		"version", "warning", "xrefitem" };

/* All of the doxygen commands divided up by how they are parsed */
string simpleCommands[] = {"n", "$", "@", "\\", "&", "~", "<", ">", "#", "%"};
string ignoredSimpleCommands[] = {"nothing at the moment"};
string commandWords[] = {"a", "b", "c", "e", "em", "p", "def", "enum", "example", "package", 
		"relates", "namespace", "relatesalso","anchor", "dontinclude", "include", "includelineno"};
string ignoredCommandWords[] = {"copydoc", "copybrief", "copydetails", "verbinclude", "htmlinclude"};
string commandLines[] = {"addindex", "fn", "name", "line", "var", "skipline", "typedef", "skip", "until", "property"};
string ignoreCommandLines[] = {"nothing at the moment"};
string commandParagraph[] = {"partofdescription", "return", "remarks", "since", "test", "sa", "see", "pre", "post", "details", "invariant", 
		    "deprecated", "date", "note", "warning", "version", "todo", "bug", "attention", "brief", "author"};
string ignoreCommandParagraphs[] = {"nothing at the moment"};
string commandEndCommands[] = {"code", "dot", "msc", "f$", "f[", "f{environment}{", "htmlonly", "latexonly", "manonly", 
		   "verbatim", "xmlonly", "cond", "if", "ifnot", "link"};
string commandWordParagraphs[] = {"param", "tparam", "throw", "retval", "exception"};
string commandWordLines[] = {"page", "subsection", "subsubsection", "section", "paragraph", "defgroup"};
string commandWordOWordOWords [] = {"category", "class", "protocol", "interface", "struct", "union"};
string commandOWords[] = {"dir", "file", "cond"};
string commandErrorThrowings[] = {"annotatedclasslist", "classhierarchy", "define", "functionindex", "header",
		"headerfilelist", "inherit", "l", "postheader", "private", "privatesection", "protected", 
		"protectedsection", "public", "publicsection", "endcode", "enddot", "endmsc", "endhtmlonly", 
		"endlatexonly", "endmanonly", "endlink", "endverbatim", "endxmlonly", "f]", "f}", "endcond", 
		"endif"};
string commandUniques[] = {"xrefitem", "arg", "ingroup", "par", "headerfile", "overload", "weakgroup", "ref",
		"subpage", "dotfile", "image", "addtogroup", "li"};


/* Changes a string to all lower case */
string StringToLower(string stringToConvert){
   for(unsigned int i=0;i<stringToConvert.length();i++){
	   stringToConvert[i] = tolower(stringToConvert[i]);
	   }
   return stringToConvert; //return the converted string
}

/* finds out if a command exists (is a possible command)
 * from the string array commandArray
 * returns -1 if no match is found */
int findCommand(string smallString){
	smallString = StringToLower(smallString);
	int a;
	for (int i = 0; i < sizeof(commandArray)/sizeof(*commandArray); i++){
		if( (a = smallString.compare(commandArray[i])) == 0){
			return 101 + i;
			}
		}
	return -1;
}

/* isSectionIndicator returns a boolean if the command is a section indicator
 * This is a helper method for finding the end of a paragraph
 * by Doxygen's terms
 */
int isSectionIndicator(string smallString){
	smallString = StringToLower(smallString);
	for (int i = 0; i < sizeof( sectionIndicators)/sizeof(* sectionIndicators); i++){
		if( smallString.compare( sectionIndicators[i]) == 0){
			return 1;
		}
	}
	return 0;
}

/* prints the parse tree */
void printTree( list <DoxygenEntity> &rootList){
	list<DoxygenEntity>::iterator p = rootList.begin();
	while (p != rootList.end()){
		(*p).printEntity(0);
		p++;
		}
	}

/* Determines how a command should be handled (what group it belongs to
 * for parsing rules
 */
int commandBelongs(string theCommand){
	 string smallString = StringToLower(theCommand);
	 //cout << " Looking for command " << theCommand << endl;
	 int i = 0;
	 for ( i = 0; i < sizeof(simpleCommands)/sizeof(*simpleCommands); i++){
	 	if(smallString.compare(simpleCommands[i]) == 0){return SIMPLECOMMAND;}
	 	}
	 for ( i = 0; i < sizeof(ignoredSimpleCommands)/sizeof(*ignoredSimpleCommands); i++){
	 	if(smallString.compare(ignoredSimpleCommands[i]) == 0){return IGNOREDSIMPLECOMMAND;}
	 	} 
	 for ( i = 0; i < sizeof(commandWords)/sizeof(*commandWords); i++){
	 	if(smallString.compare( commandWords[i]) == 0){return COMMANDWORD;}
	 	} 
	 for ( i = 0; i < sizeof(ignoredCommandWords)/sizeof(*ignoredCommandWords); i++){
	 	if(smallString.compare( ignoredCommandWords[i]) == 0){return IGNOREDCOMMANDWORD;}
	 	} 
	 for ( i = 0; i < sizeof(commandLines)/sizeof(*commandLines); i++){
	 	if(smallString.compare( commandLines[i]) == 0){return COMMANDLINE;}
	 	} 
	 for ( i = 0; i < sizeof(ignoreCommandLines)/sizeof(*ignoreCommandLines); i++){
	 	if(smallString.compare( ignoreCommandLines[i]) == 0){return IGNOREDCOMMANDLINE;}
	 	} 
	 for ( i = 0; i <  sizeof(commandParagraph)/sizeof(*commandParagraph); i++){
	 	if(smallString.compare( commandParagraph[i]) == 0){return COMMANDPARAGRAPH;}
	 	} 
	 for ( i = 0; i < sizeof(ignoreCommandParagraphs)/sizeof(*ignoreCommandParagraphs); i++){
	 	if(smallString.compare( ignoreCommandParagraphs[i]) == 0){return IGNORECOMMANDPARAGRAPH;}
	 	} 
	 for ( i = 0; i < sizeof(commandEndCommands)/sizeof(*commandEndCommands); i++){
	 	if(smallString.compare( commandEndCommands[i]) == 0){return COMMANDENDCOMMAND ;}
	 	} 
	 for ( i = 0; i < sizeof(commandWordParagraphs)/sizeof(*commandWordParagraphs); i++){
	 	if(smallString.compare( commandWordParagraphs[i]) == 0){return COMMANDWORDPARAGRAPH;}
	 	} 
	 for ( i = 0; i < sizeof(commandWordLines)/sizeof(*commandWordLines); i++){
	 	if(smallString.compare( commandWordLines[i]) == 0){return COMMANDWORDLINE ;}
	 	} 
	 for ( i = 0; i < sizeof(commandWordOWordOWords)/sizeof(*commandWordOWordOWords); i++){
	 	if(smallString.compare( commandWordOWordOWords[i]) == 0){return COMMANDWORDOWORDWORD;}
	 	} 
	 for ( i = 0; i < sizeof(commandOWords)/sizeof(*commandOWords); i++){
	 	if(smallString.compare( commandOWords[i]) == 0){return COMMANDOWORD;}
	 	} 
	 for ( i = 0; i < sizeof(commandErrorThrowings)/sizeof(*commandErrorThrowings); i++){
	 	if(smallString.compare( commandErrorThrowings[i]) == 0){return COMMANDERRORTHROW;}
	 	} 
	 for ( i = 0; i < sizeof(commandUniques)/sizeof(*commandUniques); i++){
	 	if(smallString.compare( commandUniques[i]) == 0){return COMMANDUNIQUE;}
	 	}
	 	return 0; 
}

/* Returns the next word ON THE CURRENT LINE ONLY
 * if a new line is encountered, returns a blank string.
 * Updates the index it is given if success.
 */
string getNextWord(TokenList &tokList){
	 Token nextToken = tokList.peek();
	 if (nextToken.tokenType == PLAINSTRING ){
		 nextToken = tokList.next();
		 return nextToken.tokenString;
	 }
	return "";
}

/* Returns the location of the end of the line as
 * an iterator.
 */
list<Token>::iterator getOneLine(TokenList &tokList){
	 list<Token>::iterator endOfLine = tokList.iteratorCopy();
	 while(endOfLine!= tokList.end()){
		 if ((* endOfLine).tokenType == END_LINE){
			 //cout << "REACHED END" << endl;
			 //endOfLine++;
			 return endOfLine;
			 }
		 //cout << (* endOfLine).toString();
		 endOfLine++;
		 }
	 
	return tokList.end();
	}

/* Returns a properly formatted string
* up til ANY command or end of line is encountered.
*/
string getStringTilCommand(TokenList &tokList){
	 string description;
	 if (tokList.peek().tokenType == 0) return "";
	 while(tokList.peek().tokenType == PLAINSTRING){
		 Token currentToken = tokList.next();
		 if(currentToken.tokenType == PLAINSTRING) {
			 description = description + currentToken.tokenString + " ";
			 }
		 }
	return description;
	}

/* Returns a properly formatted string
* up til the command specified is encountered
*/
//TODO check that this behaves properly for formulas

string getStringTilEndCommand(string theCommand, TokenList &tokList){
	 string description;
	 if (tokList.peek().tokenType == 0) return "";
	 while(tokList.peek().tokenString.compare(theCommand) != 0 ){
		 Token currentToken = tokList.next();
		 description = description + currentToken.tokenString + " ";
		 }
	return description;
	}

/* Returns the end of a Paragraph as an iterator-
* Paragraph is defined in Doxygen to be a paragraph of text
* seperate by either a structural command or a blank line
*/
list<Token>::iterator getEndOfParagraph(TokenList &tokList){
	 list<Token>::iterator endOfParagraph = tokList.iteratorCopy();
	 while(endOfParagraph != tokList.end()){
		if ((* endOfParagraph).tokenType == END_LINE){
			 endOfParagraph++;
			 if ((* endOfParagraph).tokenType == END_LINE){
				 endOfParagraph++;
				 //cout << "ENCOUNTERED END OF PARA" << endl;
				 return endOfParagraph;
				 }
			 }
		else if ((* endOfParagraph).tokenType == COMMAND){
			 if(isSectionIndicator((* endOfParagraph).tokenString)) return endOfParagraph;
			 else endOfParagraph++;
			 }
		else if((* endOfParagraph).tokenType == PLAINSTRING) {
			 endOfParagraph++;
			 }
		else return tokList.end();
		}
	 return tokList.end();
	 }

/* Returns the end of a section, defined as the first blank line OR first encounter of the same 
* command. Example of this behaviour is \arg
* if no end is encountered, returns the last token of the list.
*/
list<Token>::iterator getEndOfSection(string theCommand, TokenList &tokList){
	 list<Token>::iterator endOfParagraph = tokList.iteratorCopy();
	 while(endOfParagraph != tokList.end()){
		if ((* endOfParagraph).tokenType == COMMAND){
			 if(theCommand.compare((*endOfParagraph).tokenString) == 0) return endOfParagraph;
			 else endOfParagraph++;
			 }
		else if((* endOfParagraph).tokenType == PLAINSTRING) {
			 endOfParagraph++;
			 }
		 else if ((* endOfParagraph).tokenType == END_LINE){
			 endOfParagraph++;
			 if ((* endOfParagraph).tokenType == END_LINE){
				 endOfParagraph++;
				 return endOfParagraph;
				 }
			 }
		}
	 return tokList.end();
	 }

/* This method is for returning the end of a specific form of doxygen command
 * that begins with a \command and ends in \endcommand
 * such as \code and \endcode. The proper usage is
 * progressTilEndCommand("endcode", tokenList);
 * If the end is never encountered, it returns the end of the list.
 */
list<Token>::iterator getEndCommand(string theCommand, TokenList &tokList){
	list<Token>::iterator endOfCommand = tokList.iteratorCopy();
	while (endOfCommand!= tokList.end()){
		if ((*endOfCommand).tokenType == COMMAND){
			if (theCommand.compare((* endOfCommand).tokenString) == 0){
				return endOfCommand;
			}
			endOfCommand++;
		}
	}
	//End command not found
	return tokList.end();
}

/* A specialty method for commands such as \arg that end at the end of a paragraph OR when another \arg is encountered
 */
//TODO getTilAnyCommand
list<Token>::iterator getTilAnyCommand(string theCommand, TokenList &tokList){
	list<Token>::iterator anIterator;
	return anIterator;
	}




/*  Method for Adding a Simple Command
 * Format: @command
 * Plain commands, such as newline etc, they contain no other data
 *  \n \\ \@ \& \$ \# \< \> \%
 */
 int addSimpleCommand(string theCommand, list <DoxygenEntity> &doxyList){
		if (noisy) cout << "Parsing " << theCommand << endl;
		doxyList.push_back(DoxygenEntity(theCommand));
		return 1;
		}
 
 /* NOT INCLUDED Simple Commands
  * Format: @command
  * Plain commands, such as newline etc, they contain no other data
  */
 int ignoreSimpleCommand(string theCommand, list <DoxygenEntity> &doxyList){
		if (noisy) cout << "Not Adding " << theCommand << endl;
		return 1;
		}
 
 /* CommandWord
  * Format: @command <word>
  * Commands with a single WORD after then such as @b
  * "a", "b", "c", "e", "em", "p", "def", "enum", "example", "package", 
  * "relates", "namespace", "relatesalso","anchor", "dontinclude", "include", "includelineno"
  */
 int addCommandWord(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Parsing " << theCommand << endl;
	string name = getNextWord(tokList);
	if (!name.empty()){ 
		doxyList.push_back(DoxygenEntity(theCommand, name));
		return 1;
		}
	else cout << "No word followed " << theCommand <<  " command. Not added" << endl;
	return 0;
	}
 
 /* NOT INCLUDED CommandWord
  * Format: @command <word>
  * Commands with a single WORD after then such as @b
  * "copydoc", "copybrief", "copydetails", "verbinclude", "htmlinclude"
  */
 int ignoreCommandWord(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Not Adding " << theCommand << endl;
	string name = getNextWord(tokList);
	if (!name.empty()){ 
		return 1;
		}
	else cout << "WARNING: No word followed " << theCommand <<  " command." << endl;
	return 0;
	}
 
 /* CommandLine
  * Format: @command (line)
  * Commands with a single LINE after then such as @var
  * "addindex", "fn", "name", "line", "var", "skipline", "typedef", "skip", "until", "property"
  */
 int addCommandLine(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Parsing " << theCommand << endl;
	list<Token>::iterator endOfLine = getOneLine(tokList);
	list <DoxygenEntity> aNewList;
	aNewList =  parse(endOfLine, tokList);
	doxyList.push_back( DoxygenEntity(theCommand, aNewList));
	return 1;
	}
 
 /* NOT INCLUDED CommandLine
  * Format: @command (line)
  * Commands with a single LINE after then such as @var
  * 
  */
 int ignoreCommandLine(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Not Adding " << theCommand << endl;
	list<Token>::iterator endOfLine = getOneLine(tokList);
	tokList.setIterator(endOfLine);
	return 1;
}
 
 /* CommandParagraph
  * Format: @command {paragraph}
  * Commands with a single paragraph after then such as @return
  * "return", "remarks", "since", "test", "sa", "see", "pre", "post", "details", "invariant", 
  * "deprecated", "date", "note", "warning", "version", "todo", "bug", "attention", "brief", "arg", "author"
  */
 int addCommandParagraph(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Parsing " << theCommand << endl;
	list<Token>::iterator endOfParagraph = getEndOfParagraph(tokList);
	list <DoxygenEntity> aNewList;
	aNewList =  parse(endOfParagraph, tokList);
	doxyList.push_back( DoxygenEntity(theCommand, aNewList));
	return 1;
	}
 
 /* CommandParagraph
  * Format: @command {paragraph}
  * Commands with a single LINE after then such as @var
  * 
  */
 int ignoreCommandParagraph(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Not Adding " << theCommand << endl;
	list<Token>::iterator endOfParagraph = getEndOfParagraph(tokList);
	tokList.setIterator(endOfParagraph);
	return 1;
}
 
 /* Command EndCommand
  * Format: @command and ends at @endcommand
  * Commands that take in a block of text such as @code
  * "code", "dot", "msc", "f$", "f[", "f{environment}{", "htmlonly", "latexonly", "manonly", 
  * "verbatim", "xmlonly", "cond", "if", "ifnot", "link"
  * Returns 1 if success, 0 if the endcommand is never encountered.
  */
 int addCommandEndCommand(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	  if (noisy) cout << "Not Adding " << theCommand << endl;
	  string description = getStringTilEndCommand( "end" + theCommand, tokList);
	  doxyList.push_back(DoxygenEntity(theCommand, description));
	  return 1;
	  }
 
 /* CommandWordParagraph
  * Format: @command <word> {paragraph}
  * Commands such as param
  * "param", "tparam", "throw", "retval", "exception"
  */
 int addCommandWordParagraph(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Parsing " << theCommand << endl;
	string name = getNextWord(tokList);
	if (name.empty()){ 
		cout << "No word followed " << theCommand <<  " command. Not added" << endl;
		return 0;
		}
	list<Token>::iterator endOfParagraph = getEndOfParagraph(tokList);
	list <DoxygenEntity> aNewList;
	aNewList =  parse(endOfParagraph, tokList);
	aNewList.push_front(DoxygenEntity("plainstring", name));
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
	}
 
 /* CommandWordLine
  * Format: @command <word> (line)
  * Commands such as param
  * "page", "subsection", "subsubsection", "section", "paragraph", "defgroup"
  */
 int addCommandWordLine(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Parsing " << theCommand << endl;
	string name = getNextWord(tokList);
	if (name.empty()){ 
		cout << "No word followed " << theCommand <<  " command. Not added" << endl;
		return 0;
		}
	list<Token>::iterator endOfLine = getOneLine(tokList);
	list <DoxygenEntity> aNewList;
	aNewList =  parse(endOfLine, tokList);
	aNewList.push_front(DoxygenEntity("plainstring", name));
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
		
	//else cout << "No line followed " << theCommand <<  " command. Not added" << endl;
 }

 /* Command Word Optional Word Optional Word
  * Format: @command <word> [<header-file>] [<header-name>]
  * Commands such as class
  * "category", "class", "protocol", "interface", "struct", "union"
  */
 int addCommandWordOWordOWord(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Parsing " << theCommand << endl;
	string name = getNextWord(tokList);
	if (name.empty()){ 
			cout << "No word followed " << theCommand <<  " command. Not added" << endl;
			return 0;
			}
	string headerfile = getNextWord(tokList);
	string headername = getNextWord(tokList);
	list <DoxygenEntity> aNewList;
	aNewList.push_back(DoxygenEntity("plainstring", name));
	if (!headerfile.empty()) aNewList.push_back(DoxygenEntity("plainstring", headerfile));
	if (!headername.empty()) aNewList.push_back(DoxygenEntity("plainstring", headername));
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
	}
 
 /* Command Optional Word
  * Format: @command [<word>]
  * Commands such as dir
  * "dir", "file", "cond"
  */
 int addCommandOWord(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	if (noisy) cout << "Parsing " << theCommand << endl;
	string name = getNextWord(tokList);
	doxyList.push_back(DoxygenEntity(theCommand, name));
	return 1; 
 }

 /* Commands that should not be encountered (such as PHP only)
  * goes til the end of line then returns
  */
 int addCommandErrorThrow(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	  cout << "Encountered :" << theCommand << endl;
	  cout << "This command should not have been encountered. Behaviour past this may be unpredictable " << endl;
	  list<Token>::iterator endOfLine = getOneLine(tokList);
	  tokList.setIterator(endOfLine);
	  return 0;
 }

/* Adds the unique commands- different process for each unique command */
 int addCommandUnique(string theCommand, TokenList &tokList, list <DoxygenEntity> &doxyList){
	  list <DoxygenEntity> aNewList;
	  if (theCommand.compare("arg") == 0 || theCommand.compare("li") == 0){
			list<Token>::iterator endOfSection = getEndOfSection(theCommand, tokList);
			list <DoxygenEntity> aNewList;
			aNewList =  parse(endOfSection, tokList);
			doxyList.push_back( DoxygenEntity(theCommand, aNewList));
			}
	  // \xrefitem <key> "(heading)" "(list title)" {text}
	  else if (theCommand.compare("xrefitem") == 0){
		  //TODO Implement xrefitem
			if (noisy) cout << "Not Adding " << theCommand << endl;
			list<Token>::iterator endOfParagraph = getEndOfParagraph(tokList);
			tokList.setIterator(endOfParagraph);
		  return 1;
		  }
	  // \ingroup (<groupname> [<groupname> <groupname>])
	  else if (theCommand.compare("ingroup") == 0){
		  string name = getNextWord(tokList);
		  aNewList.push_back(DoxygenEntity("plainstring", name));
		  name = getNextWord(tokList);
		  if(!name.empty()) aNewList.push_back(DoxygenEntity("plainstring", name));
		  name = getNextWord(tokList);
		  if(!name.empty()) aNewList.push_back(DoxygenEntity("plainstring", name));
		  doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		  return 1;
		  }
	  // \par [(paragraph title)] { paragraph }
	  else if (theCommand.compare("par") == 0){
		  list<Token>::iterator endOfLine = getOneLine(tokList);
		  aNewList =  parse(endOfLine, tokList);
		  list <DoxygenEntity> aNewList2;
		  aNewList2 = parse(endOfLine, tokList);
		  aNewList.splice(aNewList.end(), aNewList2);
		  doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		  return 1; 
		  }
	  // \headerfile <header-file> [<header-name>]
	  else if (theCommand.compare("headerfile") == 0){
		  list <DoxygenEntity> aNewList;
		  string name = getNextWord(tokList);
		  aNewList.push_back(DoxygenEntity("plainstring", name));
		  name = getNextWord(tokList);
		  if(!name.empty()) aNewList.push_back(DoxygenEntity("plainstring", name));
		  doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		  return 1;
		  }
	  // \overload [(function declaration)]
	  else if (theCommand.compare("overload") == 0){
		  list<Token>::iterator endOfLine = getOneLine(tokList);
		  if (endOfLine != tokList.current()){
		    list <DoxygenEntity> aNewList;
		    aNewList =  parse(endOfLine, tokList);
		    doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		    }
		  else doxyList.push_back(DoxygenEntity(theCommand));
		  return 1;
		  }
	  // \weakgroup <name> [(title)]
	  else if (theCommand.compare("weakgroup") == 0){
		    if (noisy) cout << "Parsing " << theCommand << endl;
			string name = getNextWord(tokList);
			if (name.empty()){ 
				cout << "No word followed " << theCommand <<  " command. Not added" << endl;
				return 0;
				}
			list <DoxygenEntity> aNewList;
			list<Token>::iterator endOfLine = getOneLine(tokList);
			if (endOfLine != tokList.current()) {
				aNewList =  parse(endOfLine, tokList);
				}
			aNewList.push_front(DoxygenEntity("plainstring", name));
			doxyList.push_back(DoxygenEntity(theCommand, aNewList));
			}
	  // \ref <name> ["(text)"]
	  else if (theCommand.compare("ref") == 0){
		  //TODO Implement ref
			if (noisy) cout << "Not Adding " << theCommand << endl;
			list<Token>::iterator endOfParagraph = getEndOfParagraph(tokList);
			tokList.setIterator(endOfParagraph);
			}
	  // \subpage <name> ["(text)"]
	  else if (theCommand.compare("subpage") == 0){
		  //TODO implement subpage
			if (noisy) cout << "Not Adding " << theCommand << endl;
			list<Token>::iterator endOfParagraph = getEndOfParagraph(tokList);
			tokList.setIterator(endOfParagraph);
			}
	  // \dotfile <file> ["caption"]
	  else if (theCommand.compare("dotfile") == 0){
		  //TODO implement dotfile
			if (noisy) cout << "Not Adding " << theCommand << endl;
			list<Token>::iterator endOfParagraph = getEndOfParagraph(tokList);
			tokList.setIterator(endOfParagraph);
			}
	  // \image <format> <file> ["caption"] [<sizeindication>=<size>]
	  else if (theCommand.compare("image") == 0){
		  //todo implement image
		  } 
	  // \addtogroup <name> [(title)]
	  else if (theCommand.compare("addtogroup") == 0){
		    if (noisy) cout << "Parsing " << theCommand << endl;
			string name = getNextWord(tokList);
			if (name.empty()){ 
				cout << "No word followed " << theCommand <<  " command. Not added" << endl;
				return 0;
				}
			list <DoxygenEntity> aNewList;
			list<Token>::iterator endOfLine = getOneLine(tokList);
			if (endOfLine != tokList.current()) {
				aNewList =  parse(endOfLine, tokList);
				}
			aNewList.push_front(DoxygenEntity("plainstring", name));
			doxyList.push_back(DoxygenEntity(theCommand, aNewList));
			}
	  return 0;
	  }
 
/* The actual "meat" of the doxygen parser. This is not yet fully implemented
 * with my current design- however the skeletal outline is contained in
 * the file Skeleton
 */


int addCommand(string commandString, TokenList &tokList,list <DoxygenEntity> &doxyList){
	 string theCommand = StringToLower(commandString);
	 if (theCommand.compare("plainstring") == 0){
	 		string nextPhrase = getStringTilCommand( tokList);
	 		if (noisy) cout << "Parsing plain string :" << nextPhrase << endl;
	 		doxyList.push_back(DoxygenEntity("plainstring", nextPhrase ));
	 		return 1;
	 		}
	 int commandNumber = commandBelongs(theCommand);
	 if (commandNumber == SIMPLECOMMAND){
	 	return addSimpleCommand(theCommand, doxyList);
	 	}
	 if (commandNumber == IGNOREDSIMPLECOMMAND){
	 	return ignoreSimpleCommand(theCommand, doxyList);
	 	}
	 if (commandNumber == COMMANDWORD){
	 	return addCommandWord(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == IGNOREDCOMMANDWORD){
	 	return ignoreCommandWord(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDLINE ){
	 	return addCommandLine(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == IGNOREDCOMMANDLINE ){
	 	return ignoreCommandLine(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDPARAGRAPH){
	 	return addCommandParagraph(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == IGNORECOMMANDPARAGRAPH){
	 	return ignoreCommandParagraph(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDENDCOMMAND){
	 	return addCommandEndCommand(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDWORDPARAGRAPH){
	 	return addCommandWordParagraph(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDWORDLINE){
	 	return addCommandWordLine(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDWORDOWORDWORD){
	 	return addCommandWordOWordOWord(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDOWORD){
	 	return addCommandOWord(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDERRORTHROW){
	 	return addCommandErrorThrow(theCommand, tokList, doxyList);
	 	}
	 if (commandNumber == COMMANDUNIQUE){
		return addCommandUnique(theCommand, tokList, doxyList);
	 	}
	 	
	 return 0;
	 }

list<DoxygenEntity> parse(list<Token>::iterator endParsingIndex, TokenList &tokList){
	list <DoxygenEntity> aNewList;
	int currCommand;
	while (tokList.current() != endParsingIndex){ 
		Token currToken = tokList.peek();
		if(noisy) cout << "Parsing for phrase starting in:" << currToken.toString() << endl;
		if(currToken.tokenType == END_LINE ){
			tokList.next();
			}
		else if(currToken.tokenType == COMMAND){
			currCommand = findCommand(currToken.tokenString);
			if (currCommand < 0 ){
				if(noisy) cout << "Unidentified Command " << currToken.tokenString << endl;
				tokList.next();
				addCommand(string("plainstring"), tokList, aNewList);}
				//cout << "Command: " << currWord << " " << currCommand << endl;
			else { tokList.next();
			  addCommand(currToken.tokenString, tokList,  aNewList);
			  }
			}
		else if (currToken.tokenType == PLAINSTRING){
			addCommand(string("plainstring"), tokList, aNewList);
			}
		else break;
		}
	return aNewList;
	}

list<DoxygenEntity> parseRoot(list<Token>::iterator endParsingIndex, TokenList &tokList){
	list <DoxygenEntity> aNewList;
	int currCommand;
	while (tokList.current() != endParsingIndex){ 
		Token currToken = tokList.peek();
		if(noisy) cout << "Parsing for phrase starting in:" << currToken.toString() << endl;
		if(currToken.tokenType == END_LINE ){
			tokList.next();
			}
		else if(currToken.tokenType == COMMAND){
			currCommand = findCommand(currToken.tokenString);
			if (currCommand < 0 ){ 
				if(noisy) cout << "Unidentified Command " << currToken.tokenString << endl;
				tokList.next();
				addCommand(string("partofdescription"), tokList, aNewList);}
				//cout << "Command: " << currWord << " " << currCommand << endl;
			else { tokList.next();
			  addCommand(currToken.tokenString, tokList,  aNewList);
			  }
			}
		else if (currToken.tokenType == PLAINSTRING){
			addCommand(string("partofdescription"), tokList, aNewList);
			}
		}
	return aNewList;
	}

list<DoxygenEntity> DoxygenParser::createTree(string doxygenBlob){
	TokenList tokList = TokenList(doxygenBlob);
	if(noisy) {
		cout << "---TOKEN LIST---" << endl;
		tokList.printList();
		}
	list <DoxygenEntity> rootList;
	rootList = parseRoot( tokList.end(), tokList);
	if(noisy) {
		cout << "PARSED LIST" << endl;
		printTree(rootList);
		}
	return rootList;
}
