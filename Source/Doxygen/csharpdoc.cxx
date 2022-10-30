/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * csharpdoc.cxx
 * ----------------------------------------------------------------------------- */

#include "csharpdoc.h"
#include "doxyparser.h"
#include <iostream>
#include <vector>
#include <list>
#include "swigmod.h"
#define APPROX_LINE_LENGTH 64   // characters per line allowed
#define TAB_SIZE 8              // current tab size in spaces
//TODO {@link} {@linkplain} {@docRoot}, and other useful doxy commands that are not a csharpdoc tag

// define static tables, they are filled in CSharpDocConverter's constructor
std::map<std::string, std::pair<CSharpDocConverter::tagHandler, std::string> > CSharpDocConverter::tagHandlers;

using std::string;
using std::list;
using std::vector;

void CSharpDocConverter::fillStaticTables() {
  if (tagHandlers.size()) // fill only once
    return;

  /*
   * Some translation rules:
   *
   * @ and \ must be escaped for both Java and Python to appear on output: \@, \\,
   *         while Doxygen produces output in both cases.
   * Rule:   @ and \ with space on the right should get to output.
   *
   * :: remains intact, even in class::method(). But you can use class#method also
   *    in C++ comment and it is properly translated to C++ output (changed by doxygen to ::)
   *    and Java output (remains #).
   * Rule: SWIG type system can't be used to convert C::m to C#m, because in Java it is C.m
   *       Use string replacement :: --> # in tag see and links.
   *
   * HTML tags must be translated - remain in Java, to markdown in Python
   *
   * Unknown HTML tags, for example <x> is translated to &lt;x&gt; by doxygen, while
   *     Java src is <x> and therefore invisible on output - browser ignores unknown command.
   *     This is handy in syntax descriptions, for example: more <fileName>.
   *
   * Standalone < and > need not be translated, they are rendered properly in
   *      all three outputs.
   *
   * ., %, and " need not to be translated
   *
   * entities must be translated - remain in Java, something meaningful in Python (&lt, ...)
   *
   * - Python
   * - add comments also to auto-generated methods like equals(), delete() in Java,
   *   and methods for std::vector(), ...
   *   Commenting methods of std types is simple - add comment to std_*.i file.
   */

  // these commands insert HTML tags
  tagHandlers["a"] = make_pair(&CSharpDocConverter::handleTagHtml, "i");
  tagHandlers["arg"] = make_pair(&CSharpDocConverter::handleTagHtml, "li");
  tagHandlers["b"] = make_pair(&CSharpDocConverter::handleTagHtml, "b");
  tagHandlers["c"] = make_pair(&CSharpDocConverter::handleTagHtml, "code");
  tagHandlers["cite"] = make_pair(&CSharpDocConverter::handleTagHtml, "i");
  tagHandlers["e"] = make_pair(&CSharpDocConverter::handleTagHtml, "i");
  tagHandlers["em"] = make_pair(&CSharpDocConverter::handleTagHtml, "i");
  tagHandlers["li"] = make_pair(&CSharpDocConverter::handleTagHtml, "li");
  tagHandlers["p"] = make_pair(&CSharpDocConverter::handleTagHtml, "code");
  // these commands insert just a single char, some of them need to be escaped
  tagHandlers["$"] = make_pair(&CSharpDocConverter::handleTagChar, "");
  tagHandlers["@"] = make_pair(&CSharpDocConverter::handleTagChar, "");
  tagHandlers["\\"] = make_pair(&CSharpDocConverter::handleTagChar, "");
  tagHandlers["<"] = make_pair(&CSharpDocConverter::handleTagChar, "&lt;");
  tagHandlers[">"] = make_pair(&CSharpDocConverter::handleTagChar, "&gt;");
  tagHandlers["&"] = make_pair(&CSharpDocConverter::handleTagChar, "&amp;");
  tagHandlers["#"] = make_pair(&CSharpDocConverter::handleTagChar, "");
  tagHandlers["%"] = make_pair(&CSharpDocConverter::handleTagChar, "");
  tagHandlers["~"] = make_pair(&CSharpDocConverter::handleTagChar, "");
  tagHandlers["\""] = make_pair(&CSharpDocConverter::handleTagChar, "&quot;");
  tagHandlers["."] = make_pair(&CSharpDocConverter::handleTagChar, "");
  tagHandlers["::"] = make_pair(&CSharpDocConverter::handleTagChar, "");
  // these commands are stripped out
  tagHandlers["attention"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["anchor"] = make_pair(&CSharpDocConverter::handleTagAnchor, "");
  tagHandlers["brief"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["bug"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["date"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["details"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  // this command is inserts text accumulated after cmd htmlonly -
  // see DoxygenParser - CMD_HTML_ONLY.
  tagHandlers["htmlonly"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["invariant"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["latexonly"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["manonly"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["partofdescription"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["rtfonly"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["short"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  tagHandlers["xmlonly"] = make_pair(&CSharpDocConverter::handleParagraph, "");
  // these commands are kept as-is, they are supported by CSharp
  tagHandlers["author"] = make_pair(&CSharpDocConverter::handleTagSame, "");
  tagHandlers["authors"] = make_pair(&CSharpDocConverter::handleTagSame, "author");
  tagHandlers["deprecated"] = make_pair(&CSharpDocConverter::handleTagSame, "");
  tagHandlers["exception"] = make_pair(&CSharpDocConverter::handleTagSame, "");
  tagHandlers["package"] = make_pair(&CSharpDocConverter::handleTagSame, "");
  tagHandlers["param"] = make_pair(&CSharpDocConverter::handleTagParam, "");
  tagHandlers["tparam"] = make_pair(&CSharpDocConverter::handleTagParam, "");
  tagHandlers["ref"] = make_pair(&CSharpDocConverter::handleTagRef, "");
  tagHandlers["result"] = tagHandlers["return"] = tagHandlers["returns"] = make_pair(&CSharpDocConverter::handleTagReturn, "");
  //tagHandlers["see"] = make_pair(&CSharpDocConverter::handleTagSame, "");
  //tagHandlers["sa"] = make_pair(&CSharpDocConverter::handleTagSame, "see");
  tagHandlers["since"] = make_pair(&CSharpDocConverter::handleTagSame, "");
  tagHandlers["throws"] = tagHandlers["throw"] = make_pair(&CSharpDocConverter::handleTagException, "");
  tagHandlers["version"] = make_pair(&CSharpDocConverter::handleTagSame, "");
  // these commands have special handlers
  tagHandlers["code"] = make_pair(&CSharpDocConverter::handleTagExtended, "code");
  tagHandlers["cond"] = make_pair(&CSharpDocConverter::handleTagMessage, "Conditional comment: ");
  tagHandlers["copyright"] = make_pair(&CSharpDocConverter::handleTagMessage, "Copyright: ");
  tagHandlers["else"] = make_pair(&CSharpDocConverter::handleTagIf, "Else: ");
  tagHandlers["elseif"] = make_pair(&CSharpDocConverter::handleTagIf, "Else if: ");
  tagHandlers["endcond"] = make_pair(&CSharpDocConverter::handleTagMessage, "End of conditional comment.");
  // space in second arg prevents CSharp to treat '@ example' as command. File name of
  // example is still informative to user.
  tagHandlers["example"] = make_pair(&CSharpDocConverter::handleTagSame, " example");
  tagHandlers["if"] = make_pair(&CSharpDocConverter::handleTagIf, "If: ");
  tagHandlers["ifnot"] = make_pair(&CSharpDocConverter::handleTagIf, "If not: ");
  tagHandlers["image"] = make_pair(&CSharpDocConverter::handleTagImage, "");
  tagHandlers["link"] = make_pair(&CSharpDocConverter::handleTagLink, "");
  tagHandlers["see"] = make_pair(&CSharpDocConverter::handleTagSee, "");
  tagHandlers["sa"] = make_pair(&CSharpDocConverter::handleTagSee, "");
  tagHandlers["note"] = make_pair(&CSharpDocConverter::handleTagMessage, "Note: ");
  tagHandlers["overload"] = make_pair(&CSharpDocConverter::handleTagMessage,
                                      "This is an overloaded member function, provided for"
                                      " convenience. It differs from the above function only in what" " argument(s) it accepts.");
  tagHandlers["par"] = make_pair(&CSharpDocConverter::handleTagPar, "");
  tagHandlers["remark"] = make_pair(&CSharpDocConverter::handleTagMessage, "Remarks: ");
  tagHandlers["remarks"] = make_pair(&CSharpDocConverter::handleTagMessage, "Remarks: ");
  tagHandlers["todo"] = make_pair(&CSharpDocConverter::handleTagMessage, "TODO: ");
  tagHandlers["verbatim"] = make_pair(&CSharpDocConverter::handleTagExtended, "literal");

  // \f commands output literal Latex formula, which is still better than nothing.
  tagHandlers["f$"] = make_pair(&CSharpDocConverter::handleTagVerbatim, "");
  tagHandlers["f["] = make_pair(&CSharpDocConverter::handleTagVerbatim, "");
  tagHandlers["f{"] = make_pair(&CSharpDocConverter::handleTagVerbatim, "");

  tagHandlers["warning"] = make_pair(&CSharpDocConverter::handleTagMessage, "Warning: ");
  // this command just prints its contents
  // (it is internal command of swig's parser, contains plain text)
  tagHandlers["plainstd::string"] = make_pair(&CSharpDocConverter::handlePlainString, "");
  tagHandlers["plainstd::endl"] = make_pair(&CSharpDocConverter::handleNewLine, "");
  tagHandlers["n"] = make_pair(&CSharpDocConverter::handleNewLine, "");

  // HTML tags
  tagHandlers["<a"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<a");
  tagHandlers["<b"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<b");
  tagHandlers["<blockquote"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<blockquote");
  tagHandlers["<body"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<body");
  tagHandlers["<br"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<br");
  tagHandlers["<center"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<center");
  tagHandlers["<caption"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<caption");
  tagHandlers["<code"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<code");
  tagHandlers["<dd"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<dd");
  tagHandlers["<dfn"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<dfn");
  tagHandlers["<div"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<div");
  tagHandlers["<dl"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<dl");
  tagHandlers["<dt"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<dt");
  tagHandlers["<em"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<em");
  tagHandlers["<form"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<form");
  tagHandlers["<hr"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<hr");
  tagHandlers["<h1"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<h1");
  tagHandlers["<h2"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<h2");
  tagHandlers["<h3"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<h3");
  tagHandlers["<i"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<i");
  tagHandlers["<input"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<input");
  tagHandlers["<img"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<img");
  tagHandlers["<li"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<li");
  tagHandlers["<meta"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<meta");
  tagHandlers["<multicol"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<multicol");
  tagHandlers["<ol"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<ol");
  tagHandlers["<p"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<p");
  tagHandlers["<pre"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<pre");
  tagHandlers["<small"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<small");
  tagHandlers["<span"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<span");
  tagHandlers["<strong"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<strong");
  tagHandlers["<sub"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<sub");
  tagHandlers["<sup"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<sup");
  tagHandlers["<table"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<table");
  tagHandlers["<td"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<td");
  tagHandlers["<th"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<th");
  tagHandlers["<tr"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<tr");
  tagHandlers["<tt"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<tt");
  tagHandlers["<kbd"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<kbd");
  tagHandlers["<ul"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<ul");
  tagHandlers["<var"] = make_pair(&CSharpDocConverter::handleDoxyHtmlTag, "<var");

  // HTML entities
  tagHandlers["&copy"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&copy");
  tagHandlers["&trade"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&trade");
  tagHandlers["&reg"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&reg");
  tagHandlers["&lt"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&lt");
  tagHandlers["&gt"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&gt");
  tagHandlers["&amp"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&amp");
  tagHandlers["&apos"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&apos");
  tagHandlers["&quot"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&quot");
  tagHandlers["&lsquo"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&lsquo");
  tagHandlers["&rsquo"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&rsquo");
  tagHandlers["&ldquo"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&ldquo");
  tagHandlers["&rdquo"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&rdquo");
  tagHandlers["&ndash"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&ndash");
  tagHandlers["&mdash"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&mdash");
  tagHandlers["&nbsp"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&nbsp");
  tagHandlers["&times"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&times");
  tagHandlers["&minus"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&minus");
  tagHandlers["&sdot"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&sdot");
  tagHandlers["&sim"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&sim");
  tagHandlers["&le"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&le");
  tagHandlers["&ge"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&ge");
  tagHandlers["&larr"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&larr");
  tagHandlers["&rarr"] = make_pair(&CSharpDocConverter::handleHtmlEntity, "&rarr");
}

CSharpDocConverter::CSharpDocConverter(int flags) :
  DoxygenTranslator(flags) {
  fillStaticTables();
}

/**
 * Formats comment lines by inserting '\n///' at to long lines and tabs for
 * indent. Currently it is disabled, which means original comment format is
 * preserved. Experience shows, that this is usually better than breaking
 * lines automatically, especially because original line endings are not removed,
 * which results in short lines. To be useful, this function should have much
 * better algorithm.
 */
std::string CSharpDocConverter::formatCommand(std::string unformattedLine, int indent) {
  // Currently disabled. For an idea of the algorithm look at JavaDocConverter::formatCommand().
  return unformattedLine;
}

/**
 * Returns true, if the given parameter exists in the current node
 * (for example param is a name of function parameter). If feature
 * 'doxygen:nostripparams' is set, then this method always returns
 * true - parameters are copied to output regardless of presence in
 * function params list.
 */
bool CSharpDocConverter::paramExists(std::string param) {

  if (GetFlag(currentNode, "feature:doxygen:nostripparams")) {
    return true;
  }

  ParmList *plist = CopyParmList(Getattr(currentNode, "parms"));

  for (Parm *p = plist; p;) {

    if (Getattr(p, "name") && Char(Getattr(p, "name")) == param) {
      return true;
    }
    /* doesn't seem to work always: in some cases (especially for 'self' parameters)
     * tmap:in is present, but tmap:in:next is not and so this code skips all the parameters
     */
    //p = Getattr(p, "tmap:in") ? Getattr(p, "tmap:in:next") : nextSibling(p);
    p = nextSibling(p);
  }

  Delete(plist);

  return false;
}

std::string CSharpDocConverter::translateSubtree(DoxygenEntity &doxygenEntity) {
  std::string translatedComment;

  if (doxygenEntity.isLeaf) {
    return translatedComment;
  }

  for (DoxygenEntityListIt p = doxygenEntity.entityList.begin(); p != doxygenEntity.entityList.end(); p++) {

    translateEntity(*p, translatedComment);
    translateSubtree(*p);
  }

  return translatedComment;
}

/**
 * Checks if a handler for the given tag exists, and calls it.
 */
void CSharpDocConverter::translateEntity(DoxygenEntity &tag, std::string &translatedComment) {

  std::map<std::string, std::pair<tagHandler, std::string> >::iterator it;
  it = tagHandlers.find(getBaseCommand(tag.typeOfEntity));

  if (it != tagHandlers.end()) {
    (this->*(it->second.first))(tag, translatedComment, it->second.second);
  } else {
    // do NOT print warning, since there are many tags, which are not
    // translatable - many warnings hide important ones
    // addError(WARN_DOXYGEN_COMMAND_ERROR, "Unknown doxygen or HTML tag: " + tag.typeOfEntity);
  }
}


void CSharpDocConverter::handleTagAnchor(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  translatedComment += "<a id=\"" + translateSubtree(tag) + "\"></a>";
}


void CSharpDocConverter::handleTagHtml(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  if (tag.entityList.size()) { // do not include empty tags
    std::string tagData = translateSubtree(tag);
    // wrap the thing, ignoring whitespace
    size_t wsPos = tagData.find_last_not_of("\n\t ");
    if (wsPos != std::string::npos)
      translatedComment += "<" + arg + ">" + tagData.substr(0, wsPos + 1) + "</" + arg + ">" + tagData.substr(wsPos + 1);
    else
      translatedComment += "<" + arg + ">" + translateSubtree(tag) + "</" + arg + "> ";
  }
}

void CSharpDocConverter::handleDoxyHtmlTag(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  std::string htmlTagArgs = tag.data;
  if (htmlTagArgs == "/") {
    // end html tag, for example "</ul>
    translatedComment += "</" + arg.substr(1) + ">";
  } else {
    translatedComment += arg + htmlTagArgs + ">";
  }
}

void CSharpDocConverter::handleHtmlEntity(DoxygenEntity &, std::string &translatedComment, std::string &arg) {
  // html entities can be preserved for Java
  translatedComment += arg + ';';
}

void CSharpDocConverter::handleNewLine(DoxygenEntity &, std::string &translatedComment, std::string &) {
  translatedComment += "\n/// ";
}

void CSharpDocConverter::handleTagChar(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  // escape it if we need to, else just print
  if (arg.size())
    translatedComment += arg;
  else
    translatedComment += tag.typeOfEntity;
}

void CSharpDocConverter::handleTagException(DoxygenEntity& tag, std::string& translatedComment, std::string& arg) {
  std::string dummy;
  translatedComment += "<exception>";
  translatedComment += tag.entityList.begin()->data;
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
  translatedComment += "</exception>";
}

// handles tags which are the same in Doxygen and CSharp.
void CSharpDocConverter::handleTagSame(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  if (arg.size())
    tag.typeOfEntity = arg;
  translatedComment += formatCommand(std::string("@" + tag.typeOfEntity + " " + translateSubtree(tag)), 2);
}

void CSharpDocConverter::handleParagraph(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  translatedComment += formatCommand(translateSubtree(tag), 0);
}

void CSharpDocConverter::handlePlainString(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  translatedComment += tag.data;
  // if (tag.data.size() && tag.data[tag.data.size()-1] != ' ')
  //    translatedComment += " ";
}

void CSharpDocConverter::handleTagVerbatim(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  translatedComment += arg + " ";
  for (DoxygenEntityListCIt it = tag.entityList.begin(); it != tag.entityList.end(); it++) {
    translatedComment += it->data;
  }
}

void CSharpDocConverter::handleTagExtended(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += "{@" + arg + " ";
  handleParagraph(tag, translatedComment, dummy);
  translatedComment += "}";
}

void CSharpDocConverter::handleTagIf(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += arg;
  if (tag.entityList.size()) {
    translatedComment += tag.entityList.begin()->data;
    tag.entityList.pop_front();
    translatedComment += " {" + translateSubtree(tag) + "}";
  }
}

void CSharpDocConverter::handleTagMessage(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  std::string dummy;
  translatedComment += formatCommand(arg, 0);
  handleParagraph(tag, translatedComment, dummy);
}

void CSharpDocConverter::handleTagImage(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  if (tag.entityList.size() < 2)
    return;

  std::string file;
  std::string title;

  std::list<DoxygenEntity>::iterator it = tag.entityList.begin();
  if (it->data != "html")
    return;

  it++;
  file = it->data;

  it++;
  if (it != tag.entityList.end())
    title = it->data;

  translatedComment += "<img src=";
  if (file.size() >= 2 && file[0] == '"' && file[file.size() - 1] == '"')
    translatedComment += file;
  else
    translatedComment += "\"" + file + "\"";
  if (title.size())
    translatedComment += " alt=" + title;

  // the size indication is supported for Latex only in Doxygen, see manual

  translatedComment += "/>";
}

void CSharpDocConverter::handleTagPar(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
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


void CSharpDocConverter::handleTagParam(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;

  if (!tag.entityList.size())
    return;
  if (!paramExists(tag.entityList.begin()->data))
    return;

  translatedComment += "@param ";
  translatedComment += tag.entityList.begin()->data;
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
}


void CSharpDocConverter::handleTagReturn(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  translatedComment += "<returns>";
  translatedComment += tag.entityList.begin()->data;
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
  translatedComment += "</returns>";
}


void CSharpDocConverter::handleTagRef(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  if (!tag.entityList.size())
    return;

  // we translate to link, although \page is not supported in Java, but
  // reader at least knows what to look at. Also for \anchor tag on the same
  // page this link works.
  string anchor = tag.entityList.begin()->data;
  tag.entityList.pop_front();
  string anchorText = anchor;
  if (!tag.entityList.empty()) {
    anchorText = tag.entityList.begin()->data;
  }
  translatedComment += "<a href=\"#" + anchor + "\">" + anchorText + "</a>";
}


string CSharpDocConverter::convertLink(string linkObject) {
  if (GetFlag(currentNode, "feature:doxygen:nolinktranslate"))
    return linkObject;
  // find the params in function in linkObject (if any)
  size_t lbracePos = linkObject.find('(', 0);
  size_t rbracePos = linkObject.find(')', 0);
  if (lbracePos == string::npos || rbracePos == string::npos || lbracePos >= rbracePos)
    return "";

  string paramsStr = linkObject.substr(lbracePos + 1,
                                       rbracePos - lbracePos - 1);
  // strip the params, to fill them later
  string additionalObject = linkObject.substr(rbracePos + 1, string::npos);
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
  for (size_t i = 0; i < params.size(); i++) {
    // translate c/c++ type string to swig's type
    // i e 'int **arr[100][10]' -> 'a(100).a(10).p.p.int'
    // also converting arrays to pointers
    string paramStr = params[i];
    String *swigType = NewString("");

    // handle const qualifier
    if (paramStr.find("const") != string::npos)
      SwigType_add_qualifier(swigType, "const");

    // handle pointers, references and arrays
    for (int j = (int)params[i].size() - 1; j >= 0; j--) {
      // skip all the [...] blocks, write 'p.' for every of it
      if (paramStr[j] == ']') {
        while (j >= 0 && paramStr[j] != '[')
          j--;
        // no closing brace
        if (j < 0)
          return "";
        SwigType_add_pointer(swigType);
        continue;
      } else if (paramStr[j] == '*')
        SwigType_add_pointer(swigType);
      else if (paramStr[j] == '&')
        SwigType_add_reference(swigType);
      else if (isalnum(paramStr[j])) {
        size_t typeNameStart = paramStr.find_last_of(' ', j + 1);
        if (typeNameStart == string::npos)
          typeNameStart = 0;
        else
          typeNameStart++;
        Append(swigType, paramStr.substr(typeNameStart, j - typeNameStart + 1).c_str());
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

  return linkObject + additionalObject;
}

void CSharpDocConverter::handleTagLink(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
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

void CSharpDocConverter::handleTagSee(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  if (!tag.entityList.size())
    return;

  // tag.entity list contains contents of the @see paragraph. It should contain
  // one link (references) to method with or without parameters. Doxygen supports
  // arbitrary text and types mixed, but this feature is not supported here.
  // :: or # may be used as a separator between class name and method name.
  list<DoxygenEntity>::iterator it;
  string methodRef;
  for (it = tag.entityList.begin(); it != tag.entityList.end(); it++) {
    if (it->typeOfEntity == "plainstd::endl") {
      // handleNewLine(*it, translatedComment, dummy);
      continue;
    }
    // restore entities which may be used in C++ type declaration
    if (it->typeOfEntity == "&amp") {
      methodRef += '&';
    } else if (it->typeOfEntity == "&lt") {
      methodRef += '<';
    } else if (it->typeOfEntity == "&gt") {
      methodRef += '>';
    } else {
      methodRef += it->data;
    }
  }

  // replace :: with #, but only if it appears before left brace
  size_t lbrace = methodRef.find('(');
  size_t dblColon = methodRef.find("::");
  if (dblColon < lbrace) {
    methodRef = methodRef.substr(0, dblColon) + '#' + methodRef.substr(dblColon + 2);
  }

  translatedComment += "@see ";
  string linkObject = convertLink(methodRef);
  if (!linkObject.size()) {
    linkObject = methodRef;
  }
  translatedComment += linkObject;
}

/* This function moves all line endings at the end of child entities
 * out of the child entities to the parent.
 * For example, entity tree:

 -root
 |-param
 |-paramText
 |-endline

 should be turned to

 -root
 |-param
 |-paramText
 |-endline
 *
 */
int CSharpDocConverter::shiftEndlinesUpTree(DoxygenEntity &root, int level) {
  DoxygenEntityListIt it = root.entityList.begin();
  while (it != root.entityList.end()) {
    // remove line endings
    int ret = shiftEndlinesUpTree(*it, level + 1);
    // insert them after this element
    it++;
    for (int i = 0; i < ret; i++) {
      root.entityList.insert(it, DoxygenEntity("plainstd::endl"));
    }
  }

  // continue only if we are not root
  if (!level) {
    return 0;
  }

  int removedCount = 0;
  while (!root.entityList.empty()
         && root.entityList.rbegin()->typeOfEntity == "plainstd::endl") {
    root.entityList.pop_back();
    removedCount++;
  }
  return removedCount;
}

/**
 * This makes sure that all comment lines contain '*'. It is not mandatory in doxygen,
 * but highly recommended for CSharp. '*' in empty lines are indented according
 * to indentation of the first line. Indentation of non-empty lines is not
 * changed - garbage in garbage out.
 */
std::string CSharpDocConverter::indentAndInsertSlashes(const string &doc) {
  size_t idx = doc.find('\n');
  size_t indent = 0;
  bool singleLineComment = idx == string::npos;
  // Detect indentation.
  //   The first line in comment is the one after '/**', which may be
  //   spaces and '\n' or the text. In any case it is not suitable to detect
  //   indentation, so we have to skip the first '\n'.
  //   However, if there is just one line, then use that line to detect indentation.
  if (idx != string::npos) {
    size_t nonspaceIdx = doc.find_first_not_of(" \t", idx + 1);
    if (nonspaceIdx != string::npos) {
      indent = nonspaceIdx - idx;
    }
  }

  if (indent == 0) {
    // we can't indent the first line less than 0
    indent = 1;
  }
  // Create the first line of CSharp comment.
  string indentStr(indent - 1, ' ');
  string translatedStr = indentStr + "/// <summary>";
  if (indent > 1) {
    // remove the first space, so that '///' will be aligned
    translatedStr = translatedStr.substr(1);
  }

  translatedStr += doc;

  // insert '///' before each comment line, if it does not have it
  idx = translatedStr.find('\n');

  while (idx != string::npos) {
    size_t nonspaceIdx = translatedStr.find_first_not_of(" \t", idx + 1);
    if (nonspaceIdx != string::npos && translatedStr[nonspaceIdx] != '*') {
      // line without '*' found - is it empty?
      if (translatedStr[nonspaceIdx] != '\n') {
        // add '/// ' to each line without it
        translatedStr = translatedStr.substr(0, nonspaceIdx) + "/// " + translatedStr.substr(nonspaceIdx);
        //printf(translatedStr.c_str());
      } else {
        // we found empty line, replace it with indented '*'
        translatedStr = translatedStr.substr(0, idx + 1) + indentStr + "/// " + translatedStr.substr(nonspaceIdx);
      }
    }
    idx = translatedStr.find('\n', nonspaceIdx);
  }

  // Add the last comment line properly indented
  size_t nonspaceEndIdx = translatedStr.find_last_not_of(" \t");
  if (nonspaceEndIdx != string::npos) {
    if (translatedStr[nonspaceEndIdx] != '\n') {
      if (!singleLineComment)
	translatedStr += '\n';
    } else {
      // remove trailing spaces
      translatedStr = translatedStr.substr(0, nonspaceEndIdx + 1);
    }
  }

  // Create the last line of CSharp comment.
  translatedStr += indentStr + "/// </summary>\n";

  return translatedStr;
}

String *CSharpDocConverter::makeDocumentation(Node *node) {
  String *documentation = getDoxygenComment(node);

  if (documentation == NULL) {
    return NewString("");
  }

  // Note: it is currently unclear if, and how, notranslate would work for csharp:
  //if (GetFlag(node, "feature:doxygen:notranslate")) {
  //  string doc = Char(documentation);
  //
  //  string translatedStr = indentAndInsertSlashes(doc);
  //
  //  return NewString(translatedStr.c_str());
  //}

  DoxygenEntityList entityList = parser.createTree(node, documentation);

  // entityList.sort(CompareDoxygenEntities()); sorting currently not used,

  if (m_flags & debug_translator) {
    std::cout << "---RESORTED LIST---" << std::endl;
    printTree(entityList);
  }
  // store the current node
  // (currently just to handle params)
  currentNode = node;

  std::string csharpDocString = "/// <summary>\n/// ";

  DoxygenEntity root("root", entityList);

  shiftEndlinesUpTree(root);

  // strip line endings at the beginning
  while (!root.entityList.empty()
         && root.entityList.begin()->typeOfEntity == "plainstd::endl") {
    root.entityList.pop_front();
  }

  // and at the end
  while (!root.entityList.empty()
         && root.entityList.rbegin()->typeOfEntity == "plainstd::endl") {
    root.entityList.pop_back();
  }

  csharpDocString += translateSubtree(root);

  csharpDocString += "\n/// </summary>\n";

  if (m_flags & debug_translator) {
    std::cout << "\n---RESULT IN CSHARP---" << std::endl;
    std::cout << csharpDocString;
  }

  return NewString(csharpDocString.c_str());
}

void CSharpDocConverter::addError(int warningType, const std::string &message) {
  Swig_warning(warningType, "", 0, "Doxygen parser warning: %s. \n", message.c_str());
}
