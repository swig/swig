/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * JavaDocConverter.cpp
 * ----------------------------------------------------------------------------- */

#include "JavaDocConverter.h"
#include "DoxygenParser.h"
#include <iostream>
#define APPROX_LINE_LENGTH 64	//characters per line allowed
#define TAB_SIZE 8		//current tab size in spaces
//TODO {@link} {@linkplain} {@docRoot}, and other useful doxy commands that are not a javadoc tag

// define static escape table, it is filled in JavaDocConverter's constructor
std::map<std::string, std::string> JavaDocConverter::escapeTable;

void JavaDocConverter::fillEscapeTable() {
  if (escapeTable.size()) // fill only once
    return;
  
  escapeTable["&"] = "&amp";
  escapeTable["\'"] = "&apos";
  escapeTable["\""] = "&quot";
  escapeTable["<"] = "&lt";
  escapeTable[">"] = "&gt";
}


JavaDocConverter::JavaDocConverter() : debug(false) {
  
  fillEscapeTable();
  
  // these commands insert HTML tags
  tagHandlers["c"] = &handleTagC;
  tagHandlers["b"] = &handleTagB;
  // these commands insert just a single char, all of them need to be escaped
  tagHandlers["$"] = &handleTagChar;
  tagHandlers["@"] = &handleTagChar;
  tagHandlers["\\"] = &handleTagChar;
  tagHandlers["<"] = &handleTagChar;
  tagHandlers[">"] = &handleTagChar;
  tagHandlers["&"] = &handleTagChar;
  tagHandlers["#"] = &handleTagChar;
  tagHandlers["%"] = &handleTagChar;
  tagHandlers["~"] = &handleTagChar;
  tagHandlers["\""] = &handleTagChar;
  tagHandlers["."] = &handleTagChar;
  tagHandlers["::"] = &handleTagChar;
  // these commands are stripped out
  tagHandlers["brief"] = &handleTagStrip;
  tagHandlers["details"] = &handleTagStrip;
  tagHandlers["partofdescription"] = &handleTagStrip;
  // these commands are kept as-is, they are supported by JavaDoc
  tagHandlers["sa"] = &handleTagSeeAll;
  tagHandlers["see"] = &handleTagSame;
  tagHandlers["param"] = &handleTagSame;
  tagHandlers["return"] = &handleTagSame;
  tagHandlers["throws"] = &handleTagSame;
  tagHandlers["throw"] = &handleTagThrow;
  tagHandlers["author"] = &handleTagSame;
  tagHandlers["since"] = &handleTagSame;
  tagHandlers["version"] = &handleTagSame;
  tagHandlers["exception"] = &handleTagSame;
  tagHandlers["deprecated"] = &handleTagSame;
  // this command just prints it's contents
  // (it is internal command of swig's parser, contains plain text)
  tagHandlers["plainstd::string"] = &handleTagData;
}

std::string JavaDocConverter::formatCommand(std::string unformattedLine, int indent) {
  std::string formattedLines = "\n * ";
  int lastPosition = 0;
  int i = 0;
  int isFirstLine = 1;
  while (i != -1 && i < (int) unformattedLine.length()) {
    lastPosition = i;
    if (isFirstLine) {
      i += APPROX_LINE_LENGTH;
    } else {
      i += APPROX_LINE_LENGTH - indent * TAB_SIZE;
    }

    i = unformattedLine.find(" ", i);

    if (i > 0 && i + 1 < (int) unformattedLine.length()) {
      if (!isFirstLine)
	for (int j = 0; j < indent; j++) {
	  formattedLines.append("\t");
      } else {
	isFirstLine = 0;
      }
      formattedLines.append(unformattedLine.substr(lastPosition, i - lastPosition + 1));
      formattedLines.append("\n *");

    }
  }
  if (lastPosition < (int) unformattedLine.length()) {
    if (!isFirstLine) {
      for (int j = 0; j < indent; j++) {
	formattedLines.append("\t");
      }
    }
    formattedLines.append(unformattedLine.substr(lastPosition, unformattedLine.length() - lastPosition));
  }

  return formattedLines;
}

