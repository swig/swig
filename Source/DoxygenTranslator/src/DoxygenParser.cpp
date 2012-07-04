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

#include <stdio.h>

// Define static class members
std::map<std::string, DoxyCommandEnum> DoxygenParser::doxygenCommands;
std::set<std::string> DoxygenParser::doxygenSectionIndicators;


DoxygenParser::DoxygenParser() : noisy(false) {
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
  for (int i = 0; i < ignoredSimpleCommandsSize; i++)
    doxygenCommands[ignoredSimpleCommands[i]] = IGNOREDSIMPLECOMMAND;
  
  for (int i = 0; i < commandWordsSize; i++)
    doxygenCommands[commandWords[i]] = COMMANDWORD;
  for (int i = 0; i < ignoredCommandWordsSize; i++)
    doxygenCommands[ignoredCommandWords[i]] = IGNOREDCOMMANDWORD;
  
  for (int i = 0; i < commandLinesSize; i++)
    doxygenCommands[commandLines[i]] = COMMANDLINE;
  for (int i = 0; i < ignoreCommandLinesSize; i++)
    doxygenCommands[ignoreCommandLines[i]] = IGNOREDCOMMANDLINE;
  
  for (int i = 0; i < commandParagraphSize; i++)
    doxygenCommands[commandParagraph[i]] = COMMANDPARAGRAPH;
  for (int i = 0; i < ignoreCommandParagraphsSize; i++)
    doxygenCommands[ignoreCommandParagraphs[i]] = IGNORECOMMANDPARAGRAPH;
  
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

std::string DoxygenParser::StringToLower(std::string stringToConvert) {
  for (unsigned int i = 0; i < stringToConvert.length(); i++) {
    stringToConvert[i] = tolower(stringToConvert[i]);
  }
  return stringToConvert;	//return the converted std::string
}

int DoxygenParser::findCommand(std::string smallString) {
  std::map<std::string, DoxyCommandEnum>::iterator it;
  smallString = StringToLower(smallString);
  // I'm not sure if we can really do so, because there are different commands
  // in doxygenCommands and original commandArray
  it = doxygenCommands.find(smallString);
  if (it != doxygenCommands.end())
    return 1;
  return -1;
}

int DoxygenParser::isSectionIndicator(std::string smallString) {
  smallString = StringToLower(smallString);
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
  std::string smallString = StringToLower(theCommand);
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
    nextToken = tokList.next();
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
    //cout << (* endOfLine).toString();
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
  while (tokList.next().tokenString.compare(theCommand) != 0) {
    //TODO: it won't output doxygen commands, need a way to fix it
    if (tokList.peek().tokenType == PLAINSTRING)
      description += tokList.peek().tokenString + " ";
    if (tokList.peek().tokenType == END_LINE)
      description += "\n";
  }
  tokList.next(); // eat the end command itself
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
      if (theCommand.compare((*endOfParagraph).tokenString) == 0)
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
    if ((*endOfCommand).tokenType == COMMAND) {
      if (theCommand.compare((*endOfCommand).tokenString) == 0) {
	return endOfCommand;
      }
      endOfCommand++;
    }
  }
  //End command not found
  return tokList.end();
}

std::list < Token >::iterator DoxygenParser::getTilAnyCommand(std::string theCommand, TokenList & tokList) {
#pragma unused(theCommand,tokList)
  std::list < Token >::iterator anIterator;
  return anIterator;
}

int DoxygenParser::addSimpleCommand(std::string theCommand, std::list < DoxygenEntity > &doxyList) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  doxyList.push_back(DoxygenEntity(theCommand));
  return 1;
}

int DoxygenParser::ignoreSimpleCommand(std::string theCommand, std::list < DoxygenEntity > &doxyList) {
#pragma unused(doxyList)
  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  return 1;
}

int DoxygenParser::addCommandWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  std::string name = getNextWord(tokList);
  if (!name.empty()) {
    doxyList.push_back(DoxygenEntity(theCommand, name));
    return 1;
  } else
    cout << "No word followed " << theCommand << " command. Not added" << endl;
  return 0;
}

