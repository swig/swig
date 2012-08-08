/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * DoxygenParser.cpp
 * ----------------------------------------------------------------------------- */

#include "DoxygenParser.h"
#include "DoxygenCommands.h"

// Define static class members
std::map<std::string, DoxyCommandEnum> DoxygenParser::doxygenCommands;
std::set<std::string> DoxygenParser::doxygenSectionIndicators;


DoxygenParser::DoxygenParser(bool noisy) : noisy(noisy) {
	fillTables();
}

DoxygenParser::~DoxygenParser() {
}

void DoxygenParser::fillTables() {
	// run it only once
	if (doxygenCommands.size())
		return;

	// fill in tables with data from DxygenCommands.h
	for (int i = 0; i < simpleCommandsSize; i++)
		doxygenCommands[simpleCommands[i]] = SIMPLECOMMAND;
	for (int i = 0; i < commandWordsSize; i++)
		doxygenCommands[commandWords[i]] = COMMANDWORD;
	for (int i = 0; i < commandLinesSize; i++)
		doxygenCommands[commandLines[i]] = COMMANDLINE;
	for (int i = 0; i < commandParagraphSize; i++)
		doxygenCommands[commandParagraph[i]] = COMMANDPARAGRAPH;
	for (int i = 0; i < commandEndCommandsSize; i++)
		doxygenCommands[commandEndCommands[i]] = COMMANDENDCOMMAND;
	for (int i = 0; i < commandWordParagraphsSize; i++)
		doxygenCommands[commandWordParagraphs[i]] = COMMANDWORDPARAGRAPH;
	for (int i = 0; i < commandWordLinesSize; i++)
		doxygenCommands[commandWordLines[i]] = COMMANDWORDLINE;
	for (int i = 0; i < commandWordOWordOWordsSize; i++)
		doxygenCommands[commandWordOWordOWords[i]] = COMMANDWORDOWORDWORD;
	for (int i = 0; i < commandOWordsSize; i++)
		doxygenCommands[commandOWords[i]] = COMMANDOWORD;
	for (int i = 0; i < commandErrorThrowingsSize; i++)
		doxygenCommands[commandErrorThrowings[i]] = COMMANDERRORTHROW;
	for (int i = 0; i < commandUniquesSize; i++)
		doxygenCommands[commandUniques[i]] = COMMANDUNIQUE;

	// fill section indicators command set
	for (int i = 0; i < sectionIndicatorsSize; i++)
		doxygenSectionIndicators.insert(sectionIndicators[i]);
}

std::string DoxygenParser::stringToLower(std::string &stringToConvert) {
	for (unsigned int i = 0; i < stringToConvert.length(); i++) {
		stringToConvert[i] = tolower(stringToConvert[i]);
	}
	return stringToConvert;	//return the converted std::string
}

int DoxygenParser::findCommand(std::string smallString) {
	std::map<std::string, DoxyCommandEnum>::iterator it;
	smallString = stringToLower(smallString);
	// I'm not sure if we can really do so, because there are different commands
	// in doxygenCommands and original commandArray
	it = doxygenCommands.find(smallString);
	if (it != doxygenCommands.end())
		return 1;
	return -1;
}

int DoxygenParser::isSectionIndicator(std::string smallString) {
	smallString = stringToLower(smallString);
	std::set<std::string>::iterator it;
	it = doxygenSectionIndicators.find(smallString);
	if (it != doxygenSectionIndicators.end())
		return 1;
	return 0;
}

void DoxygenParser::printTree(std::list < DoxygenEntity > &rootList) {
	std::list < DoxygenEntity >::iterator p = rootList.begin();
	while (p != rootList.end()) {
		(*p).printEntity(0);
		p++;
	}
}

int DoxygenParser::commandBelongs(std::string theCommand) {
	std::string smallString = stringToLower(theCommand);
	//cout << " Looking for command " << theCommand << endl;
	std::map<std::string, DoxyCommandEnum>::iterator it;
	it = doxygenCommands.find(smallString);
	if (it!=doxygenCommands.end())
		return it->second;
	return 0;
}