std::string JavaDocConverter::translateSubtree(DoxygenEntity & doxygenEntity) {
  std::string translatedComment;
  
  if (doxygenEntity.isLeaf)
    return translatedComment;
  
  std::list < DoxygenEntity >::iterator p = doxygenEntity.entityList.begin();
  while (p != doxygenEntity.entityList.end()) {
    translateEntity(*p, translatedComment);
    translateSubtree(*p);
    p++;
  }
  
  return translatedComment;
}

void JavaDocConverter::translateEntity(DoxygenEntity& tag, std::string& translatedComment) {
  // check if we have needed handler and call it
  std::map<std::string, tagHandler>::iterator it;
  it = tagHandlers.find(tag.typeOfEntity); 
  if (it!=tagHandlers.end())
    (*it).second(this, tag, translatedComment);
}

void JavaDocConverter::handleTagC(JavaDocConverter* converter, DoxygenEntity& tag, std::string& translatedComment) {
  translatedComment += "<tt>" + tag.data + "</tt>";
}
void JavaDocConverter::handleTagB(JavaDocConverter* converter, DoxygenEntity& tag, std::string& translatedComment) {
  translatedComment += "<b>" + tag.data + "</b>";
}
void JavaDocConverter::handleTagThrow(JavaDocConverter* converter, DoxygenEntity& tag, std::string& translatedComment) {
  tag.typeOfEntity = "throws";
  handleTagSame(converter, tag, translatedComment);
}
void JavaDocConverter::handleTagSeeAll(JavaDocConverter* converter, DoxygenEntity& tag, std::string& translatedComment) {
  tag.typeOfEntity = "see";
  handleTagSame(converter, tag, translatedComment);
}
void JavaDocConverter::handleTagChar(JavaDocConverter* converter, DoxygenEntity& tag, std::string& translatedComment) {
  // escape it if we can, else just print
  if (escapeTable.find(tag.typeOfEntity)!=escapeTable.end())
    translatedComment += escapeTable[tag.typeOfEntity];
  else
    translatedComment += tag.typeOfEntity;
}
void JavaDocConverter::handleTagSame(JavaDocConverter* converter, DoxygenEntity& tag, std::string& translatedComment) {
  translatedComment += converter->formatCommand(std::string("@" + tag.typeOfEntity + "\t" + converter->translateSubtree(tag)), 2);
}
void JavaDocConverter::handleTagStrip(JavaDocConverter* converter, DoxygenEntity& tag, std::string& translatedComment) {
  translatedComment += converter->formatCommand(converter->translateSubtree(tag), 0);
}
void JavaDocConverter::handleTagData(JavaDocConverter* converter, DoxygenEntity& tag, std::string& translatedComment) {
  translatedComment += tag.data + " ";
}

String *JavaDocConverter::makeDocumentation(Node *node) {

  String *documentation = getDoxygenComment(node);

  if (documentation == NULL) {
    return NULL;
  }

  std::list < DoxygenEntity > entityList = parser.createTree(Char(documentation));

  // entityList.sort(CompareDoxygenEntities()); sorting currently not used,
  // see CompareDoxygenEntities::operator() in DoxygenEntity.cpp

  if (debug) {
    std::cout << "---RESORTED LIST---" << std::endl;
    printTree(entityList);
  }

  std::string javaDocString = "/**";

  for (std::list < DoxygenEntity >::iterator entityIterator = entityList.begin(); entityIterator != entityList.end();) {
    translateEntity(*entityIterator, javaDocString);
    entityIterator++;
  }

  javaDocString += "\n */\n";

  if (debug) {
    std::cout << "\n---RESULT IN JAVADOC---" << std::endl;
    std::cout << javaDocString;
  }
  
  return NewString(javaDocString.c_str());
}
