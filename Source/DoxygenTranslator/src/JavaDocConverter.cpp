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
#include <vector>
#include "../../Modules/swigmod.h"
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
  tagHandlers["param"] = make_pair(&JavaDocConverter::handleTagParam, "");
  tagHandlers["tparam"] = make_pair(&JavaDocConverter::handleTagParam, "");
  tagHandlers["result"] = make_pair(&JavaDocConverter::handleTagSame, "return");
  tagHandlers["return"] = make_pair(&JavaDocConverter::handleTagSame, "");
  tagHandlers["returns"] = make_pair(&JavaDocConverter::handleTagSame, "return");
  //tagHandlers["see"] = make_pair(&JavaDocConverter::handleTagSame, "");
  //tagHandlers["sa"] = make_pair(&JavaDocConverter::handleTagSame, "see");
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
  tagHandlers["link"] = make_pair(&JavaDocConverter::handleTagLink, "");
  tagHandlers["see"] = make_pair(&JavaDocConverter::handleTagSee, "");
  tagHandlers["sa"] = make_pair(&JavaDocConverter::handleTagSee, "");
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

bool JavaDocConverter::paramExists(std::string param) {
  if (GetFlag(currentNode, "feature:doxygen:nostripparams"))
    return true;
  ParmList *plist = CopyParmList(Getattr(currentNode, "parms"));
  Parm *p = NULL;
  for (p = plist; p;) {
    if (Getattr(p, "name") && Char(Getattr(p, "name")) == param)
      return true;
    /*
     * doesn't seem to work always: in some cases (especially for 'self' parameters)
     * tmap:in is present, but tmap:in:next is not and so this code skips all the parameters
     */
    //p = Getattr(p, "tmap:in") ? Getattr(p, "tmap:in:next") : nextSibling(p);
    p = nextSibling(p);
  }
  Delete(plist);
  return false;
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
  if (tag.entityList.size()) { // do not include empty tags
    std::string tagData = translateSubtree(tag);
    // wrap the thing, ignoring whitespaces
    size_t wsPos = tagData.find_last_not_of("\n\t ");
    if (wsPos != std::string::npos)
      translatedComment += "<" + arg + ">" + tagData.substr(0, wsPos + 1) + "</" + arg + ">" + tagData.substr(wsPos + 1);
    else
      translatedComment += "<" + arg + ">" + translateSubtree(tag) + "</" + arg + "> ";
  }
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
  if (tag.entityList.size()) {
    translatedComment += " alt=\"" + tag.entityList.begin()->data + "\"";
    translatedComment += ">";
    tag.entityList.pop_front();
    handleParagraph(tag, translatedComment, dummy);
  }
  translatedComment += "</p>";
}

void JavaDocConverter::handleTagParam(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  std::string dummy;
  if (!tag.entityList.size())
    return;
  if (!paramExists(tag.entityList.begin()->data))
    return;

  translatedComment += "@param ";
  translatedComment += tag.entityList.begin()->data + " ";
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
}