std::string DoxygenParser::getNextWord(TokenList & tokList) {
	Token nextToken = tokList.peek();
	if (nextToken.tokenType == PLAINSTRING) {
		// handle quoted strings as words
		if (nextToken.tokenString[0] == '"'
				&& nextToken.tokenString[nextToken.tokenString.size() - 1] != '"') {
			string word = nextToken.tokenString + " ";
			nextToken = tokList.next();
			while (true) {
				string nextWord = getNextWord(tokList);
				if (!nextWord.size()) // maybe report unterminated string error
					return word;
				word += nextWord;
				if (word[word.size() - 1] == '"') // strip quotes
					return word.substr(1, word.size() - 2);
				word += " ";
			}
		}

		tokList.next();
		return nextToken.tokenString;
	}
	return "";
}

std::list < Token >::iterator DoxygenParser::getOneLine(TokenList & tokList) {
	std::list < Token >::iterator endOfLine = tokList.iteratorCopy();
	while (endOfLine != tokList.end()) {
		if ((*endOfLine).tokenType == END_LINE) {
			//cout << "REACHED END" << endl;
			//endOfLine++;
			return endOfLine;
		}
		endOfLine++;
	}

	return tokList.end();
}

std::string DoxygenParser::getStringTilCommand(TokenList & tokList) {
	std::string description;
	if (tokList.peek().tokenType == 0)
		return "";
	while (tokList.peek().tokenType == PLAINSTRING) {
		Token currentToken = tokList.next();
		if (currentToken.tokenType == PLAINSTRING) {
			description = description + currentToken.tokenString + " ";
		}
	}
	return description;
}

std::string DoxygenParser::getStringTilEndCommand(std::string theCommand, TokenList & tokList) {
	std::string description;
	if (tokList.peek().tokenType == 0)
		return "";
	while (tokList.current() != tokList.end()) {

		//TODO: it won't output doxygen commands, need a way to fix it
		if (tokList.peek().tokenType == PLAINSTRING)
			description += tokList.peek().tokenString + " ";
		if (tokList.peek().tokenType == END_LINE)
			description += "\n";

		if (tokList.peek().tokenString == theCommand) {
			tokList.next();
			return description;
		}

		tokList.next();
	}
	tokList.printListError(theCommand + " command expected");
	return description;
}

std::list < Token >::iterator DoxygenParser::getEndOfParagraph(TokenList & tokList) {
	std::list < Token >::iterator endOfParagraph = tokList.iteratorCopy();
	while (endOfParagraph != tokList.end()) {
		if ((*endOfParagraph).tokenType == END_LINE) {
			endOfParagraph++;
			if (endOfParagraph != tokList.end() && (*endOfParagraph).tokenType == END_LINE) {
				endOfParagraph++;
				//cout << "ENCOUNTERED END OF PARA" << endl;
				return endOfParagraph;
			}

		} else if ((*endOfParagraph).tokenType == COMMAND) {

			if (isSectionIndicator((*endOfParagraph).tokenString)) {
				return endOfParagraph;
			} else
				endOfParagraph++;

		} else if ((*endOfParagraph).tokenType == PLAINSTRING) {
			endOfParagraph++;
		} else {
			return tokList.end();
		}
	}

	return tokList.end();
}

std::list < Token >::iterator DoxygenParser::getEndOfSection(std::string theCommand, TokenList & tokList) {
	std::list < Token >::iterator endOfParagraph = tokList.iteratorCopy();
	while (endOfParagraph != tokList.end()) {
		if ((*endOfParagraph).tokenType == COMMAND) {
			if (theCommand == (*endOfParagraph).tokenString)
				return endOfParagraph;
			else
				endOfParagraph++;
		} else if ((*endOfParagraph).tokenType == PLAINSTRING) {
			endOfParagraph++;
		} else if ((*endOfParagraph).tokenType == END_LINE) {
			endOfParagraph++;
			if ((*endOfParagraph).tokenType == END_LINE) {
				endOfParagraph++;
				return endOfParagraph;
			}
		}
	}
	return tokList.end();
}

std::list < Token >::iterator DoxygenParser::getEndCommand(std::string theCommand, TokenList & tokList) {
	std::list < Token >::iterator endOfCommand = tokList.iteratorCopy();
	while (endOfCommand != tokList.end()) {
        endOfCommand++;
		if ((*endOfCommand).tokenType == COMMAND) {
			if (theCommand == (*endOfCommand).tokenString) {
				return endOfCommand;
			}
		}
	}
	//End command not found
	return tokList.end();
}

std::list < Token >::iterator DoxygenParser::getTilAnyCommand(std::string, TokenList &) {
	std::list < Token >::iterator anIterator;
	return anIterator;
}

