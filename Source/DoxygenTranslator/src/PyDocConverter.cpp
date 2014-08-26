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

#include "swigmod.h"

// define static tables, they are filled in PyDocConverter's constructor
PyDocConverter::TagHandlersMap PyDocConverter::tagHandlers;
std::map<std::string, std::string> PyDocConverter::sectionTitles;

using std::string;

// Helper class increasing the provided indent string in its ctor and decreasing
// it in its dtor.
class IndentGuard
{
public:
  // One indent level.
  static const char* Level() { return "    "; }

  // Ctor takes the output to determine the current indent and to remove the
  // extra indent added to it in the dtor and the variable containing the indent
  // to use, which must be used after every new line by the code actually
  // updating the output.
  explicit IndentGuard(string& output, string& indent) :
    m_output(output),
    m_indent(indent)
  {
    const size_t lastNonSpace = m_output.find_last_not_of(' ');
    if (lastNonSpace == string::npos) {
      m_firstLineIndent = m_output.length();
    } else if (m_output[lastNonSpace] == '\n') {
      m_firstLineIndent = m_output.length() - (lastNonSpace + 1);
    } else {
      m_firstLineIndent = 0;
    }

    // Notice that the indent doesn't include the first line indent because it's
    // implicit, i.e. it is present in the input and so is copied into the
    // output anyhow.
    m_indent = Level();
  }

  // Get the indent for the first line of the paragraph, which is smaller than
  // the indent for the subsequent lines.
  string getFirstLineIndent() const { return string(m_firstLineIndent, ' '); }

  ~IndentGuard()
  {
    m_indent.clear();

    // Get rid of possible remaining extra indent, e.g. if there were any trailing
    // new lines: we shouldn't add the extra indent level to whatever follows
    // this paragraph.
    static const size_t lenIndentLevel = strlen(Level());
    if (m_output.length() > lenIndentLevel) {
      const size_t start = m_output.length() - lenIndentLevel;
      if (m_output.compare(start, string::npos, Level()) == 0)
          m_output.erase(start);
    }
  }

private:
  string& m_output;
  string& m_indent;
  unsigned m_firstLineIndent;

  IndentGuard(const IndentGuard&);
  IndentGuard& operator=(const IndentGuard&);
};

// Return the indent of the given multiline string, i.e. the maximal number of
// spaces present in the beginning of all its non-empty lines.
static size_t determineIndent(const string& s)
{
  size_t minIndent = static_cast<size_t>(-1);

  for (size_t lineStart = 0; lineStart < s.length();) {
    const size_t lineEnd = s.find('\n', lineStart);
    const size_t firstNonSpace = s.find_first_not_of(' ', lineStart);

    // If inequality doesn't hold, it means that this line contains only spaces
    // (notice that this works whether lineEnd is valid or string::npos), in
    // which case it doesn't matter when determining the indent.
    if (firstNonSpace < lineEnd) {
      // Here we can be sure firstNonSpace != string::npos.
      const size_t lineIndent = firstNonSpace - lineStart;
      if (lineIndent < minIndent)
        minIndent = lineIndent;
    }

    if (lineEnd == string::npos)
      break;

    lineStart = lineEnd + 1;
  }

  return minIndent;
}

static void trimWhitespace(string& s)
{
  const size_t lastNonSpace = s.find_last_not_of(' ');
  if (lastNonSpace != string::npos)
    s.erase(lastNonSpace + 1);
}

/* static */
PyDocConverter::TagHandlersMap::mapped_type
PyDocConverter::make_handler(tagHandler handler)
{
  return make_pair(handler, std::string());
}

/* static */
PyDocConverter::TagHandlersMap::mapped_type
PyDocConverter::make_handler(tagHandler handler, const char* arg)
{
  return make_pair(handler, arg);
}

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
  sectionTitles["note"] = "Notes: ";
  sectionTitles["remark"] = "Remarks: ";
  sectionTitles["remarks"] = "Remarks: ";
  sectionTitles["warning"] = "Warning: ";