string JavaDocConverter::convertLink(string linkObject) {
  if (GetFlag(currentNode, "feature:doxygen:nolinktranslate"))
    return linkObject;
  // find the params in function in linkObject (if any)
  size_t lbracePos = linkObject.find('(', 0);
  size_t rbracePos = linkObject.find(')', 0);
  if (lbracePos == string::npos && rbracePos == string::npos && lbracePos >= rbracePos)
    return "";

  string paramsStr = linkObject.substr(lbracePos + 1, rbracePos - lbracePos - 1);
  // strip the params, to fill them later
  linkObject = linkObject.substr(0, lbracePos);

  // find all the params
  vector<string> params;
  size_t lastPos = 0, commaPos = 0;
  while (true) {
    commaPos = paramsStr.find(',', lastPos);
    if (commaPos == string::npos)
      commaPos = paramsStr.size();
    string param = paramsStr.substr(lastPos, commaPos - lastPos);
    // if any param type is empty, we are failed
    if (!param.size())
      return "";
    params.push_back(param);
    lastPos = commaPos + 1;
    if (lastPos >= paramsStr.size())
      break;
  }

  linkObject += "(";
  for (size_t i=0; i<params.size(); i++) {
    // translate c/c++ type string to swig's type
    // i e 'int **arr[100][10]' -> 'a(100).a(10).p.p.int'
    // also converting arrays to pointers
    string paramStr = params[i];
    String *swigType = NewString("");
    for (int j=(int)params[i].size() - 1; j>=0; j--) {
      // skip all the [...] blocks, write 'p.' for every of it
      if (paramStr[j] == ']') {
        while (j>=0 && paramStr[j] != '[')
          j--;
        // no closing brace
        if (!j)
          return "";
        Append(swigType, "p.");
        continue;
      }
      else if (paramStr[j] == '*')
        Append(swigType, "p.");
      else if (isalnum(paramStr[j])) {
        Append(swigType, paramStr.substr(0, j + 1).c_str());
        break;
      }
    }

    // make dummy param list, to lookup typemaps for it
    Parm *dummyParam = NewParm(swigType, "", 0);
    Swig_typemap_attach_parms("jstype", dummyParam, NULL);
    Language::instance()->replaceSpecialVariables(0, Getattr(dummyParam, "tmap:jstype"), dummyParam);

    //Swig_print(dummyParam, 1);
    linkObject += Char(Getattr(dummyParam, "tmap:jstype"));
    if (i != params.size() - 1)
      linkObject += ",";

    Delete(dummyParam);
    Delete(swigType);
  }
  linkObject += ")";

  return linkObject;
}

void JavaDocConverter::handleTagLink(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  std::string dummy;
  if (!tag.entityList.size())
    return;

  string linkObject = convertLink(tag.entityList.begin()->data);
  if (!linkObject.size())
    linkObject = tag.entityList.begin()->data;
  tag.entityList.pop_front();

  translatedComment += "{@link ";
  translatedComment += linkObject + " ";
  handleParagraph(tag, translatedComment, dummy);
  translatedComment += "}";
}

void JavaDocConverter::handleTagSee(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  std::string dummy;
  if (!tag.entityList.size())
    return;

  list<DoxygenEntity>::iterator it;
  for (it = tag.entityList.begin(); it!=tag.entityList.end(); it++) {
    if (it->typeOfEntity == "plainstd::endl")
      handleNewLine(*it, translatedComment, dummy);
    if (it->typeOfEntity != "plainstd::string")
      continue;
    translatedComment += "@see ";
    string linkObject = convertLink(it->data);
    if (!linkObject.size())
      linkObject = it->data;
    translatedComment += linkObject;
  }
}

String *JavaDocConverter::makeDocumentation(Node *node) {

  String *documentation = getDoxygenComment(node);

  if (documentation == NULL) {
    return NewString("");
  }

  if (GetFlag(node, "feature:doxygen:notranslate")) {
    String *comment = NewString("/**\n");
    Append(comment, documentation);
    // reformat the comment
    Replaceall(comment, "\n *", "\n");
    Replaceall(comment, "\n", "\n * ");
    Append(comment, "\n */\n");
    return comment;
  }

  std::list < DoxygenEntity > entityList = parser.createTree(Char(documentation), Char(Getfile(documentation)), Getline(documentation));

  // entityList.sort(CompareDoxygenEntities()); sorting currently not used,
  // see CompareDoxygenEntities::operator() in DoxygenEntity.cpp

  if (debug) {
    std::cout << "---RESORTED LIST---" << std::endl;
    printTree(entityList);
  }

  std::string javaDocString = "/**\n * ";

  // strip endlines at the beginning
  while (entityList.begin()->typeOfEntity == "plainstd::endl")
    entityList.pop_front();
  // and at the end
  while (entityList.rbegin()->typeOfEntity == "plainstd::endl")
    entityList.pop_back();

  // store the current node
  // (currently just to handle params)
  currentNode = node;
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