int DoxygenParser::addSimpleCommand(std::string theCommand, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	doxyList.push_back(DoxygenEntity(theCommand));
	return 1;
}

int DoxygenParser::addCommandWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	std::string name = getNextWord(tokList);
	if (!name.empty()) {
    std::list < DoxygenEntity > aNewList;
    aNewList.push_back(DoxygenEntity("plainstd::string", name));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		return 1;
	} else
		tokList.printListError("No word followed " + theCommand + " command. Not added");
	return 0;
}

int DoxygenParser::addCommandLine(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	std::list < Token >::iterator endOfLine = getOneLine(tokList);
	std::list < DoxygenEntity > aNewList = parse(endOfLine, tokList);
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
}

int DoxygenParser::addCommandParagraph(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
	std::list < DoxygenEntity > aNewList;
	aNewList = parse(endOfParagraph, tokList);
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
}

int DoxygenParser::addCommandEndCommand(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	std::list < Token >::iterator endCommand = getEndCommand("end" + theCommand, tokList);
	if (endCommand == tokList.end()) {
	  tokList.printListError("Expected end" + theCommand);
	  return 0;
	}
	std::list < DoxygenEntity > aNewList;
	aNewList = parse(endCommand, tokList);
	tokList.next();
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
}

int DoxygenParser::addCommandWordParagraph(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	std::string name = getNextWord(tokList);
	if (name.empty()) {
		tokList.printListError("No word followed " + theCommand + " command. Not added");
		return 0;
	}
	std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
	std::list < DoxygenEntity > aNewList;
	aNewList = parse(endOfParagraph, tokList);
	aNewList.push_front(DoxygenEntity("plainstd::string", name));
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
}

int DoxygenParser::addCommandWordLine(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	std::string name = getNextWord(tokList);
	if (name.empty()) {
		tokList.printListError("No word followed " + theCommand + " command. Not added");
		return 0;
	}
	std::list < Token >::iterator endOfLine = getOneLine(tokList);
	std::list < DoxygenEntity > aNewList;
	aNewList = parse(endOfLine, tokList);
	aNewList.push_front(DoxygenEntity("plainstd::string", name));
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
	//else cout << "No line followed " << theCommand <<  " command. Not added" << endl;
}

int DoxygenParser::addCommandWordOWordOWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	std::string name = getNextWord(tokList);
	if (name.empty()) {
		tokList.printListError("No word followed " + theCommand + " command. Not added");
		return 0;
	}
	std::string headerfile = getNextWord(tokList);
	std::string headername = getNextWord(tokList);
	std::list < DoxygenEntity > aNewList;
	aNewList.push_back(DoxygenEntity("plainstd::string", name));
	if (!headerfile.empty())
		aNewList.push_back(DoxygenEntity("plainstd::string", headerfile));
	if (!headername.empty())
		aNewList.push_back(DoxygenEntity("plainstd::string", headername));
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
}

int DoxygenParser::addCommandOWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	if (noisy)
		cout << "Parsing " << theCommand << endl;
	std::string name = getNextWord(tokList);
	std::list < DoxygenEntity > aNewList;
  aNewList.push_back(DoxygenEntity("plainstd::string", name));
	doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	return 1;
}

int DoxygenParser::addCommandErrorThrow(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &) {
	tokList.printListError("Encountered: " + theCommand +
			"\nThis command should not have been encountered. Behaviour past this may be unpredictable");
	std::list < Token >::iterator endOfLine = getOneLine(tokList);
	tokList.setIterator(endOfLine);
	return 0;
}