//  sectionTitles["sa"] = "See also: ";
//  sectionTitles["see"] = "See also: ";
  sectionTitles["since"] = "Since: ";
  sectionTitles["todo"] = "TODO: ";
  sectionTitles["version"] = "Version: ";

  tagHandlers["a"] = make_handler(&PyDocConverter::handleTagWrap, "*");
  tagHandlers["b"] = make_handler(&PyDocConverter::handleTagWrap, "**");
  // \c command is translated as single quotes around next word
  tagHandlers["c"] = make_handler(&PyDocConverter::handleTagWrap, "``");
  tagHandlers["cite"] = make_handler(&PyDocConverter::handleTagWrap, "'");
  tagHandlers["e"] = make_handler(&PyDocConverter::handleTagWrap, "*");
  // these commands insert just a single char, some of them need to be escaped
  tagHandlers["$"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["@"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["\\"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["<"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers[">"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["&"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["#"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["%"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["~"] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["\""] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["."] = make_handler(&PyDocConverter::handleTagChar);
  tagHandlers["::"] = make_handler(&PyDocConverter::handleTagChar);
  // these commands are stripped out, and only their content is printed
  tagHandlers["attention"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["author"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["authors"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["brief"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["bug"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["code"] = make_handler(&PyDocConverter::handleCode);
  tagHandlers["copyright"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["date"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["deprecated"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["details"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["em"] = make_handler(&PyDocConverter::handleParagraph, " ");
  tagHandlers["example"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["exception"] =
  tagHandlers["throw"] =
  tagHandlers["throws"] = make_handler(&PyDocConverter::handleTagException);
  tagHandlers["htmlonly"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["invariant"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["latexonly"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["link"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["manonly"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["note"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["p"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["partofdescription"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["rtfonly"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["remark"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["remarks"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["sa"] = make_handler(&PyDocConverter::handleTagMessage, "See also: ");
  tagHandlers["see"] = make_handler(&PyDocConverter::handleTagMessage,
      "See also: ");
  tagHandlers["since"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["short"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["todo"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["version"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["verbatim"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["warning"] = make_handler(&PyDocConverter::handleParagraph);
  tagHandlers["xmlonly"] = make_handler(&PyDocConverter::handleParagraph);
  // these commands have special handlers
  tagHandlers["arg"] = make_handler(&PyDocConverter::handleTagMessage, "* ");
  tagHandlers["cond"] = make_handler(&PyDocConverter::handleTagMessage,
      "Conditional comment: ");
  tagHandlers["else"] = make_handler(&PyDocConverter::handleTagIf, "Else: ");
  tagHandlers["elseif"] = make_handler(&PyDocConverter::handleTagIf, "Else if: ");
  tagHandlers["endcond"] = make_handler(&PyDocConverter::handleTagMessage,
      "End of conditional comment.");
  tagHandlers["if"] = make_handler(&PyDocConverter::handleTagIf, "If: ");
  tagHandlers["ifnot"] = make_handler(&PyDocConverter::handleTagIf, "If not: ");
  tagHandlers["image"] = make_handler(&PyDocConverter::handleTagImage);
  tagHandlers["li"] = make_handler(&PyDocConverter::handleTagMessage, "* ");
  tagHandlers["overload"] = make_handler(&PyDocConverter::handleTagMessage,
      "This is an overloaded member function, provided for"
          " convenience.\nIt differs from the above function only in what"
          " argument(s) it accepts.");
  tagHandlers["par"] = make_handler(&PyDocConverter::handleTagPar);
  tagHandlers["param"] =
  tagHandlers["tparam"] = make_handler(&PyDocConverter::handleTagParam);
  tagHandlers["ref"] = make_handler(&PyDocConverter::handleTagRef);
  tagHandlers["result"] =
  tagHandlers["return"] =
  tagHandlers["returns"] = make_handler(&PyDocConverter::handleTagReturn);

  // this command just prints it's contents
  // (it is internal command of swig's parser, contains plain text)
  tagHandlers["plainstd::string"] = make_handler(&PyDocConverter::handlePlainString);
  tagHandlers["plainstd::endl"] = make_handler(&PyDocConverter::handleNewLine);
  tagHandlers["n"] = make_handler(&PyDocConverter::handleNewLine);

  // \f commands output literal Latex formula, which is still better than nothing.
  tagHandlers["f$"] =
  tagHandlers["f["] =
  tagHandlers["f{"] = make_handler(&PyDocConverter::handleMath);

  // HTML tags
  tagHandlers["<a"] = make_handler(&PyDocConverter::handleDoxyHtmlTag_A);
  tagHandlers["<b"] = make_handler(&PyDocConverter::handleDoxyHtmlTag2, "**");
  tagHandlers["<blockquote"] = make_handler(&PyDocConverter::handleDoxyHtmlTag_A,
      "Quote: ");
  tagHandlers["<body"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<br"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, "\n");

  // there is no formatting for this tag as it was deprecated in HTML 4.01 and
  // not used in HTML 5
  tagHandlers["<center"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<caption"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<code"] = make_handler(&PyDocConverter::handleDoxyHtmlTag2, "``");

  tagHandlers["<dl"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<dd"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, "    ");
  tagHandlers["<dt"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);

  tagHandlers["<dfn"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<div"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<em"] = make_handler(&PyDocConverter::handleDoxyHtmlTag2, "**");
  tagHandlers["<form"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<hr"] = make_handler(&PyDocConverter::handleDoxyHtmlTag,
      "--------------------------------------------------------------------\n");
  tagHandlers["<h1"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, "# ");
  tagHandlers["<h2"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, "## ");
  tagHandlers["<h3"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, "### ");
  tagHandlers["<i"] = make_handler(&PyDocConverter::handleDoxyHtmlTag2, "*");
  tagHandlers["<input"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<img"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, "Image:");
  tagHandlers["<li"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, "* ");
  tagHandlers["<meta"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<multicol"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<ol"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<p"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, "\n");
  tagHandlers["<pre"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<small"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<span"] = make_handler(&PyDocConverter::handleDoxyHtmlTag2, "'");
  tagHandlers["<strong"] = make_handler(&PyDocConverter::handleDoxyHtmlTag2, "**");

  // make a space between text and super/sub script.
  tagHandlers["<sub"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, " ");
  tagHandlers["<sup"] = make_handler(&PyDocConverter::handleDoxyHtmlTag, " ");

  tagHandlers["<table"] = make_handler(&PyDocConverter::handleDoxyHtmlTagNoParam);
  tagHandlers["<td"] = make_handler(&PyDocConverter::handleDoxyHtmlTag_td);
  tagHandlers["<th"] = make_handler(&PyDocConverter::handleDoxyHtmlTag_th);
  tagHandlers["<tr"] = make_handler(&PyDocConverter::handleDoxyHtmlTag_tr);
  tagHandlers["<tt"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<kbd"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<ul"] = make_handler(&PyDocConverter::handleDoxyHtmlTag);
  tagHandlers["<var"] = make_handler(&PyDocConverter::handleDoxyHtmlTag2, "*");

  // HTML entities
  tagHandlers["&copy"] = make_handler(&PyDocConverter::handleHtmlEntity, "(C)");
  tagHandlers["&trade"] = make_handler(&PyDocConverter::handleHtmlEntity, " TM");
  tagHandlers["&reg"] = make_handler(&PyDocConverter::handleHtmlEntity, "(R)");
  tagHandlers["&lt"] = make_handler(&PyDocConverter::handleHtmlEntity, "<");
  tagHandlers["&gt"] = make_handler(&PyDocConverter::handleHtmlEntity, ">");
  tagHandlers["&amp"] = make_handler(&PyDocConverter::handleHtmlEntity, "&");
  tagHandlers["&apos"] = make_handler(&PyDocConverter::handleHtmlEntity, "'");
  tagHandlers["&quot"] = make_handler(&PyDocConverter::handleHtmlEntity, "\"");
  tagHandlers["&lsquo"] = make_handler(&PyDocConverter::handleHtmlEntity, "`");
  tagHandlers["&rsquo"] = make_handler(&PyDocConverter::handleHtmlEntity, "'");
  tagHandlers["&ldquo"] = make_handler(&PyDocConverter::handleHtmlEntity, "\"");
  tagHandlers["&rdquo"] = make_handler(&PyDocConverter::handleHtmlEntity, "\"");
  tagHandlers["&ndash"] = make_handler(&PyDocConverter::handleHtmlEntity, "-");
  tagHandlers["&mdash"] = make_handler(&PyDocConverter::handleHtmlEntity, "--");
  tagHandlers["&nbsp"] = make_handler(&PyDocConverter::handleHtmlEntity, " ");
  tagHandlers["&times"] = make_handler(&PyDocConverter::handleHtmlEntity, "x");
  tagHandlers["&minus"] = make_handler(&PyDocConverter::handleHtmlEntity, "-");
  tagHandlers["&sdot"] = make_handler(&PyDocConverter::handleHtmlEntity, ".");
  tagHandlers["&sim"] = make_handler(&PyDocConverter::handleHtmlEntity, "~");
  tagHandlers["&le"] = make_handler(&PyDocConverter::handleHtmlEntity, "<=");
  tagHandlers["&ge"] = make_handler(&PyDocConverter::handleHtmlEntity, ">=");
  tagHandlers["&larr"] = make_handler(&PyDocConverter::handleHtmlEntity, "<--");
  tagHandlers["&rarr"] = make_handler(&PyDocConverter::handleHtmlEntity, "-->");
}

PyDocConverter::PyDocConverter(int flags) :
    DoxygenTranslator(flags), m_tableLineLen(0), m_prevRowIsTH(
        false)
{
  fillStaticTables();
}

// Return the type as it should appear in the output documentation.
static
std::string getPyDocType(Node* n, const_String_or_char_ptr lname = "")
{
  std::string type;

  String *s = Swig_typemap_lookup("doctype", n, lname, 0);
  if (!s)
    s = SwigType_str(Getattr(n, "type"), "");

  if (Language::classLookup(s)) {
    // In Python C++ namespaces are flattened, so remove all but last component
    // of the name.
    String * const last = Swig_scopename_last(s);

    // We are not actually sure whether it's a documented class or not, but
    // there doesn't seem to be any harm in making it a reference if it isn't,
    // while there is a lot of benefit in having a hyperlink if it is.
    type = ":py:class:`";
    type += Char (last);
    type += "`";

    Delete(last);
  } else {
    type = Char(s);
  }

  Delete(s);

  return type;
}

std::string PyDocConverter::getParamType(std::string param)
{
  std::string type;

  ParmList *plist = CopyParmList(Getattr(currentNode, "parms"));
  for (Parm *p = plist; p;p = nextSibling(p)) {
    String* pname = Getattr(p, "name");
    if (Char (pname) != param)
      continue;

    type = getPyDocType(p, pname);
    break;
  }
  Delete(plist);
  return type;
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
                                     const std::string&)
{
  translatedComment += translateSubtree(tag);
}

void PyDocConverter::handleMath(DoxygenEntity &tag,
                                std::string &translatedComment,
                                const std::string& arg)
{
  IndentGuard indent(translatedComment, m_indent);

  // Only \f$ is translated to inline formulae, \f[ and \f{ are for the block ones.
  const bool inlineFormula = tag.typeOfEntity == "f$";

  string formulaNL;

  if (inlineFormula) {
    translatedComment += ":math:`";
  } else {
    trimWhitespace(translatedComment);
    translatedComment += '\n';

    const string formulaIndent = indent.getFirstLineIndent();
    translatedComment += formulaIndent;
    translatedComment += ".. math::\n";

    formulaNL = '\n';
    formulaNL += formulaIndent;
    formulaNL += m_indent;
    translatedComment += formulaNL;
  }

  std::string formula;
  handleTagVerbatim(tag, formula, arg);

  // It is important to ensure that we have no spaces around the inline math
  // contents, so strip them.
  const size_t start = formula.find_first_not_of(" \t\n");
  const size_t end = formula.find_last_not_of(" \t\n");
  if (start != std::string::npos) {
    for (size_t n = start; n <= end; n++) {
      if (formula[n] == '\n') {
        // New lines must be suppressed in inline maths and indented in the block ones.
        if (!inlineFormula)
          translatedComment += formulaNL;
      } else {
        // Just copy everything else.
        translatedComment += formula[n];
      }
    }
  }

  if (inlineFormula) {
    translatedComment += "`";
  } else {
    translatedComment += '\n';
  }
}

void PyDocConverter::handleCode(DoxygenEntity &tag,
                                std::string &translatedComment,
                                const std::string &arg)
{
  IndentGuard indent(translatedComment, m_indent);

  trimWhitespace(translatedComment);
  translatedComment += '\n';

  // Use the current indent for the code-block line itself.
  string codeIndent = indent.getFirstLineIndent();
  translatedComment += codeIndent;

  // Go out on a limb and assume that examples in the C or C++ sources use C++.
  // In the worst case, we'll highlight C code using C++ syntax which is not a
  // big deal (TODO: handle Doxygen code command language argument).
  translatedComment += ".. code-block:: c++\n\n";

  // For now on, use extra indent level for all the subsequent lines.
  codeIndent += m_indent;

  std::string code;
  handleTagVerbatim(tag, code, arg);

  translatedComment += codeIndent;
  for (size_t n = 0; n < code.length(); n++) {
    if (code[n] == '\n') {
      // Don't leave trailing white space, this results in PEP8 validation
      // errors in Python code (which are performed by our own unit tests).
      trimWhitespace(translatedComment);
      translatedComment += '\n';

      // Ensure that we indent all the lines by the code indent.
      translatedComment += codeIndent;
    } else {
      // Just copy everything else.
      translatedComment += code[n];
    }
  }

  trimWhitespace(translatedComment);
  if (*translatedComment.rbegin() != '\n')
    translatedComment += '\n';
}

void PyDocConverter::handlePlainString(DoxygenEntity& tag,
                                       std::string& translatedComment,
                                       const std::string&)
{
  translatedComment += tag.data;
  if (tag.data.size() && tag.data[tag.data.size() - 1] != ' ')
    translatedComment += "";
}

void PyDocConverter::handleTagVerbatim(DoxygenEntity& tag,
                                       std::string& translatedComment,
                                       const std::string &arg)
{
  translatedComment += arg + " ";
  for (DoxygenEntityListCIt it = tag.entityList.begin();
      it != tag.entityList.end(); it++) {
    translatedComment += it->data;
  }
}

void PyDocConverter::handleTagMessage(DoxygenEntity& tag,
                                      std::string& translatedComment,
                                      const std::string &arg)
{
  translatedComment += arg;
  handleParagraph(tag, translatedComment);
}

void PyDocConverter::handleTagChar(DoxygenEntity& tag,
                                   std::string& translatedComment,
                                   const std::string&)
{
  translatedComment += tag.typeOfEntity;
}

void PyDocConverter::handleTagIf(DoxygenEntity& tag,
                                 std::string& translatedComment,
                                 const std::string &arg)
{
  translatedComment += arg;
  if (tag.entityList.size()) {
    translatedComment += tag.entityList.begin()->data;
    tag.entityList.pop_front();
    translatedComment += " {" + translateSubtree(tag) + "}";
  }
}

void PyDocConverter::handleTagPar(DoxygenEntity& tag,
                                  std::string& translatedComment,
                                  const std::string&)
{
  translatedComment += "Title: ";
  if (tag.entityList.size())
    translatedComment += tag.entityList.begin()->data;
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment);
}

void PyDocConverter::handleTagImage(DoxygenEntity& tag,
                                    std::string& translatedComment,
                                    const std::string&)
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
                                    const std::string&)
{
  if (tag.entityList.size() < 2)
    return;

  IndentGuard indent(translatedComment, m_indent);

  DoxygenEntity paramNameEntity = *tag.entityList.begin();
  tag.entityList.pop_front();

  const std::string& paramName = paramNameEntity.data;

  const std::string paramType = getParamType(paramName);
  if (!paramType.empty()) {
    translatedComment += ":type " + paramName + ": " + paramType + "\n";
    translatedComment += indent.getFirstLineIndent();
  }

  translatedComment += ":param " + paramName + ":";

  handleParagraph(tag, translatedComment);
}


void PyDocConverter::handleTagReturn(DoxygenEntity &tag,
                                     std::string &translatedComment,
                                     const std::string &)
{
  IndentGuard indent(translatedComment, m_indent);

  const std::string pytype = getPyDocType(currentNode);
  if (!pytype.empty()) {
    translatedComment += ":rtype: ";
    translatedComment += pytype;
    translatedComment += "\n";
    translatedComment += indent.getFirstLineIndent();
  }

  translatedComment += ":return: ";
  handleParagraph(tag, translatedComment);
}


void PyDocConverter::handleTagException(DoxygenEntity &tag,
                                        std::string &translatedComment,
                                        const std::string &)
{
  IndentGuard indent(translatedComment, m_indent);

  translatedComment += ":raises: ";
  handleParagraph(tag, translatedComment);
}


void PyDocConverter::handleTagRef(DoxygenEntity& tag,
                                  std::string& translatedComment,
                                  const std::string&)
{
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
                                   const std::string &arg)
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
                                       const std::string &arg)
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
                                              const std::string &arg)
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
                                         const std::string &arg)
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
                                        const std::string &arg)
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
                                          const std::string &)
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
                                          const std::string &)
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
                                          const std::string &)
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
                                      const std::string &arg)
{
  // html entities
  translatedComment += arg;
}

void PyDocConverter::handleNewLine(DoxygenEntity&,
                                   std::string& translatedComment,
                                   const std::string&)
{
  trimWhitespace(translatedComment);

  translatedComment += "\n";
  if (!m_indent.empty())
    translatedComment += m_indent;
}

String *PyDocConverter::makeDocumentation(Node *n)
{
  String *documentation;
  std::string pyDocString;

  // store the node, we may need it later
  currentNode = n;

  // for overloaded functions we must concat documentation for underlying overloads
  if (Getattr(n, "sym:overloaded")) {
    // rewind to the first overload
    while (Getattr(n, "sym:previousSibling"))
      n = Getattr(n, "sym:previousSibling");

    std::vector<std::string> allDocumentation;

    // minimal indent of any documentation comments, not initialized yet
    size_t minIndent = static_cast<size_t>(-1);

    // for each real method (not a generated overload) append the documentation
    string oneDoc;
    while (n) {
      documentation = getDoxygenComment(n);
      if (!Swig_is_generated_overload(n) && documentation) {
        currentNode = n;
        if (GetFlag(n, "feature:doxygen:notranslate")) {
          String *comment = NewString("");
          Append(comment, documentation);
          Replaceall(comment, "\n *", "\n");
          oneDoc = Char (comment);
          Delete(comment);
        } else {
          std::list<DoxygenEntity> entityList = parser.createTree(n, documentation);
          DoxygenEntity root("root", entityList);

          oneDoc = translateSubtree(root);
        }

        // find the minimal indent of this documentation comment, we need to
        // ensure that the entire comment is indented by it to avoid the leading
        // parts of the other lines being simply discarded later
        const size_t oneIndent = determineIndent(oneDoc);
        if (oneIndent < minIndent)
          minIndent = oneIndent;

        allDocumentation.push_back(oneDoc);
      }
      n = Getattr(n, "sym:nextSibling");
    }

    // construct final documentation string
    if (allDocumentation.size() > 1) {
      string indentStr;
      if (minIndent != static_cast<size_t>(-1))
        indentStr.assign(minIndent, ' ');

      std::ostringstream concatDocString;
      for (size_t realOverloadCount = 0;
          realOverloadCount < allDocumentation.size();
          realOverloadCount++) {
        if (realOverloadCount != 0) {
          // separate it from the preceding one.
          concatDocString << "\n" << indentStr << "|\n\n";
        }

        oneDoc = allDocumentation[realOverloadCount];
        trimWhitespace(oneDoc);
        concatDocString << indentStr << "*Overload " << (realOverloadCount + 1) << ":*\n"
                        << oneDoc;
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
        std::list<DoxygenEntity> entityList = parser.createTree(n, documentation);
        DoxygenEntity root("root", entityList);
        pyDocString = translateSubtree(root);
      }
    }
  }

  // if we got something log the result
  if (!pyDocString.empty()) {

    // remove the last '\n' since additional one is added during writing to file
    if (pyDocString[pyDocString.size() - 1] == '\n') {
      pyDocString.erase(pyDocString.size() - 1);
    }

    if (m_flags & debug_translator) {
      std::cout << "\n---RESULT IN PYDOC---" << std::endl;
      std::cout << pyDocString;
      std::cout << std::endl;
    }
  }

  return NewString(pyDocString.c_str());
}