int DoxygenParser::ignoreCommandWord(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
#pragma unused(doxyList)
  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  std::string name = getNextWord(tokList);
  if (!name.empty())
    return 1;
  else
    cout << "WARNING: No word followed " << theCommand << " command." << endl;
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

int DoxygenParser::ignoreCommandLine(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
#pragma unused(doxyList)
  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  std::list < Token >::iterator endOfLine = getOneLine(tokList);
  tokList.setIterator(endOfLine);
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

int DoxygenParser::ignoreCommandParagraph(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
#pragma unused(doxyList)
  if (noisy)
    cout << "Not Adding " << theCommand << endl;
  std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
  tokList.setIterator(endOfParagraph);
  return 1;
}

int DoxygenParser::addCommandEndCommand(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  std::string description = getStringTilEndCommand("end" + theCommand, tokList);
  doxyList.push_back(DoxygenEntity(theCommand, description));
  return 1;
}

int DoxygenParser::addCommandWordParagraph(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
  if (noisy)
    cout << "Parsing " << theCommand << endl;
  std::string name = getNextWord(tokList);
  if (name.empty()) {
    cout << "No word followed " << theCommand << " command. Not added" << endl;
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
    cout << "No word followed " << theCommand << " command. Not added" << endl;
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
    cout << "No word followed " << theCommand << " command. Not added" << endl;
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
  doxyList.push_back(DoxygenEntity(theCommand, name));
  return 1;
}

int DoxygenParser::addCommandErrorThrow(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
#pragma unused(doxyList)
  if (noisy) {
    cout << "Encountered :" << theCommand << endl;
    cout << "This command should not have been encountered. Behaviour past this may be unpredictable " << endl;
  }
  std::list < Token >::iterator endOfLine = getOneLine(tokList);
  tokList.setIterator(endOfLine);
  return 0;
}

int DoxygenParser::addCommandUnique(std::string theCommand, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
  std::list < DoxygenEntity > aNewList;
  if (theCommand.compare("arg") == 0 || theCommand.compare("li") == 0) {
    std::list < Token >::iterator endOfSection = getEndOfSection(theCommand, tokList);
    std::list < DoxygenEntity > aNewList;
    aNewList = parse(endOfSection, tokList);
    doxyList.push_back(DoxygenEntity(theCommand, aNewList));
  }
  // \xrefitem <key> "(heading)" "(std::list title)" {text}
  else if (theCommand.compare("xrefitem") == 0) {
    //TODO Implement xrefitem
    if (noisy)
      cout << "Not Adding " << theCommand << endl;
    std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
    tokList.setIterator(endOfParagraph);
    return 1;
  }
  // \ingroup (<groupname> [<groupname> <groupname>])
  else if (theCommand.compare("ingroup") == 0) {
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
  else if (theCommand.compare("par") == 0) {
    std::list < Token >::iterator endOfLine = getOneLine(tokList);
    aNewList = parse(endOfLine, tokList);
    std::list < DoxygenEntity > aNewList2;
    aNewList2 = parse(endOfLine, tokList);
    aNewList.splice(aNewList.end(), aNewList2);
    doxyList.push_back(DoxygenEntity(theCommand, aNewList));
    return 1;
  }
  // \headerfile <header-file> [<header-name>]
  else if (theCommand.compare("headerfile") == 0) {
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
  else if (theCommand.compare("overload") == 0) {
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
  else if (theCommand.compare("weakgroup") == 0) {
    if (noisy)
      cout << "Parsing " << theCommand << endl;
    std::string name = getNextWord(tokList);
    if (name.empty()) {
      cout << "No word followed " << theCommand << " command. Not added" << endl;
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
  else if (theCommand.compare("ref") == 0) {
    //TODO Implement ref
    if (noisy)
      cout << "Not Adding " << theCommand << endl;
    std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
    tokList.setIterator(endOfParagraph);
  }
  // \subpage <name> ["(text)"]
  else if (theCommand.compare("subpage") == 0) {
    //TODO implement subpage
    if (noisy)
      cout << "Not Adding " << theCommand << endl;
    std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
    tokList.setIterator(endOfParagraph);
  }
  // \dotfile <file> ["caption"]
  else if (theCommand.compare("dotfile") == 0) {
    //TODO implement dotfile
    if (noisy)
      cout << "Not Adding " << theCommand << endl;
    std::list < Token >::iterator endOfParagraph = getEndOfParagraph(tokList);
    tokList.setIterator(endOfParagraph);
  }
  // \image <format> <file> ["caption"] [<sizeindication>=<size>]
  else if (theCommand.compare("image") == 0) {
    //todo implement image
  }
  // \addtogroup <name> [(title)]
  else if (theCommand.compare("addtogroup") == 0) {
    if (noisy)
      cout << "Parsing " << theCommand << endl;
    std::string name = getNextWord(tokList);
    if (name.empty()) {
      cout << "No word followed " << theCommand << " command. Not added" << endl;
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
  return 0;
}

int DoxygenParser::addCommand(std::string commandString, TokenList & tokList, std::list < DoxygenEntity > &doxyList) {
  std::string theCommand = StringToLower(commandString);
  if (theCommand.compare("plainstd::string") == 0) {
    std::string nextPhrase = getStringTilCommand(tokList);
    if (noisy)
      cout << "Parsing plain std::string :" << nextPhrase << endl;
    doxyList.push_back(DoxygenEntity("plainstd::string", nextPhrase));
    return 1;
  }
  int commandNumber = commandBelongs(theCommand);
  if (commandNumber == SIMPLECOMMAND) {
    return addSimpleCommand(theCommand, doxyList);
  }
  if (commandNumber == IGNOREDSIMPLECOMMAND) {
    return ignoreSimpleCommand(theCommand, doxyList);
  }
  if (commandNumber == COMMANDWORD) {
    return addCommandWord(theCommand, tokList, doxyList);
  }
  if (commandNumber == IGNOREDCOMMANDWORD) {
    return ignoreCommandWord(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDLINE) {
    return addCommandLine(theCommand, tokList, doxyList);
  }
  if (commandNumber == IGNOREDCOMMANDLINE) {
    return ignoreCommandLine(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDPARAGRAPH) {
    return addCommandParagraph(theCommand, tokList, doxyList);
  }
  if (commandNumber == IGNORECOMMANDPARAGRAPH) {
    return ignoreCommandParagraph(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDENDCOMMAND) {
    return addCommandEndCommand(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDWORDPARAGRAPH) {
    return addCommandWordParagraph(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDWORDLINE) {
    return addCommandWordLine(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDWORDOWORDWORD) {
    return addCommandWordOWordOWord(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDOWORD) {
    return addCommandOWord(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDERRORTHROW) {
    return addCommandErrorThrow(theCommand, tokList, doxyList);
  }
  if (commandNumber == COMMANDUNIQUE) {
    return addCommandUnique(theCommand, tokList, doxyList);
  }

  return 0;
}

std::list < DoxygenEntity > DoxygenParser::parse(std::list < Token >::iterator endParsingIndex, TokenList & tokList) {
  std::list < DoxygenEntity > aNewList;
  int currCommand;
  while (tokList.current() != endParsingIndex) {
    Token currToken = tokList.peek();
    if (noisy)
      cout << "Parsing for phrase starting in:" << currToken.toString() << endl;
    if (currToken.tokenType == END_LINE) {
      tokList.next();
    } else if (currToken.tokenType == COMMAND) {
      currCommand = findCommand(currToken.tokenString);
      if (currCommand < 0) {
	if (noisy)
	  cout << "Unidentified Command " << currToken.tokenString << endl;
	tokList.next();
	addCommand(std::string("plainstd::string"), tokList, aNewList);
      } else {
	tokList.next();
	addCommand(currToken.tokenString, tokList, aNewList);
      }
    } else if (currToken.tokenType == PLAINSTRING) {
      addCommand(std::string("plainstd::string"), tokList, aNewList);
    }
    break;
  }
  return aNewList;
}

std::list < DoxygenEntity > DoxygenParser::parseRoot(std::list < Token >::iterator endParsingIndex, TokenList & tokList) {

  std::list < DoxygenEntity > aNewList;
  int currCommand;

  while (tokList.current() != endParsingIndex) {

    Token currToken = tokList.peek();
    if (noisy) {
      cout << "Parsing for phrase starting in:" << currToken.toString() << endl;
    }

    if (currToken.tokenType == END_LINE) {
      tokList.next();
    } else if (currToken.tokenType == COMMAND) {
      currCommand = findCommand(currToken.tokenString);
      if (currCommand < 0) {
	if (noisy) {
	  cout << "Unidentified Command " << currToken.tokenString << endl;
	}
	tokList.next();
	addCommand(std::string("partofdescription"), tokList, aNewList);
      } else {
	tokList.next();
	addCommand(currToken.tokenString, tokList, aNewList);
      }
    } else if (currToken.tokenType == PLAINSTRING) {
      addCommand(std::string("partofdescription"), tokList, aNewList);
    }
  }
  return aNewList;
}

std::list < DoxygenEntity > DoxygenParser::createTree(std::string doxygenBlob) {
  TokenList tokList = TokenList(doxygenBlob);
  if (noisy) {
    cout << "---TOKEN LIST---" << endl;
    tokList.printList();
  }
  std::list < DoxygenEntity > rootList;
  rootList = parseRoot(tokList.end(), tokList);
  if (noisy) {
    cout << "PARSED LIST" << endl;
    printTree(rootList);
  }
  return rootList;
}