int DoxygenParser::addCommandUnique(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
    static std::map<std::string, std::string> endCommands;
	std::list < DoxygenEntity > aNewList;
	if (theCommand == "arg" || theCommand == "li") {
		std::list < Token >::iterator endOfSection = getEndOfSection(theCommand, tokList);
		std::list < DoxygenEntity > aNewList;
		aNewList = parse(endOfSection, tokList);
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	}
	// \xrefitem <key> "(heading)" "(std::list title)" {text}
	else if (theCommand == "xrefitem") {
		if (noisy)
			cout << "Parsing " << theCommand << endl;
		std::string key = getNextWord(tokList);
		if (key.empty()) {
			tokList.printListError("No key followed " + theCommand + " command. Not added");
			return 0;
		}
		std::string heading = getNextWord(tokList);
		if (key.empty()) {
			tokList.printListError("No heading followed " + theCommand + " command. Not added");
			return 0;
		}
		std::string title = getNextWord(tokList);
		if (title.empty()) {
			tokList.printListError("No title followed " + theCommand + " command. Not added");
			return 0;
		}
		std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
		aNewList = parse(endOfParagraph, tokList);
		aNewList.push_front(DoxygenEntity("plainstd::string", title));
		aNewList.push_front(DoxygenEntity("plainstd::string", heading));
		aNewList.push_front(DoxygenEntity("plainstd::string", key));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		return 1;
	}
	// \ingroup (<groupname> [<groupname> <groupname>])
	else if (theCommand == "ingroup") {
		std::string name = getNextWord(tokList);
		aNewList.push_back(DoxygenEntity("plainstd::string", name));
		name = getNextWord(tokList);
		if (!name.empty())
			aNewList.push_back(DoxygenEntity("plainstd::string", name));
		name = getNextWord(tokList);
		if (!name.empty())
			aNewList.push_back(DoxygenEntity("plainstd::string", name));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		return 1;
	}
	// \par [(paragraph title)] { paragraph }
	else if (theCommand == "par") {
		std::list < Token >::iterator endOfLine = getOneLine(tokList);
		aNewList = parse(endOfLine, tokList);
		std::list < DoxygenEntity > aNewList2;
		std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
		aNewList2 = parse(endOfParagraph, tokList);
		aNewList.splice(aNewList.end(), aNewList2);
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		return 1;
	}
	// \headerfile <header-file> [<header-name>]
	else if (theCommand == "headerfile") {
		std::list < DoxygenEntity > aNewList;
		std::string name = getNextWord(tokList);
		aNewList.push_back(DoxygenEntity("plainstd::string", name));
		name = getNextWord(tokList);
		if (!name.empty())
			aNewList.push_back(DoxygenEntity("plainstd::string", name));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		return 1;
	}
	// \overload [(function declaration)]
	else if (theCommand == "overload") {
		std::list < Token >::iterator endOfLine = getOneLine(tokList);
		if (endOfLine != tokList.current()) {
			std::list < DoxygenEntity > aNewList;
			aNewList = parse(endOfLine, tokList);
			doxyList.push_back(DoxygenEntity(theCommand, aNewList));
		} else
			doxyList.push_back(DoxygenEntity(theCommand));
		return 1;
	}
	// \weakgroup <name> [(title)]
	else if (theCommand == "weakgroup") {
		if (noisy)
			cout << "Parsing " << theCommand << endl;
		std::string name = getNextWord(tokList);
		if (name.empty()) {
			tokList.printListError("No word followed " + theCommand + " command. Not added");
			return 0;
		}
		std::list < DoxygenEntity > aNewList;
		std::list < Token >::iterator endOfLine = getOneLine(tokList);
		if (endOfLine != tokList.current()) {
			aNewList = parse(endOfLine, tokList);
		}
		aNewList.push_front(DoxygenEntity("plainstd::string", name));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	}
	// \ref <name> ["(text)"]
	else if (theCommand == "ref") {
		if (noisy)
			cout << "Parsing " << theCommand << endl;
		std::string name = getNextWord(tokList);
		if (name.empty()) {
			tokList.printListError("No key followed " + theCommand + " command. Not added");
			return 0;
		}
		std::string text = getNextWord(tokList);
		aNewList.push_back(DoxygenEntity("plainstd::string", name));
		if (!text.empty())
			aNewList.push_back(DoxygenEntity("plainstd::string", text));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	}
	// \subpage <name> ["(text)"]
	else if (theCommand == "subpage") {
		if (noisy)
			cout << "Parsing " << theCommand << endl;
		std::string name = getNextWord(tokList);
		if (name.empty()) {
			tokList.printListError("No name followed " + theCommand + " command. Not added");
			return 0;
		}
		std::string text = getNextWord(tokList);
		aNewList.push_back(DoxygenEntity("plainstd::string", name));
		if (!text.empty())
			aNewList.push_back(DoxygenEntity("plainstd::string", text));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	}
    // \code ... \endcode
    // \verbatim ... \endverbatim
	// \dot dotcode \enddot
	// \msc msccode \endmsc
	// \f[ ... \f]
	// \f{ ... \f}
	// \f{env}{ ... \f}
	// \f$ ... \f$
    else if (theCommand == "code" || theCommand == "verbatim"
        || theCommand == "dot" || theCommand == "msc"
        || theCommand == "f[" || theCommand == "f{"
        || theCommand == "f$") {
        if (!endCommands.size()) {
          // fill in static table of end commands
          endCommands["f["] = "f]";
          endCommands["f{"] = "f}";
          endCommands["f$"] = "f$";
        }
        if (noisy)
            cout << "Parsing " << theCommand << endl;

        std::string endCommand;
        std::map <std::string, std::string>::iterator it;
        it = endCommands.find(theCommand);
        if (it != endCommands.end())
          endCommand = it->second;
        else
          endCommand = "end" + theCommand;

        std::string content = getStringTilEndCommand(endCommand, tokList);
        aNewList.push_back(DoxygenEntity("plainstd::string", content));
        doxyList.push_back(DoxygenEntity(theCommand, aNewList));
    }
	// \dotfile <file> ["caption"]
	// \mscfile <file> ["caption"]
	else if (theCommand == "dotfile" || theCommand == "mscfile") {
		if (noisy)
			cout << "Parsing " << theCommand << endl;
		std::string file = getNextWord(tokList);
		if (file.empty()) {
			tokList.printListError("No file followed " + theCommand + " command. Not added");
			return 0;
		}
		std::string caption = getNextWord(tokList);
		aNewList.push_back(DoxygenEntity("plainstd::string", file));
		if (!caption.empty())
			aNewList.push_back(DoxygenEntity("plainstd::string", caption));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	}
	// \image <format> <file> ["caption"] [<sizeindication>=<size>]
	else if (theCommand == "image") {
		if (noisy)
			cout << "Parsing " << theCommand << endl;
		std::string format = getNextWord(tokList);
		if (format.empty()) {
			tokList.printListError("No format followed " + theCommand + " command. Not added");
			return 0;
		}
		std::string file = getNextWord(tokList);
		if (file.empty()) {
			tokList.printListError("No name followed " + theCommand + " command. Not added");
			return 0;
		}
		std::string caption = getNextWord(tokList);
		std::string size = getNextWord(tokList);

		std::list < DoxygenEntity > aNewList;
		aNewList.push_back(DoxygenEntity("plainstd::string", format));
		aNewList.push_back(DoxygenEntity("plainstd::string", file));
		if (!caption.empty())
			aNewList.push_back(DoxygenEntity("plainstd::string", caption));
		if (!size.empty())
			aNewList.push_back(DoxygenEntity("plainstd::string", size));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	}
	// \addtogroup <name> [(title)]
	else if (theCommand == "addtogroup") {
		if (noisy)
			cout << "Parsing " << theCommand << endl;
		std::string name = getNextWord(tokList);
		if (name.empty()) {
			tokList.printListError("No word followed " + theCommand + " command. Not added");
			return 0;
		}
		std::list < DoxygenEntity > aNewList;
		std::list < Token >::iterator endOfLine = getOneLine(tokList);
		if (endOfLine != tokList.current()) {
			aNewList = parse(endOfLine, tokList);
		}
		aNewList.push_front(DoxygenEntity("plainstd::string", name));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	}
	// \if <cond> [\else ...] [\elseif <cond> ...] \endif
	else if (theCommand == "if" || theCommand == "ifnot" ||
					 theCommand == "else" || theCommand == "elseif") {
		if (noisy)
			cout << "Parsing " << theCommand << endl;

		std::string cond;
		bool skipEndif = false; // if true then we skip endif after parsing block of code
		bool needsCond = (theCommand == "if" || theCommand == "ifnot" || theCommand == "elseif");
		if (needsCond) {
			cond = getNextWord(tokList);
			if (cond.empty()) {
				tokList.printListError("No word followed " + theCommand + " command. Not added");
				return 0;
			}
		}

		int nestedCounter = 1;
		std::list < Token >::iterator endCommand = tokList.end();
		// go through the commands and find closing endif or else or elseif
		std::list < Token >::iterator it=tokList.iteratorCopy();
		for (; it!=tokList.end(); it++) {
			if (it->tokenType == COMMAND) {
				if (it->tokenString == "if" || it->tokenString == "ifnot")
					nestedCounter++;
				else if (it->tokenString == "endif")
					nestedCounter--;
				if (nestedCounter == 1 && (it->tokenString == "else" || it->tokenString == "elseif")) { // else found
					endCommand = it;
					break;
				}
				if (nestedCounter == 0) { // endif found
					endCommand = it;
					skipEndif = true;
					break;
				}
			}
		}

		if (endCommand == tokList.end()) {
			tokList.printListError("No corresponding endif found");
			return 0;
		}

		std::list < DoxygenEntity > aNewList;
		aNewList = parse(endCommand, tokList);
		if (skipEndif)
			tokList.next();
		if (needsCond)
			aNewList.push_front(DoxygenEntity("plainstd::string", cond));
		doxyList.push_back(DoxygenEntity(theCommand, aNewList));
	}
	return 0;
}

