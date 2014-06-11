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
#include <string>
#include <vector>
#include <iostream>

// define static tables, they are filled in PyDocConverter's constructor
std::map<std::string, std::pair<PyDocConverter::tagHandler, std::string> > PyDocConverter::tagHandlers;
std::map<std::string, std::string> PyDocConverter::sectionTitles;

using std::string;

void PyDocConverter::fillStaticTables()
{
  if (tagHandlers.size()) // fill only once
    return;

  // table of section titles, they are printed only once
  // for each group of specified doxygen commands
  sectionTitles["author"] = "Author: ";
  sectionTitles["authors"] = "Authors: ";
  sectionTitles["copyright"] = "Copyright: ";
  sectionTitles["deprecated"] = "Deprecated: ";
  sectionTitles["example"] = "Example: ";
  sectionTitles["exception"] = "Throws: ";
  sectionTitles["param"] = "Arguments:\n";
  sectionTitles["tparam"] = "Arguments:\n";
  sectionTitles["note"] = "Notes: ";
  sectionTitles["remark"] = "Remarks: ";
  sectionTitles["remarks"] = "Remarks: ";
  sectionTitles["warning"] = "Warning: ";
  sectionTitles["result"] = "Return: ";
  sectionTitles["return"] = "Return: ";
  sectionTitles["returns"] = "Returns: ";
//  sectionTitles["sa"] = "See also: ";
//  sectionTitles["see"] = "See also: ";
  sectionTitles["since"] = "Since: ";
  sectionTitles["throw"] = "Throw: ";
  sectionTitles["throws"] = "Throws: ";
  sectionTitles["todo"] = "TODO: ";
  sectionTitles["version"] = "Version: ";

  tagHandlers["a"] = make_pair(&PyDocConverter::handleTagWrap, "_");
  tagHandlers["b"] = make_pair(&PyDocConverter::handleTagWrap, "__");
  // \c command is translated as single quotes around next word
  tagHandlers["c"] = make_pair(&PyDocConverter::handleTagWrap, "'"); // see markdown support in doxy, section 'code wraps'
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
  // these commands are stripped out, and only their content is printed
  tagHandlers["attention"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["author"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["authors"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["brief"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["bug"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["code"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["copyright"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["date"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["deprecated"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["details"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["em"] = make_pair(&PyDocConverter::handleParagraph, " ");
  tagHandlers["example"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["exception"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["htmlonly"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["invariant"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["latexonly"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["link"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["manonly"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["note"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["p"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["partofdescription"] = make_pair(&PyDocConverter::handleParagraph,
      "");
  tagHandlers["rtfonly"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["return"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["returns"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["result"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["remark"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["remarks"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["sa"] = make_pair(&PyDocConverter::handleTagMessage,
      "See also: ");
  tagHandlers["see"] = make_pair(&PyDocConverter::handleTagMessage,
      "See also: ");
  tagHandlers["since"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["short"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["throw"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["throws"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["todo"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["version"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["verbatim"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["warning"] = make_pair(&PyDocConverter::handleParagraph, "");
  tagHandlers["xmlonly"] = make_pair(&PyDocConverter::handleParagraph, "");
  // these commands have special handlers
  tagHandlers["arg"] = make_pair(&PyDocConverter::handleTagMessage, " -");
  tagHandlers["cond"] = make_pair(&PyDocConverter::handleTagMessage,
      "Conditional comment: ");
  tagHandlers["else"] = make_pair(&PyDocConverter::handleTagIf, "Else: ");
  tagHandlers["elseif"] = make_pair(&PyDocConverter::handleTagIf, "Else if: ");
  tagHandlers["endcond"] = make_pair(&PyDocConverter::handleTagMessage,
      "End of conditional comment.");
  tagHandlers["if"] = make_pair(&PyDocConverter::handleTagIf, "If: ");
  tagHandlers["ifnot"] = make_pair(&PyDocConverter::handleTagIf, "If not: ");
  tagHandlers["image"] = make_pair(&PyDocConverter::handleTagImage, "");
  tagHandlers["li"] = make_pair(&PyDocConverter::handleTagMessage, " -");
  tagHandlers["overload"] = make_pair(&PyDocConverter::handleTagMessage,
      "This is an overloaded member function, provided for"
          " convenience.\nIt differs from the above function only in what"
          " argument(s) it accepts.");
  tagHandlers["par"] = make_pair(&PyDocConverter::handleTagPar, "");
  tagHandlers["param"] = make_pair(&PyDocConverter::handleTagParam, "");
  tagHandlers["tparam"] = make_pair(&PyDocConverter::handleTagParam, "");
  tagHandlers["ref"] = make_pair(&PyDocConverter::handleTagRef, "");
  // this command just prints it's contents
  // (it is internal command of swig's parser, contains plain text)
  tagHandlers["plainstd::string"] = make_pair(
      &PyDocConverter::handlePlainString, "");
  tagHandlers["plainstd::endl"] = make_pair(&PyDocConverter::handleNewLine, "");
  tagHandlers["n"] = make_pair(&PyDocConverter::handleNewLine, "");

  // \f commands output literal Latex formula, which is still better than nothing.
  tagHandlers["f$"] = make_pair(&PyDocConverter::handleTagVerbatim, "");
  tagHandlers["f["] = make_pair(&PyDocConverter::handleTagVerbatim, "");
  tagHandlers["f{"] = make_pair(&PyDocConverter::handleTagVerbatim, "");

  // HTML tags
  tagHandlers["<a"] = make_pair(&PyDocConverter::handleDoxyHtmlTag_A, "");
  tagHandlers["<b"] = make_pair(&PyDocConverter::handleDoxyHtmlTag2, "__");
  tagHandlers["<blockquote"] = make_pair(&PyDocConverter::handleDoxyHtmlTag_A,
      "Quote: ");
  tagHandlers["<body"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<br"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "\n");

  // there is no formatting for this tag as it was deprecated in HTML 4.01 and
  // not used in HTML 5
  tagHandlers["<center"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<caption"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<code"] = make_pair(&PyDocConverter::handleDoxyHtmlTag2, "'");

  tagHandlers["<dl"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<dd"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "    ");
  tagHandlers["<dt"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");

  tagHandlers["<dfn"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<div"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<em"] = make_pair(&PyDocConverter::handleDoxyHtmlTag2, "__");
  tagHandlers["<form"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<hr"] = make_pair(&PyDocConverter::handleDoxyHtmlTag,
      "--------------------------------------------------------------------\n");
  tagHandlers["<h1"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "# ");
  tagHandlers["<h2"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "## ");
  tagHandlers["<h3"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "### ");
  tagHandlers["<i"] = make_pair(&PyDocConverter::handleDoxyHtmlTag2, "_");
  tagHandlers["<input"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<img"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "Image:");
  tagHandlers["<li"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "- ");
  tagHandlers["<meta"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<multicol"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<ol"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<p"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "\n");
  tagHandlers["<pre"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<small"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<span"] = make_pair(&PyDocConverter::handleDoxyHtmlTag2, "'");
  tagHandlers["<strong"] = make_pair(&PyDocConverter::handleDoxyHtmlTag2, "__");

  // make a space between text and super/sub script.
  tagHandlers["<sub"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, " ");
  tagHandlers["<sup"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, " ");

  tagHandlers["<table"] = make_pair(&PyDocConverter::handleDoxyHtmlTagNoParam,
      "");
  tagHandlers["<td"] = make_pair(&PyDocConverter::handleDoxyHtmlTag_td, "");
  tagHandlers["<th"] = make_pair(&PyDocConverter::handleDoxyHtmlTag_th, "");
  tagHandlers["<tr"] = make_pair(&PyDocConverter::handleDoxyHtmlTag_tr, "");
  tagHandlers["<tt"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<kbd"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<ul"] = make_pair(&PyDocConverter::handleDoxyHtmlTag, "");
  tagHandlers["<var"] = make_pair(&PyDocConverter::handleDoxyHtmlTag2, "_");

  // HTML entities
  tagHandlers["&copy"] = make_pair(&PyDocConverter::handleHtmlEntity, "(C)");
  tagHandlers["&trade"] = make_pair(&PyDocConverter::handleHtmlEntity, " TM");
  tagHandlers["&reg"] = make_pair(&PyDocConverter::handleHtmlEntity, "(R)");
  tagHandlers["&lt"] = make_pair(&PyDocConverter::handleHtmlEntity, "<");
  tagHandlers["&gt"] = make_pair(&PyDocConverter::handleHtmlEntity, ">");
  tagHandlers["&amp"] = make_pair(&PyDocConverter::handleHtmlEntity, "&");
  tagHandlers["&apos"] = make_pair(&PyDocConverter::handleHtmlEntity, "'");
  tagHandlers["&quot"] = make_pair(&PyDocConverter::handleHtmlEntity, "\"");
  tagHandlers["&lsquo"] = make_pair(&PyDocConverter::handleHtmlEntity, "`");
  tagHandlers["&rsquo"] = make_pair(&PyDocConverter::handleHtmlEntity, "'");
  tagHandlers["&ldquo"] = make_pair(&PyDocConverter::handleHtmlEntity, "\"");
  tagHandlers["&rdquo"] = make_pair(&PyDocConverter::handleHtmlEntity, "\"");
  tagHandlers["&ndash"] = make_pair(&PyDocConverter::handleHtmlEntity, "-");
  tagHandlers["&mdash"] = make_pair(&PyDocConverter::handleHtmlEntity, "--");
  tagHandlers["&nbsp"] = make_pair(&PyDocConverter::handleHtmlEntity, " ");
  tagHandlers["&times"] = make_pair(&PyDocConverter::handleHtmlEntity, "x");
  tagHandlers["&minus"] = make_pair(&PyDocConverter::handleHtmlEntity, "-");
  tagHandlers["&sdot"] = make_pair(&PyDocConverter::handleHtmlEntity, ".");
  tagHandlers["&sim"] = make_pair(&PyDocConverter::handleHtmlEntity, "~");
  tagHandlers["&le"] = make_pair(&PyDocConverter::handleHtmlEntity, "<=");
  tagHandlers["&ge"] = make_pair(&PyDocConverter::handleHtmlEntity, ">=");
  tagHandlers["&larr"] = make_pair(&PyDocConverter::handleHtmlEntity, "<--");
  tagHandlers["&rarr"] = make_pair(&PyDocConverter::handleHtmlEntity, "-->");
}

PyDocConverter::PyDocConverter(int flags) :
    DoxygenTranslator(flags), m_tableLineLen(0), m_prevRowIsTH(
        false)
{
  fillStaticTables();
}

std::string PyDocConverter::getParamType(std::string param)
{
  ParmList *plist = CopyParmList(Getattr(currentNode, "parms"));
  Parm *p = NULL;
  for (p = plist; p;) {
    if (Char (Getattr(p, "name")) == param) {
      std::string type = Char (SwigType_str(Getattr(p, "type"), ""));
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

std::string PyDocConverter::justifyString(std::string documentString,
                                          int indent, int maxWidth)
{
  std::string formattedString;
  std::string currentLine;

  for (std::string::iterator stringPosition = documentString.begin();
      stringPosition != documentString.end(); ++stringPosition) {
    if (currentLine.length() == 0)
      currentLine.resize(indent, ' ');

    currentLine += *stringPosition;

    if ((iswspace(*stringPosition) && (int) currentLine.size() >= maxWidth)
        || (stringPosition + 1) == documentString.end()) {
      formattedString += currentLine + "\n";
      currentLine = "";
    }
  }

  // strip the last endl
  if (formattedString.size())
    formattedString = formattedString.substr(0, formattedString.size() - 1);

  return formattedString;
}

std::string PyDocConverter::translateSubtree(DoxygenEntity & doxygenEntity)
{
  std::string translatedComment;

  if (doxygenEntity.isLeaf)
    return translatedComment;

  std::string currentSection;
  std::list<DoxygenEntity>::iterator p = doxygenEntity.entityList.begin();
  while (p != doxygenEntity.entityList.end()) {
    std::map<std::string, std::string>::iterator it;
    it = sectionTitles.find(p->typeOfEntity);
    if (it != sectionTitles.end()) {
      if (it->second != currentSection) {
        currentSection = it->second;
        translatedComment += currentSection;
      }
    }
    translateEntity(*p, translatedComment);
    translateSubtree(*p);
    p++;
  }

  return translatedComment;
}

void PyDocConverter::translateEntity(DoxygenEntity & doxyEntity,
                                     std::string &translatedComment)
{
  // check if we have needed handler and call it
  std::map<std::string, std::pair<tagHandler, std::string> >::iterator it;
  it = tagHandlers.find(doxyEntity.typeOfEntity);
  if (it != tagHandlers.end())
    (this->*(it->second.first))(doxyEntity, translatedComment,
        it->second.second);
}

void PyDocConverter::handleParagraph(DoxygenEntity& tag,
                                     std::string& translatedComment,
                                     std::string &arg)
{
  translatedComment += translateSubtree(tag) + arg;
}

void PyDocConverter::handlePlainString(DoxygenEntity& tag,
                                       std::string& translatedComment,
                                       std::string&)
{
  translatedComment += tag.data;
  if (tag.data.size() && tag.data[tag.data.size() - 1] != ' ')
    translatedComment += "";
}

void PyDocConverter::handleTagVerbatim(DoxygenEntity& tag,
                                       std::string& translatedComment,
                                       std::string &arg)
{
  translatedComment += arg + " ";
  for (DoxygenEntityListCIt it = tag.entityList.begin();
      it != tag.entityList.end(); it++) {
    translatedComment += it->data;
  }
}

void PyDocConverter::handleTagMessage(DoxygenEntity& tag,
                                      std::string& translatedComment,
                                      std::string &arg)
{
  std::string dummy;
  translatedComment += arg;
  handleParagraph(tag, translatedComment, dummy);
}

void PyDocConverter::handleTagChar(DoxygenEntity& tag,
                                   std::string& translatedComment, std::string&)
{
  translatedComment += tag.typeOfEntity;
}

void PyDocConverter::handleTagIf(DoxygenEntity& tag,
                                 std::string& translatedComment,
                                 std::string &arg)
{
  std::string dummy;
  translatedComment += arg;
  if (tag.entityList.size()) {
    translatedComment += tag.entityList.begin()->data;
    tag.entityList.pop_front();
    translatedComment += " {" + translateSubtree(tag) + "}";
  }
}

void PyDocConverter::handleTagPar(DoxygenEntity& tag,
                                  std::string& translatedComment, std::string&)
{
  std::string dummy;
  translatedComment += "Title: ";
  if (tag.entityList.size())
    translatedComment += tag.entityList.begin()->data;
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
}

void PyDocConverter::handleTagImage(DoxygenEntity& tag,
                                    std::string& translatedComment,
                                    std::string&)
{
  if (tag.entityList.size() < 2)
    return;
  tag.entityList.pop_front();
  translatedComment += "Image: ";
  translatedComment += tag.entityList.begin()->data;
  tag.entityList.pop_front();
  if (tag.entityList.size())
    translatedComment += "(" + tag.entityList.begin()->data + ")";
}

void PyDocConverter::handleTagParam(DoxygenEntity& tag,
                                    std::string& translatedComment,
                                    std::string&)
{
  std::string dummy;
  if (tag.entityList.size() < 2)
    return;

  DoxygenEntity paramNameEntity = *tag.entityList.begin();
  tag.entityList.pop_front();

  std::string paramType = getParamType(paramNameEntity.data);
  if (!paramType.size())
    paramType = "none";

  translatedComment += "  " + paramNameEntity.data + " (" + paramType + ") --";
  handleParagraph(tag, translatedComment, dummy);
}


void PyDocConverter::handleTagRef(DoxygenEntity& tag,
                                  std::string& translatedComment,
                                  std::string&)
{
  std::string dummy;
  if (!tag.entityList.size())
    return;

  string anchor = tag.entityList.begin()->data;
  tag.entityList.pop_front();
  string anchorText = anchor;
  if (!tag.entityList.empty()) {
    anchorText = tag.entityList.begin()->data;
  }
  translatedComment += "'" + anchorText + "'";
}


void PyDocConverter::handleTagWrap(DoxygenEntity& tag,
                                   std::string& translatedComment,
                                   std::string &arg)
{
  if (tag.entityList.size()) { // do not include empty tags
    std::string tagData = translateSubtree(tag);
    // wrap the thing, ignoring whitespace
    size_t wsPos = tagData.find_last_not_of("\n\t ");
    if (wsPos != std::string::npos && wsPos != tagData.size() - 1)
      translatedComment += arg + tagData.substr(0, wsPos + 1) + arg
          + tagData.substr(wsPos + 1);
    else
      translatedComment += arg + tagData + arg;
  }
}

void PyDocConverter::handleDoxyHtmlTag(DoxygenEntity& tag,
                                       std::string& translatedComment,
                                       std::string &arg)
{
  std::string htmlTagArgs = tag.data;
  if (htmlTagArgs == "/") {
    // end html tag, for example "</ul>
    // translatedComment += "</" + arg.substr(1) + ">";
  } else {
    translatedComment += arg + htmlTagArgs;
  }
}

void PyDocConverter::handleDoxyHtmlTagNoParam(DoxygenEntity& tag,
                                              std::string& translatedComment,
                                              std::string &arg)
{
  std::string htmlTagArgs = tag.data;
  if (htmlTagArgs == "/") {
    // end html tag, for example "</ul>
  } else {
    translatedComment += arg;
  }
}

void PyDocConverter::handleDoxyHtmlTag_A(DoxygenEntity& tag,
                                         std::string& translatedComment,
                                         std::string &arg)
{
  std::string htmlTagArgs = tag.data;
  if (htmlTagArgs == "/") {
    // end html tag, "</a>
    translatedComment += " (" + m_url + ')';
    m_url.clear();
  } else {
    m_url.clear();
    size_t pos = htmlTagArgs.find('=');
    if (pos != string::npos) {
      m_url = htmlTagArgs.substr(pos + 1);
    }
    translatedComment += arg;
  }
}

void PyDocConverter::handleDoxyHtmlTag2(DoxygenEntity& tag,
                                        std::string& translatedComment,
                                        std::string &arg)
{
  std::string htmlTagArgs = tag.data;
  if (htmlTagArgs == "/") {
    // end html tag, for example "</em>
    translatedComment += arg;
  } else {
    translatedComment += arg;
  }
}

void PyDocConverter::handleDoxyHtmlTag_tr(DoxygenEntity& tag,
                                          std::string& translatedComment,
                                          std::string &)
{
  std::string htmlTagArgs = tag.data;
  size_t nlPos = translatedComment.rfind('\n');
  if (htmlTagArgs == "/") {
    // end tag, </tr> appends vertical table line '|'
    translatedComment += '|';
    if (nlPos != string::npos) {
      size_t startOfTableLinePos = translatedComment.find_first_not_of(" \t",
          nlPos + 1);
      if (startOfTableLinePos != string::npos) {
        m_tableLineLen = translatedComment.size() - startOfTableLinePos;
      }
    }
  } else {
    if (m_prevRowIsTH) {
      // if previous row contained <th> tag, add horizontal separator
      // but first get leading spaces, because they'll be needed for the next row
      size_t numLeadingSpaces = translatedComment.size() - nlPos - 1;

      translatedComment += string(m_tableLineLen, '-') + '\n';

      if (nlPos != string::npos) {
        translatedComment += string(numLeadingSpaces, ' ');
      }
      m_prevRowIsTH = false;
    }
  }
}

void PyDocConverter::handleDoxyHtmlTag_th(DoxygenEntity& tag,
                                          std::string& translatedComment,
                                          std::string &)
{
  std::string htmlTagArgs = tag.data;
  if (htmlTagArgs == "/") {
    // end tag, </th> is ignored
  } else {
    translatedComment += '|';
    m_prevRowIsTH = true;
  }
}

void PyDocConverter::handleDoxyHtmlTag_td(DoxygenEntity& tag,
                                          std::string& translatedComment,
                                          std::string &)
{
  std::string htmlTagArgs = tag.data;
  if (htmlTagArgs == "/") {
    // end tag, </td> is ignored
  } else {
    translatedComment += '|';
  }
}

void PyDocConverter::handleHtmlEntity(DoxygenEntity&,
                                      std::string& translatedComment,
                                      std::string &arg)
{
  // html entities
  translatedComment += arg;
}

void PyDocConverter::handleNewLine(DoxygenEntity&,
                                   std::string& translatedComment, std::string&)
{
  translatedComment += "\n";
}

String *PyDocConverter::makeDocumentation(Node *n)
{
  String *documentation;
  std::string pyDocString, result;

  // store the node, we may need it later
  currentNode = n;

  // for overloaded functions we must concat documentation for underlying overloads
  if (Checkattr(n, "kind", "function") && Getattr(n, "sym:overloaded")) {
    // rewind to the first overload
    while (Getattr(n, "sym:previousSibling"))
      n = Getattr(n, "sym:previousSibling");

    std::vector<std::string> allDocumentation;

    // for each real method (not a generated overload) append the documentation
    while (n) {
      documentation = getDoxygenComment(n);
      if (!Swig_is_generated_overload(n) && documentation) {
        currentNode = n;
        if (GetFlag(n, "feature:doxygen:notranslate")) {
          String *comment = NewString("");
          Append(comment, documentation);
          Replaceall(comment, "\n *", "\n");
          allDocumentation.push_back(Char (comment));
          Delete(comment);
        } else {
          std::list<DoxygenEntity> entityList = parser.createTree(
              Char (documentation), Char (Getfile(documentation)),
              Getline(documentation));
          DoxygenEntity root("root", entityList);
          allDocumentation.push_back(translateSubtree(root));
        }
      }
      n = Getattr(n, "sym:nextSibling");
    }

    // construct final documentation string
    if (allDocumentation.size() > 1) {
      std::ostringstream concatDocString;
      for (int realOverloadCount = 0;
          realOverloadCount < (int) allDocumentation.size();
          realOverloadCount++) {
        concatDocString << generateDivider() << std::endl;
        concatDocString << "Overload " << (realOverloadCount + 1) << ":"
            << std::endl;
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
        pyDocString = Char (comment);
        Delete(comment);
      } else {
        std::list<DoxygenEntity> entityList = parser.createTree(
            Char (documentation), Char (Getfile(documentation)),
            Getline(documentation));
        DoxygenEntity root("root", entityList);
        pyDocString = translateSubtree(root);
      }
    }
  }

  // if we got something log the result and construct DOH string to return
  if (!pyDocString.empty()) {

    // remove the last '\n' since additional one is added during writing to file
    if (pyDocString[pyDocString.size() - 1] == '\n') {
      pyDocString.erase(pyDocString.size() - 1);
    }

    result = pyDocString;

    if (m_flags & debug_translator) {
      std::cout << "\n---RESULT IN PYDOC---" << std::endl;
      std::cout << result;
      std::cout << std::endl;
    }

    return NewString(result.c_str());
  }

  return NewString("");
}

std::string PyDocConverter::generateDivider()
{
  static string dividerString(DOC_STRING_LENGTH, '-');
  return dividerString;
}
