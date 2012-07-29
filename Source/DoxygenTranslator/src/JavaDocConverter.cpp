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

// define static tables, they are filled in JavaDocConverter's constructor
std::map<std::string, std::pair<JavaDocConverter::tagHandler, std::string > > JavaDocConverter::tagHandlers;

void JavaDocConverter::fillStaticTables() {
  if (tagHandlers.size()) // fill only once
    return;

  // these commands insert HTML tags
  tagHandlers["a"] = make_pair(&JavaDocConverter::handleTagHtml, "i");
  tagHandlers["arg"] = make_pair(&JavaDocConverter::handleTagHtml, "li");
  tagHandlers["b"] = make_pair(&JavaDocConverter::handleTagHtml, "b");
  tagHandlers["c"] = make_pair(&JavaDocConverter::handleTagHtml, "code");
  tagHandlers["cite"] = make_pair(&JavaDocConverter::handleTagHtml, "i");
  tagHandlers["e"] = make_pair(&JavaDocConverter::handleTagHtml, "i");
  tagHandlers["em"] = make_pair(&JavaDocConverter::handleTagHtml, "i");
  tagHandlers["li"] = make_pair(&JavaDocConverter::handleTagHtml, "li");
  tagHandlers["p"] = make_pair(&JavaDocConverter::handleTagHtml, "code");
  // these commands insert just a single char, some of them need to be escaped
  tagHandlers["$"] = make_pair(&JavaDocConverter::handleTagChar, "");
  tagHandlers["@"] = make_pair(&JavaDocConverter::handleTagChar, "");
  tagHandlers["\\"] = make_pair(&JavaDocConverter::handleTagChar, "");
  tagHandlers["<"] = make_pair(&JavaDocConverter::handleTagChar, "&lt;");
  tagHandlers[">"] = make_pair(&JavaDocConverter::handleTagChar, "&gt;");
  tagHandlers["&"] = make_pair(&JavaDocConverter::handleTagChar, "&amp;");
  tagHandlers["#"] = make_pair(&JavaDocConverter::handleTagChar, "");
  tagHandlers["%"] = make_pair(&JavaDocConverter::handleTagChar, "");
  tagHandlers["~"] = make_pair(&JavaDocConverter::handleTagChar, "");
  tagHandlers["\""] = make_pair(&JavaDocConverter::handleTagChar, "&quot;");
  tagHandlers["."] = make_pair(&JavaDocConverter::handleTagChar, "");
  tagHandlers["::"] = make_pair(&JavaDocConverter::handleTagChar, "");
  // these commands are stripped out
  tagHandlers["attention"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["brief"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["bug"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["date"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["details"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["htmlonly"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["invariant"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["latexonly"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["manonly"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["partofdescription"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["rtfonly"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["short"] = make_pair(&JavaDocConverter::handleParagraph, "");
  tagHandlers["xmlonly"] = make_pair(&JavaDocConverter::handleParagraph, "");
  // these commands are kept as-is, they are supported by JavaDoc
  tagHandlers["author"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["authors"] = make_pair(&JavaDocConverter::handleTagSame, "author");
  tagHandlers["deprecated"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["exception"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["package"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["param"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["tparam"] = make_pair(&JavaDocConverter::handleTagSame, "param");
  tagHandlers["result"] = make_pair(&JavaDocConverter::handleTagSame, "return");
  tagHandlers["return"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["returns"] = make_pair(&JavaDocConverter::handleTagSame, "return");
  tagHandlers["see"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["sa"] = make_pair(&JavaDocConverter::handleTagSame, "see");
  tagHandlers["since"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["throws"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["throw"] = make_pair(&JavaDocConverter::handleTagSame, "throws");
  tagHandlers["version"] = make_pair(&JavaDocConverter::handleTagSame, "");
  // these commands have special handlers
  tagHandlers["code"] = make_pair(&JavaDocConverter::handleTagExtended, "code");
  tagHandlers["cond"] = make_pair(&JavaDocConverter::handleTagMessage, "Conditional comment: ");
  tagHandlers["copyright"] = make_pair(&JavaDocConverter::handleTagMessage, "Copyright: ");
  tagHandlers["else"] = make_pair(&JavaDocConverter::handleTagIf, "Else: ");
  tagHandlers["elseif"] = make_pair(&JavaDocConverter::handleTagIf, "Else if: ");
  tagHandlers["endcond"] = make_pair(&JavaDocConverter::handleTagMessage, "End of conditional comment.");
  tagHandlers["if"] = make_pair(&JavaDocConverter::handleTagIf, "If: ");
  tagHandlers["ifnot"] = make_pair(&JavaDocConverter::handleTagIf, "If not: ");
  tagHandlers["image"] = make_pair(&JavaDocConverter::handleTagImage, "");
  tagHandlers["link"] = make_pair(&JavaDocConverter::handleTagExtended, "link");
  tagHandlers["note"] = make_pair(&JavaDocConverter::handleTagMessage, "Note: ");
  tagHandlers["overload"] = make_pair(&JavaDocConverter::handleTagMessage, "This is an overloaded member function, provided for"
      " convenience. It differs from the above function only in what"
      " argument(s) it accepts.");
  tagHandlers["par"] = make_pair(&JavaDocConverter::handleTagPar, "");
  tagHandlers["remark"] = make_pair(&JavaDocConverter::handleTagMessage, "Remarks: ");
  tagHandlers["remarks"] = make_pair(&JavaDocConverter::handleTagMessage, "Remarks: ");
  tagHandlers["todo"] = make_pair(&JavaDocConverter::handleTagMessage, "TODO: ");
  tagHandlers["verbatim"] = make_pair(&JavaDocConverter::handleTagExtended, "literal");
  tagHandlers["warning"] = make_pair(&JavaDocConverter::handleTagMessage, "Warning: ");
  // this command just prints it's contents
  // (it is internal command of swig's parser, contains plain text)
  tagHandlers["plainstd::string"] = make_pair(&JavaDocConverter::handlePlainString, "");
  tagHandlers["plainstd::endl"] = make_pair(&JavaDocConverter::handleNewLine, "");
  tagHandlers["n"] = make_pair(&JavaDocConverter::handleNewLine, "");
}


JavaDocConverter::JavaDocConverter(bool debugTranslator, bool debugParser)
: DoxygenTranslator(debugTranslator, debugParser) {
  fillStaticTables();
}

std::string JavaDocConverter::formatCommand(std::string unformattedLine, int indent) {
  std::string formattedLines;
  return unformattedLine;
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
  std::map<std::string, std::pair<tagHandler, std::string > >::iterator it;
  it = tagHandlers.find(tag.typeOfEntity);
  if (it!=tagHandlers.end())
    (this->*(it->second.first))(tag, translatedComment, it->second.second);
}

void JavaDocConverter::handleTagHtml(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  if (tag.entityList.size()) // do not include empty tags
    translatedComment += "<" + arg + ">" + translateSubtree(tag) + "</" + arg + ">";
}
void JavaDocConverter::handleNewLine(DoxygenEntity&, std::string& translatedComment, std::string&) {
  translatedComment += "\n * ";
}
void JavaDocConverter::handleTagChar(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  // escape it if we need to, else just print
  if (arg.size())
    translatedComment += arg;
  else
    translatedComment += tag.typeOfEntity;
  translatedComment += " ";
}
void JavaDocConverter::handleTagSame(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  if (arg.size())
    tag.typeOfEntity = arg;
  translatedComment += formatCommand(std::string("@" + tag.typeOfEntity + " " + translateSubtree(tag)), 2);
}
void JavaDocConverter::handleParagraph(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  translatedComment += formatCommand(translateSubtree(tag), 0);
}
void JavaDocConverter::handlePlainString(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  translatedComment += tag.data;
  if (tag.data.size() && tag.data[tag.data.size()-1] != ' ')
  	translatedComment += " ";
}

void JavaDocConverter::handleTagExtended(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += "{@" + arg + " ";
  handleParagraph(tag, translatedComment, dummy);
  translatedComment += "}";
}
void JavaDocConverter::handleTagIf(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += arg;
  if (tag.entityList.size()) {
    translatedComment += tag.entityList.begin()->data;
    tag.entityList.pop_front();
    translatedComment += " {" + translateSubtree(tag) + "}";
  }
}
void JavaDocConverter::handleTagMessage(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += formatCommand(arg, 0);
  handleParagraph(tag, translatedComment, dummy);
}
void JavaDocConverter::handleTagImage(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  if (tag.entityList.size() < 2)
    return;

  std::string file;
  std::string title;

  std::list <DoxygenEntity>::iterator it = tag.entityList.begin();
  if (it->data != "html")
    return;

  it++;
  file = it->data;

  it++;
  if (it != tag.entityList.end())
    title = it->data;

  translatedComment += "<img src=" + file;
  if (title.size())
    translatedComment += " alt=\"" + title +"\"";
  translatedComment += " />";
}
void JavaDocConverter::handleTagPar(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  std::string dummy;
  translatedComment += "<p";
  if (tag.entityList.size())
    translatedComment += " alt=\"" + tag.entityList.begin()->data + "\"";
  translatedComment += ">";
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
  translatedComment += "</p>";
}

String *JavaDocConverter::makeDocumentation(Node *node) {

  String *documentation = getDoxygenComment(node);

  if (documentation == NULL) {
    return NULL;
  }

  std::list < DoxygenEntity > entityList = parser.createTree(Char(documentation), Char(Getfile(documentation)), Getline(documentation));

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