int DoxygenParser::addCommand(std::string commandString, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
	std::string theCommand = stringToLower(commandString);
	if (theCommand == "plainstd::string") {
		std::string nextPhrase = getStringTilCommand(tokList);
		if (noisy)
			cout << "Parsing plain std::string :" << nextPhrase << endl;
		doxyList.push_back(DoxygenEntity("plainstd::string", nextPhrase));
		return 1;
	}
	switch (commandBelongs(theCommand)) {
		case SIMPLECOMMAND:
			return addSimpleCommand(theCommand, doxyList);
		case COMMANDWORD:
			return addCommandWord(theCommand, tokList, doxyList);
		case COMMANDLINE:
			return addCommandLine(theCommand, tokList, doxyList);
		case COMMANDPARAGRAPH:
			return addCommandParagraph(theCommand, tokList, doxyList);
		case COMMANDENDCOMMAND:
			return addCommandEndCommand(theCommand, tokList, doxyList);
		case COMMANDWORDPARAGRAPH:
			return addCommandWordParagraph(theCommand, tokList, doxyList);
		case COMMANDWORDLINE:
			return addCommandWordLine(theCommand, tokList, doxyList);
		case COMMANDWORDOWORDWORD:
			return addCommandWordOWordOWord(theCommand, tokList, doxyList);
		case COMMANDOWORD:
			return addCommandOWord(theCommand, tokList, doxyList);
		case COMMANDERRORTHROW:
			return addCommandErrorThrow(theCommand, tokList, doxyList);
		case COMMANDUNIQUE:
			return addCommandUnique(theCommand, tokList, doxyList);
	}
	return 0;
}

