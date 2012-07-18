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

  sectionTitles["author"] = "Authors:";
  sectionTitles["authors"] = "Authors:";
  sectionTitles["copyright"] = "Copyright:";
  sectionTitles["deprecated"] = "Deprecated:";
  sectionTitles["param"] = "Arguments:";
  sectionTitles["tparam"] = "Arguments:";
  sectionTitles["note"] = "Notes:";
  sectionTitles["remark"] = "Remarks:";
  sectionTitles["remarks"] = "Remarks:";
  sectionTitles["warning"] = "Warning:";
  sectionTitles["result"] = "Return:";
  sectionTitles["return"] = "Return:";
  sectionTitles["returns"] = "Return:";

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
  // these commands are stripped out
  tagHandlers["attention"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["author"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["authors"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["brief"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["c"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["code"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["copyright"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["date"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["deprecated"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["details"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["note"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["partofdescription"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["remark"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["remarks"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["warning"] = make_pair(&PyDocConverter::handleParagraph, "");
  // these commands have special handlers
  tagHandlers["cond"] = make_pair(&PyDocConverter::handleTagMessage, "Conditional comment: ");
  tagHandlers["endcond"] = make_pair(&PyDocConverter::handleTagMessage, "End of conditional comment.");
  // this command just prints it's contents
  // (it is internal command of swig's parser, contains plain text)
  tagHandlers["plainstd::string"] = make_pair(&PyDocConverter::handlePlainString, "");
  tagHandlers["plainstd::endl"] = make_pair(&PyDocConverter::handleNewLine, "");
  tagHandlers["n"] = make_pair(&PyDocConverter::handleNewLine, "");
}

PyDocConverter::PyDocConverter() : debug(false) {
  fillStaticTables();
}

std::string PyDocConverter::formatParam(Node *n, DoxygenEntity & doxygenEntity) {

  if (doxygenEntity.entityList.size() < 2) {
    /* if 'paramDescriptionEntity' is not there, ignore param. Better than crash!
       TODO: log error! */

    return "";
  }

  ParmList *plist = CopyParmList(Getattr(n, "parms"));
  Parm *p = NULL;

  DoxygenEntity & paramNameEntity = *doxygenEntity.entityList.begin();
  DoxygenEntity & paramDescriptionEntity = *(++doxygenEntity.entityList.begin());

  std::string result;
  std::string paramDescription = justifyString(paramDescriptionEntity.data, DOC_PARAM_STRING_LENGTH);

  for (p = plist; p;) {
    
    //Swig_print(p, 1);
    if (Char(Getattr(p, "name")) == paramNameEntity.data) {
      std::string name = Char(Swig_name_make(n, 0, Getattr(p, "name"), 0, 0));
      std::string type = Char(Swig_name_make(n, 0, Getattr(p, "type"), 0, 0));

      result = name + " (" + type + ") ";
      if (result.size() < (DOC_PARAM_STRING_LENGTH - 3)) {
	/* do not cut info away - it is better to have not so nice output than type information missing. */
	result.resize(DOC_PARAM_STRING_LENGTH - 3, ' ');
      }
      result += "-- " + paramDescription.substr(DOC_PARAM_STRING_LENGTH);
      break;
    }
    /*
     * doesn't seem to work always: in some cases (especially for 'self' parameters)
     * tmap:in is present, but tmap:in:next is not and so this code skips all the parameters
     */
    //p = Getattr(p, "tmap:in") ? Getattr(p, "tmap:in:next") : nextSibling(p);
    p = nextSibling(p);
  }

  Delete(plist);
  return result;
}

std::string PyDocConverter::formatReturnDescription(Node *node, DoxygenEntity & doxygenEntity) {
#pragma unused(node)
  return "\nResult:\n" + justifyString(translateSubtree(doxygenEntity));
}

std::string PyDocConverter::justifyString(std::string documentString, int indent, int maxWidth) {
  std::ostringstream formattedString;
  std::string currentLine;

  for (std::string::iterator stringPosition = documentString.begin(); stringPosition != documentString.end(); ++stringPosition) {
    if (currentLine.length() == 0)
      currentLine.resize(indent, ' ');

    currentLine += *stringPosition;

    if (*stringPosition == ' ' && (int) currentLine.size() >= maxWidth || (stringPosition + 1) == documentString.end()) {
      formattedString << currentLine << std::endl;
      currentLine = "";
    }
  }

  return formattedString.str();
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
  std::map<std::string, std::pair<tagHandler, std::string > >::iterator it;
  it = tagHandlers.find(doxyEntity.typeOfEntity);
  if (it!=tagHandlers.end())
    (this->*(it->second.first))(doxyEntity, translatedComment, it->second.second);
}

void PyDocConverter::handleParagraph(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  translatedComment += translateSubtree(tag);
}
void PyDocConverter::handlePlainString(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  translatedComment += tag.data;
  if (tag.data.size() && tag.data[tag.data.size()-1] != ' ')
    translatedComment += "";
}
void PyDocConverter::handleTagMessage(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += arg;
  handleParagraph(tag, translatedComment, dummy);
}
void PyDocConverter::handleTagChar(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  translatedComment += tag.typeOfEntity;
}
void PyDocConverter::handleTagWrap(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  if (tag.entityList.size()) // do not include empty tags
    translatedComment += arg + translateSubtree(tag) + arg;
}
void PyDocConverter::handleNewLine(DoxygenEntity& tag, std::string& translatedComment, std::string &arg) {
  translatedComment += "\n";
}

String *PyDocConverter::makeDocumentation(Node *n) {
  String *documentation;
  std::string pyDocString, result;

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
	std::list < DoxygenEntity > entityList = parser.createTree(Char(documentation), Char(Getfile(documentation)), Getline(documentation));
	DoxygenEntity root("root", entityList);
	allDocumentation.push_back(translateSubtree(root));
      }
      n = Getattr(n, "sym:nextSibling");
    }

    // construct final documentation string
    if (allDocumentation.size() > 1) {
      std::ostringstream concatDocString;
      for (int realOverloadCount = 0; realOverloadCount < (int) allDocumentation.size(); realOverloadCount++) {
        concatDocString << generateDivider();
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
      std::list < DoxygenEntity > entityList = parser.createTree(Char(documentation), Char(Getfile(documentation)), Getline(documentation));
      DoxygenEntity root("root", entityList);
      pyDocString = translateSubtree(root);
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

  return 0;
}

std::string PyDocConverter::generateDivider() {
  static string dividerString('-', DOC_STRING_LENGTH);
  return dividerString;
}
