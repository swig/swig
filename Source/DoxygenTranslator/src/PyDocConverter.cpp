/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * PyDocConverter.cpp
 *
 * Module to return documentation for nodes formatted for PyDoc
 * ----------------------------------------------------------------------------- */

#include "PyDocConverter.h"
#include "DoxygenParser.h"
#include <sstream>
#include <vector>
#include <iostream>

// define static tables, they are filled in PyDocConverter's constructor
std::map<std::string, std::pair<PyDocConverter::tagHandler, std::string > > PyDocConverter::tagHandlers;
std::map<std::string, std::string> PyDocConverter::sectionTitles;

void PyDocConverter::fillStaticTables() {
  if (tagHandlers.size()) // fill only once
    return;

  // table of section titles, they are printed only once
  // for each group of specified doxygen commands
  sectionTitles["author"] = "Authors:";
  sectionTitles["authors"] = "Authors:";
  sectionTitles["copyright"] = "Copyright:";
  sectionTitles["deprecated"] = "Deprecated:";
  sectionTitles["example"] = "Example:";
  sectionTitles["exception"] = "Throws:";
  sectionTitles["param"] = "Arguments:";
  sectionTitles["tparam"] = "Arguments:";
  sectionTitles["note"] = "Notes:";
  sectionTitles["remark"] = "Remarks:";
  sectionTitles["remarks"] = "Remarks:";
  sectionTitles["warning"] = "Warning:";
  sectionTitles["result"] = "Return:";
  sectionTitles["return"] = "Return:";
  sectionTitles["returns"] = "Return:";
  sectionTitles["sa"] = "See also:";
  sectionTitles["see"] = "See also:";
  sectionTitles["since"] = "Since:";
  sectionTitles["throw"] = "Throws:";
  sectionTitles["throws"] = "Throws:";
  sectionTitles["todo"] = "TODO:";
  sectionTitles["version"] = "Version:";

  // these commands insert HTML tags
  tagHandlers["a"] = make_pair(&PyDocConverter::handleTagWrap, "_");
  tagHandlers["b"] = make_pair(&PyDocConverter::handleTagWrap, "__");
  tagHandlers["cite"] = make_pair(&PyDocConverter::handleTagWrap, "'");
  tagHandlers["e"] = make_pair(&PyDocConverter::handleTagWrap, "_");
  // these commands insert just a single char, some of them need to be escaped
  tagHandlers["$"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["@"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["\\"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["<"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers[">"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["&"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["#"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["%"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["~"] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["\""] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["."] = make_pair(&PyDocConverter::handleTagChar, "");
  tagHandlers["::"] = make_pair(&PyDocConverter::handleTagChar, "");
  // these commands have special handlers
  tagHandlers["arg"] = make_pair(&PyDocConverter::handleTagMessage, " -");
  tagHandlers["cond"] = make_pair(&PyDocConverter::handleTagMessage, "Conditional comment: ");
  tagHandlers["else"] = make_pair(&PyDocConverter::handleTagIf, "Else: ");
  tagHandlers["elseif"] = make_pair(&PyDocConverter::handleTagIf, "Else if: ");
  tagHandlers["endcond"] = make_pair(&PyDocConverter::handleTagMessage, "End of conditional comment.");
  tagHandlers["if"] = make_pair(&PyDocConverter::handleTagIf, "If: ");
  tagHandlers["ifnot"] = make_pair(&PyDocConverter::handleTagIf, "If not: ");
  tagHandlers["image"] = make_pair(&PyDocConverter::handleTagMessage, "Image: ");
  tagHandlers["li"] = make_pair(&PyDocConverter::handleTagMessage, " -");
  tagHandlers["overload"] = make_pair(&PyDocConverter::handleTagMessage, "This is an overloaded member function, provided for"
      " convenience.\nIt differs from the above function only in what"
      " argument(s) it accepts.");
  tagHandlers["par"] = make_pair(&PyDocConverter::handleTagPar, "");
  tagHandlers["param"] = make_pair(&PyDocConverter::handleTagParam, "");
  tagHandlers["tparam"] = make_pair(&PyDocConverter::handleTagParam, "");
  // this command just prints it's contents
  // (it is internal command of swig's parser, contains plain text)
  tagHandlers["plainstd::string"] = make_pair(&PyDocConverter::handlePlainString, "");
  tagHandlers["plainstd::endl"] = make_pair(&PyDocConverter::handleNewLine, "");
  tagHandlers["n"] = make_pair(&PyDocConverter::handleNewLine, "");
}

PyDocConverter::PyDocConverter(bool debugTranslator, bool debugParser)
: DoxygenTranslator(debugTranslator, debugParser) {
  fillStaticTables();
}

std::string PyDocConverter::getParamType(std::string param) {
  ParmList *plist = CopyParmList(Getattr(currentNode, "parms"));
  Parm *p = NULL;
  for (p = plist; p;) {
    if (Char(Getattr(p, "name")) == param) {
      std::string type = Char(SwigType_str(Getattr(p, "type"), ""));
      return type;
    }
    /*
     * doesn't seem to work always: in some cases (especially for 'self' parameters)
     * tmap:in is present, but tmap:in:next is not and so this code skips all the parameters
     */
    //p = Getattr(p, "tmap:in") ? Getattr(p, "tmap:in:next") : nextSibling(p);
    p = nextSibling(p);
  }
  Delete(plist);
  return "";
}

std::string PyDocConverter::justifyString(std::string documentString, int indent, int maxWidth) {
  std::string formattedString;
  std::string currentLine;

  for (std::string::iterator stringPosition = documentString.begin(); stringPosition != documentString.end(); ++stringPosition) {
    if (currentLine.length() == 0)
      currentLine.resize(indent, ' ');

    currentLine += *stringPosition;

    if ((iswspace(*stringPosition) && (int) currentLine.size() >= maxWidth) || (stringPosition + 1) == documentString.end()) {
      formattedString += currentLine + "\n";
      currentLine = "";
    }
  }

  // strip the last endl
  if (formattedString.size())
    formattedString = formattedString.substr(0, formattedString.size() - 1);

  return formattedString;
}

std::string PyDocConverter::translateSubtree(DoxygenEntity & doxygenEntity) {
  std::string translatedComment;

  if (doxygenEntity.isLeaf)
    return translatedComment;

  std::string currentSection;
  std::list < DoxygenEntity >::iterator p = doxygenEntity.entityList.begin();
  while (p != doxygenEntity.entityList.end()) {
    std::map<std::string, std::string>::iterator it;
    it = sectionTitles.find(p->typeOfEntity);
    if (it != sectionTitles.end()) {
      if (it->second != currentSection) {
        currentSection = it->second;
        translatedComment += currentSection + "\n";
      }
    }
    translateEntity(*p, translatedComment);
    translateSubtree(*p);
    p++;
  }

  return translatedComment;
}

void PyDocConverter::translateEntity(DoxygenEntity & doxyEntity, std::string &translatedComment) {
  // check if we have needed handler and call it
  std::string dummy;
  std::map<std::string, std::pair<tagHandler, std::string > >::iterator it;
  it = tagHandlers.find(doxyEntity.typeOfEntity);
  if (it!=tagHandlers.end())
    (this->*(it->second.first))(doxyEntity, translatedComment, it->second.second);
  else
    handleParagraph(doxyEntity, translatedComment, dummy);
}

void PyDocConverter::handleParagraph(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  translatedComment += justifyString(translateSubtree(tag), 0);
}
void PyDocConverter::handlePlainString(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  translatedComment += tag.data;
  if (tag.data.size() && tag.data[tag.data.size()-1] != ' ')
    translatedComment += "";
}
void PyDocConverter::handleTagMessage(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += arg;
  handleParagraph(tag, translatedComment, dummy);
}
void PyDocConverter::handleTagChar(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  translatedComment += tag.typeOfEntity;
}
void PyDocConverter::handleTagIf(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += arg;
  if (tag.entityList.size()) {
    translatedComment += tag.entityList.begin()->data;
    tag.entityList.pop_front();
    translatedComment += " {" + translateSubtree(tag) + "}";
  }
}
void PyDocConverter::handleTagPar(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  std::string dummy;
  translatedComment += "Title: ";
  if (tag.entityList.size())
    translatedComment += tag.entityList.begin()->data;
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
}
void PyDocConverter::handleTagParam(DoxygenEntity& tag, std::string& translatedComment, std::string&) {
  std::string dummy;
  if (tag.entityList.size() < 2) {
    // TODO: log error
    return;
  }
  DoxygenEntity paramNameEntity = *tag.entityList.begin();
  std::string paramDescription = "-- ";

  tag.entityList.pop_front();
  handleParagraph(tag, paramDescription, dummy);
  paramDescription = justifyString(paramDescription, DOC_PARAM_STRING_LENGTH);

  std::string paramType = getParamType(paramNameEntity.data);
  if (!paramType.size())
    paramType = "none";

  translatedComment += paramNameEntity.data + " (" + paramType + ")" + paramDescription;
}
void PyDocConverter::handleTagWrap(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  if (tag.entityList.size()) { // do not include empty tags
    std::string tagData = translateSubtree(tag);
    // wrap the thing, ignoring whitespaces
    size_t wsPos = tagData.find_last_not_of("\n\t ");
    if (wsPos != std::string::npos)
      translatedComment += arg + tagData.substr(0, wsPos + 1) + arg + tagData.substr(wsPos + 1);
    else
      translatedComment += arg + tagData + arg + " ";
  }
}
void PyDocConverter::handleNewLine(DoxygenEntity&, std::string& translatedComment, std::string&) {
  translatedComment += "\n";
}

String *PyDocConverter::makeDocumentation(Node *n) {
  String *documentation;
  std::string pyDocString, result;

  // store the node, we may need it later
  currentNode = n;

  // for overloaded functions we must concat documentation for underlying overloads
  if (Checkattr(n, "kind", "function") && Getattr(n, "sym:overloaded")) {
    // rewind to the first overload
    while (Getattr(n, "sym:previousSibling"))
      n = Getattr(n, "sym:previousSibling");

    std::vector < std::string > allDocumentation;

    // for each real method (not a generated overload) append the documentation
    while (n) {
      documentation = getDoxygenComment(n);
      if (!Swig_is_generated_overload(n) && documentation) {
	currentNode = n;
	if (GetFlag(n, "feature:doxygen:notranslate")) {
	  String *comment = NewString("");
	  Append(comment, documentation);
	  Replaceall(comment, "\n *", "\n");
	  allDocumentation.push_back(Char(comment));
	  Delete(comment);
	}
	else {
	  std::list < DoxygenEntity > entityList = parser.createTree(Char(documentation), Char(Getfile(documentation)), Getline(documentation));
	  DoxygenEntity root("root", entityList);
	  allDocumentation.push_back(translateSubtree(root));
	}
      }
      n = Getattr(n, "sym:nextSibling");
    }

    // construct final documentation string
    if (allDocumentation.size() > 1) {
      std::ostringstream concatDocString;
      for (int realOverloadCount = 0; realOverloadCount < (int) allDocumentation.size(); realOverloadCount++) {
        concatDocString << generateDivider() << std::endl;
        concatDocString << "Overload " << (realOverloadCount + 1) << ":" << std::endl;
        concatDocString << generateDivider();
        concatDocString << allDocumentation[realOverloadCount] << std::endl;
      }
      pyDocString = concatDocString.str();
    } else if (allDocumentation.size() == 1) {
      pyDocString = *(allDocumentation.begin());
    }
  }
  // for other nodes just process as normal
  else {
    documentation = getDoxygenComment(n);
    if (documentation != NULL) {
      if (GetFlag(n, "feature:doxygen:notranslate")) {
        String *comment = NewString("");
        Append(comment, documentation);
        Replaceall(comment, "\n *", "\n");
        pyDocString = Char(comment);
        Delete(comment);
      }
      else {
        std::list < DoxygenEntity > entityList = parser.createTree(Char(documentation), Char(Getfile(documentation)), Getline(documentation));
        DoxygenEntity root("root", entityList);
        pyDocString = translateSubtree(root);
      }
    }
  }

  // if we got something log the result and construct DOH string to return
  if (pyDocString.length()) {
    result = pyDocString;

    if (debug) {
      std::cout << "\n---RESULT IN PYDOC---" << std::endl;
      std::cout << result;
      std::cout << std::endl;
    }

    return NewString(result.c_str());
  }

  return NewString("");
}

std::string PyDocConverter::generateDivider() {
  static string dividerString(DOC_STRING_LENGTH, '-');
  return dividerString;
}