std::list < DoxygenEntity > DoxygenParser::parse(std::list < Token >::iterator endParsingIndex, TokenList & tokList, bool root) {
	// if we are root, than any strings should be added as 'partofdescription', else as 'plainstd::string'
	std::string currPlainstringCommandType = root ? "partofdescription" : "plainstd::string";
	std::list < DoxygenEntity > aNewList;
	int currCommand;
	while (tokList.current() != endParsingIndex) {
		Token currToken = tokList.peek();
		if (noisy)
			cout << "Parsing for phrase starting in:" << currToken.toString() << endl;
		if (currToken.tokenType == END_LINE) {
		  aNewList.push_back(DoxygenEntity("plainstd::endl"));
			tokList.next();
		} else if (currToken.tokenType == COMMAND) {
			currCommand = findCommand(currToken.tokenString);
			if (currCommand < 0) {
				if (noisy)
					cout << "Unidentified Command " << currToken.tokenString << endl;
				tokList.next();
				addCommand(currPlainstringCommandType, tokList, aNewList);
			} else {
				tokList.next();
				addCommand(currToken.tokenString, tokList, aNewList);
			}
		} else if (currToken.tokenType == PLAINSTRING) {
			addCommand(currPlainstringCommandType, tokList, aNewList);
		}

		if (endParsingIndex != tokList.end() && tokList.current() == tokList.end()) {
		  // this could happen if we cant reach the original endParsingIndex
		  tokList.printListError("Unexpected end of comment encountered");
		  break;
		}
	}
	return aNewList;
}

std::list < DoxygenEntity > DoxygenParser::createTree(std::string doxygenBlob, std::string fileName, int lineNumber) {
	TokenList tokList = TokenList::tokenizeDoxygenComment(doxygenBlob, fileName, lineNumber);
	if (noisy) {
		cout << "---TOKEN LIST---" << endl;
		tokList.printList();
	}
	std::list < DoxygenEntity > rootList;
	rootList = parse(tokList.end(), tokList, true);
	if (noisy) {
		cout << "PARSED LIST" << endl;
		printTree(rootList);
	}
	return rootList;
}
