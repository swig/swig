/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * swiftdoc.cxx
 *
 * Translate Doxygen comments into Swift documentation comments (Swift Markup).
 * Modelled on javadoc.cxx, but the output is a markdown body with Swift field
 * callouts (- Parameter:, - Returns:, - Throws:, - Note:, ...) instead of the
 * HTML-based JavaDoc.  Every Doxygen command is handled so nothing is emitted in
 * a form Swift would not understand; constructs without a markdown equivalent are
 * dropped while their textual content is preserved.
 * ----------------------------------------------------------------------------- */

#include "swiftdoc.h"
#include "doxyparser.h"
#include <iostream>
#include <list>
#include <string>
#include "swigmod.h"

// define static tables, they are filled in SwiftDocConverter's constructor
std::map<std::string, std::pair<SwiftDocConverter::tagHandler, std::string> > SwiftDocConverter::tagHandlers;

// original C++ name -> renamed Swift name; populated by the swift module when
// -autorename is in effect (declared in swiftdoc.h).
std::map<std::string, std::string> swiftRenamedSymbols;

using std::list;
using std::string;

// In-comment newline: keeps the ' * ' left margin of the /** ... */ block.
static const char *const SWIFTDOC_NL = "\n * ";

// Append SWIFTDOC_NL only if we are not already at the start of a fresh comment
// line (used so block callouts like "- Note:" always begin a markdown list item).
static void ensureLineStart(std::string &s) {
  if (s.empty())
    return;
  if (s.size() >= 2 && s[s.size() - 1] == ' ' && s[s.size() - 2] == '*')
    return;
  s += SWIFTDOC_NL;
}

void SwiftDocConverter::fillStaticTables() {
  if (tagHandlers.size())  // fill only once
    return;

  // inline emphasis doxygen commands -> markdown markers
  tagHandlers["a"] = make_pair(&SwiftDocConverter::handleTagEmphasis, "*");
  tagHandlers["e"] = make_pair(&SwiftDocConverter::handleTagEmphasis, "*");
  tagHandlers["em"] = make_pair(&SwiftDocConverter::handleTagEmphasis, "*");
  tagHandlers["cite"] = make_pair(&SwiftDocConverter::handleTagEmphasis, "*");
  tagHandlers["b"] = make_pair(&SwiftDocConverter::handleTagEmphasis, "**");
  tagHandlers["c"] = make_pair(&SwiftDocConverter::handleTagEmphasis, "`");
  tagHandlers["p"] = make_pair(&SwiftDocConverter::handleTagEmphasis, "`");
  // list-item doxygen commands -> markdown list item
  tagHandlers["arg"] = make_pair(&SwiftDocConverter::handleTagListItem, "");
  tagHandlers["li"] = make_pair(&SwiftDocConverter::handleTagListItem, "");

  // single-char escape commands: emit the literal char (markdown needs no escaping here)
  tagHandlers["$"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["@"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["\\"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["<"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers[">"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["&"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["#"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["%"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["~"] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["\""] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["."] = make_pair(&SwiftDocConverter::handleTagChar, "");
  tagHandlers["::"] = make_pair(&SwiftDocConverter::handleTagChar, "");

  // commands that contribute only their content (summary / detailed description)
  tagHandlers["brief"] = make_pair(&SwiftDocConverter::handleParagraph, "");
  tagHandlers["details"] = make_pair(&SwiftDocConverter::handleParagraph, "");
  tagHandlers["short"] = make_pair(&SwiftDocConverter::handleParagraph, "");
  tagHandlers["partofdescription"] = make_pair(&SwiftDocConverter::handleParagraph, "");
  tagHandlers["htmlonly"] = make_pair(&SwiftDocConverter::handleParagraph, "");
  tagHandlers["latexonly"] = make_pair(&SwiftDocConverter::handleParagraph, "");
  tagHandlers["manonly"] = make_pair(&SwiftDocConverter::handleParagraph, "");
  tagHandlers["rtfonly"] = make_pair(&SwiftDocConverter::handleParagraph, "");
  tagHandlers["xmlonly"] = make_pair(&SwiftDocConverter::handleParagraph, "");

  // structured commands -> Swift callouts ("- <Name>: ...")
  tagHandlers["note"] = make_pair(&SwiftDocConverter::handleTagMessage, "Note: ");
  tagHandlers["warning"] = make_pair(&SwiftDocConverter::handleTagMessage, "Warning: ");
  tagHandlers["attention"] = make_pair(&SwiftDocConverter::handleTagMessage, "Attention: ");
  tagHandlers["remark"] = make_pair(&SwiftDocConverter::handleTagMessage, "Remark: ");
  tagHandlers["remarks"] = make_pair(&SwiftDocConverter::handleTagMessage, "Remark: ");
  tagHandlers["bug"] = make_pair(&SwiftDocConverter::handleTagMessage, "Bug: ");
  tagHandlers["todo"] = make_pair(&SwiftDocConverter::handleTagMessage, "ToDo: ");
  tagHandlers["invariant"] = make_pair(&SwiftDocConverter::handleTagMessage, "Invariant: ");
  tagHandlers["pre"] = make_pair(&SwiftDocConverter::handleTagMessage, "Precondition: ");
  tagHandlers["post"] = make_pair(&SwiftDocConverter::handleTagMessage, "Postcondition: ");
  tagHandlers["copyright"] = make_pair(&SwiftDocConverter::handleTagMessage, "Copyright: ");
  tagHandlers["date"] = make_pair(&SwiftDocConverter::handleTagMessage, "Date: ");
  tagHandlers["since"] = make_pair(&SwiftDocConverter::handleTagMessage, "Since: ");
  tagHandlers["version"] = make_pair(&SwiftDocConverter::handleTagMessage, "Version: ");
  tagHandlers["author"] = make_pair(&SwiftDocConverter::handleTagMessage, "Author: ");
  tagHandlers["authors"] = make_pair(&SwiftDocConverter::handleTagMessage, "Authors: ");
  tagHandlers["deprecated"] = make_pair(&SwiftDocConverter::handleTagMessage, "Warning: Deprecated. ");
  tagHandlers["overload"] = make_pair(&SwiftDocConverter::handleTagMessage,
                                      "Note: This is an overloaded member function, provided for"
                                      " convenience. It differs from the above function only in what"
                                      " argument(s) it accepts.");
  tagHandlers["cond"] = make_pair(&SwiftDocConverter::handleTagMessage, "Conditional comment: ");
  tagHandlers["endcond"] = make_pair(&SwiftDocConverter::handleTagMessage, "End of conditional comment.");

  // function/parameter/return/throw/see
  tagHandlers["param"] = make_pair(&SwiftDocConverter::handleTagParam, "");
  tagHandlers["tparam"] = make_pair(&SwiftDocConverter::handleTagParam, "");
  tagHandlers["return"] = make_pair(&SwiftDocConverter::handleTagReturn, "");
  tagHandlers["returns"] = make_pair(&SwiftDocConverter::handleTagReturn, "");
  tagHandlers["result"] = make_pair(&SwiftDocConverter::handleTagReturn, "");
  tagHandlers["throw"] = make_pair(&SwiftDocConverter::handleTagThrows, "");
  tagHandlers["throws"] = make_pair(&SwiftDocConverter::handleTagThrows, "");
  tagHandlers["exception"] = make_pair(&SwiftDocConverter::handleTagThrows, "");
  tagHandlers["see"] = make_pair(&SwiftDocConverter::handleTagSee, "");
  tagHandlers["sa"] = make_pair(&SwiftDocConverter::handleTagSee, "");
  tagHandlers["ref"] = make_pair(&SwiftDocConverter::handleTagRef, "");
  tagHandlers["link"] = make_pair(&SwiftDocConverter::handleTagLink, "");

  // special handlers
  tagHandlers["code"] = make_pair(&SwiftDocConverter::handleTagCode, "");
  tagHandlers["verbatim"] = make_pair(&SwiftDocConverter::handleTagCode, "");
  tagHandlers["if"] = make_pair(&SwiftDocConverter::handleTagIf, "If: ");
  tagHandlers["ifnot"] = make_pair(&SwiftDocConverter::handleTagIf, "If not: ");
  tagHandlers["else"] = make_pair(&SwiftDocConverter::handleTagIf, "Else: ");
  tagHandlers["elseif"] = make_pair(&SwiftDocConverter::handleTagIf, "Else if: ");
  tagHandlers["par"] = make_pair(&SwiftDocConverter::handleTagPar, "");
  tagHandlers["image"] = make_pair(&SwiftDocConverter::handleTagImage, "");

  // \f LaTeX formulae - emitted verbatim, best effort
  tagHandlers["f$"] = make_pair(&SwiftDocConverter::handleTagVerbatim, "");
  tagHandlers["f["] = make_pair(&SwiftDocConverter::handleTagVerbatim, "");
  tagHandlers["f{"] = make_pair(&SwiftDocConverter::handleTagVerbatim, "");

  // internal parser tokens
  tagHandlers["plainstd::string"] = make_pair(&SwiftDocConverter::handlePlainString, "");
  tagHandlers["plainstd::endl"] = make_pair(&SwiftDocConverter::handleNewLine, "");
  tagHandlers["n"] = make_pair(&SwiftDocConverter::handleNewLine, "");

  // HTML tags recognised by Doxygen -> markdown (unknown ones drop the tag, keep text)
  const char *htmlTags[] = {"<a",     "<b",    "<blockquote", "<body", "<br", "<center", "<caption", "<code", "<dd",     "<dfn",   "<div",
                            "<dl",    "<dt",   "<em",         "<form", "<hr", "<h1",     "<h2",      "<h3",   "<i",      "<input", "<img",
                            "<li",    "<meta", "<multicol",   "<ol",   "<p",  "<pre",    "<small",   "<span", "<strong", "<sub",   "<sup",
                            "<table", "<td",   "<th",         "<tr",   "<tt", "<kbd",    "<ul",      "<var",  0};
  for (int i = 0; htmlTags[i]; i++)
    tagHandlers[htmlTags[i]] = make_pair(&SwiftDocConverter::handleDoxyHtmlTag, std::string(htmlTags[i]));

  // HTML entities -> the literal character
  const char *htmlEntities[] = {"&copy",  "&trade", "&reg",   "&lt",    "&gt",   "&amp", "&apos", "&quot", "&lsquo", "&rsquo", "&ldquo",  "&rdquo", "&ndash",
                                "&mdash", "&nbsp",  "&times", "&minus", "&sdot", "&sim", "&le",   "&ge",   "&larr",  "&rarr",  "&hellip", 0};
  for (int i = 0; htmlEntities[i]; i++)
    tagHandlers[htmlEntities[i]] = make_pair(&SwiftDocConverter::handleHtmlEntity, std::string(htmlEntities[i]));
}

SwiftDocConverter::SwiftDocConverter(int flags) : DoxygenTranslator(flags), currentNode(0) {
  fillStaticTables();
}

bool SwiftDocConverter::paramExists(std::string param) {
  if (GetFlag(currentNode, "feature:doxygen:nostripparams")) {
    return true;
  }

  ParmList *plist = CopyParmList(Getattr(currentNode, "parms"));
  for (Parm *p = plist; p;) {
    if (Getattr(p, "name") && Char(Getattr(p, "name")) == param) {
      Delete(plist);
      return true;
    }
    p = nextSibling(p);
  }
  Delete(plist);
  return false;
}

std::string SwiftDocConverter::translateSubtree(DoxygenEntity &doxygenEntity) {
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

void SwiftDocConverter::translateEntity(DoxygenEntity &tag, std::string &translatedComment) {
  std::map<std::string, std::pair<tagHandler, std::string> >::iterator it;
  it = tagHandlers.find(getBaseCommand(tag.typeOfEntity));

  if (it != tagHandlers.end()) {
    (this->*(it->second.first))(tag, translatedComment, it->second.second);
  }
  // No handler: silently drop the command marker. Its content (sibling entities)
  // is still translated, so no text is lost. This keeps "accept all features" true.
}

void SwiftDocConverter::handleTagEmphasis(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  if (tag.entityList.size()) {  // do not emit empty markers
    std::string content = translateSubtree(tag);
    size_t wsPos = content.find_last_not_of("\n\t ");
    if (wsPos != std::string::npos)
      translatedComment += arg + content.substr(0, wsPos + 1) + arg + content.substr(wsPos + 1);
    else
      translatedComment += arg + content + arg + " ";
  }
}

void SwiftDocConverter::handleTagListItem(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  ensureLineStart(translatedComment);
  translatedComment += "- ";
  handleParagraph(tag, translatedComment, dummy);
}

void SwiftDocConverter::handleTagChar(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  if (arg.size())
    translatedComment += arg;
  else
    translatedComment += tag.typeOfEntity;
}

void SwiftDocConverter::handleParagraph(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  translatedComment += translateSubtree(tag);
}

void SwiftDocConverter::handlePlainString(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  translatedComment += tag.data;
}

void SwiftDocConverter::handleNewLine(DoxygenEntity &, std::string &translatedComment, std::string &) {
  translatedComment += SWIFTDOC_NL;
}

void SwiftDocConverter::handleTagMessage(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  std::string dummy;
  ensureLineStart(translatedComment);
  translatedComment += "- " + arg;
  handleParagraph(tag, translatedComment, dummy);
}

void SwiftDocConverter::handleTagParam(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  if (!tag.entityList.size())
    return;
  if (!paramExists(tag.entityList.begin()->data))
    return;

  ensureLineStart(translatedComment);
  translatedComment += "- Parameter ";
  translatedComment += tag.entityList.begin()->data;
  translatedComment += ": ";
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
}

void SwiftDocConverter::handleTagReturn(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  ensureLineStart(translatedComment);
  translatedComment += "- Returns: ";
  handleParagraph(tag, translatedComment, dummy);
}

void SwiftDocConverter::handleTagThrows(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  if (!tag.entityList.size())
    return;

  ensureLineStart(translatedComment);
  translatedComment += "- Throws: ";
  // @throws Type description -> keep the type, then the description
  translatedComment += tag.entityList.begin()->data + " ";
  tag.entityList.pop_front();
  handleParagraph(tag, translatedComment, dummy);
}

void SwiftDocConverter::handleTagSee(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  if (!tag.entityList.size())
    return;

  string ref;
  for (list<DoxygenEntity>::iterator it = tag.entityList.begin(); it != tag.entityList.end(); it++) {
    if (it->typeOfEntity == "plainstd::endl")
      continue;
    ref += it->data;
  }
  // strip an empty list (only endlines)
  if (ref.find_first_not_of(" \t") == string::npos)
    return;

  ensureLineStart(translatedComment);
  translatedComment += "- SeeAlso: `" + ref + "`";
}

void SwiftDocConverter::handleTagRef(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  if (!tag.entityList.size())
    return;

  string anchor = tag.entityList.begin()->data;
  tag.entityList.pop_front();
  string anchorText = anchor;
  if (!tag.entityList.empty())
    anchorText = tag.entityList.begin()->data;
  // Swift markup has no cross-reference syntax for arbitrary anchors; render the
  // visible text and keep the target as inline code so the reader still sees it.
  translatedComment += anchorText + " (`" + anchor + "`)";
}

void SwiftDocConverter::handleTagLink(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  if (!tag.entityList.size())
    return;

  string linkObject = tag.entityList.begin()->data;
  tag.entityList.pop_front();
  translatedComment += "`" + linkObject + "` ";
  handleParagraph(tag, translatedComment, dummy);
}

void SwiftDocConverter::handleTagCode(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  // Render @code/@verbatim as a fenced markdown code block.
  ensureLineStart(translatedComment);
  translatedComment += "```";
  translatedComment += SWIFTDOC_NL;
  std::string content = translateSubtree(tag);
  translatedComment += content;
  ensureLineStart(translatedComment);
  translatedComment += "```";
  translatedComment += SWIFTDOC_NL;
}

void SwiftDocConverter::handleTagVerbatim(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  translatedComment += arg;
  for (DoxygenEntityListCIt it = tag.entityList.begin(); it != tag.entityList.end(); it++) {
    translatedComment += it->data;
  }
}

void SwiftDocConverter::handleTagIf(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  ensureLineStart(translatedComment);
  translatedComment += "- " + arg;
  if (tag.entityList.size()) {
    translatedComment += tag.entityList.begin()->data;
    tag.entityList.pop_front();
    translatedComment += " " + translateSubtree(tag);
  }
}

void SwiftDocConverter::handleTagPar(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  std::string dummy;
  ensureLineStart(translatedComment);
  if (tag.entityList.size()) {
    // optional title -> bold
    translatedComment += "**" + tag.entityList.begin()->data + "**";
    translatedComment += SWIFTDOC_NL;
    tag.entityList.pop_front();
    handleParagraph(tag, translatedComment, dummy);
  }
}

void SwiftDocConverter::handleTagImage(DoxygenEntity &tag, std::string &translatedComment, std::string &) {
  if (tag.entityList.size() < 2)
    return;

  std::list<DoxygenEntity>::iterator it = tag.entityList.begin();
  if (it->data != "html")
    return;
  it++;
  string file = it->data;
  it++;
  string title;
  if (it != tag.entityList.end())
    title = it->data;

  // strip surrounding quotes from file/title
  if (file.size() >= 2 && file[0] == '"' && file[file.size() - 1] == '"')
    file = file.substr(1, file.size() - 2);
  if (title.size() >= 2 && title[0] == '"' && title[title.size() - 1] == '"')
    title = title.substr(1, title.size() - 2);

  translatedComment += "![" + title + "](" + file + ")";
}

void SwiftDocConverter::handleDoxyHtmlTag(DoxygenEntity &tag, std::string &translatedComment, std::string &arg) {
  // arg is the tag opener, e.g. "<b"; tag.data is "/" for a closing tag, attributes otherwise.
  std::string name = arg.substr(1);
  bool closing = (tag.data == "/");

  if (name == "b" || name == "strong") {
    translatedComment += "**";
  } else if (name == "i" || name == "em" || name == "cite") {
    translatedComment += "*";
  } else if (name == "code" || name == "tt" || name == "kbd") {
    translatedComment += "`";
  } else if (name == "br") {
    translatedComment += SWIFTDOC_NL;
  } else if (name == "p") {
    if (!closing) {
      translatedComment += SWIFTDOC_NL;
      translatedComment += SWIFTDOC_NL;
    }
  } else if (name == "li") {
    if (!closing) {
      ensureLineStart(translatedComment);
      translatedComment += "- ";
    }
  } else if (name == "hr") {
    ensureLineStart(translatedComment);
    translatedComment += "---";
    translatedComment += SWIFTDOC_NL;
  }
  // all other tags (a, ul, ol, dl, table, div, span, ...) are dropped; the text
  // between them is carried by sibling entities and therefore preserved.
}

void SwiftDocConverter::handleHtmlEntity(DoxygenEntity &, std::string &translatedComment, std::string &arg) {
  if (arg == "&lt")
    translatedComment += "<";
  else if (arg == "&gt")
    translatedComment += ">";
  else if (arg == "&amp")
    translatedComment += "&";
  else if (arg == "&apos")
    translatedComment += "'";
  else if (arg == "&quot")
    translatedComment += "\"";
  else if (arg == "&nbsp")
    translatedComment += " ";
  else if (arg == "&copy")
    translatedComment += "©";
  else if (arg == "&reg")
    translatedComment += "®";
  else if (arg == "&trade")
    translatedComment += "™";
  else if (arg == "&ndash")
    translatedComment += "–";
  else if (arg == "&mdash")
    translatedComment += "—";
  else if (arg == "&times")
    translatedComment += "×";
  else if (arg == "&minus")
    translatedComment += "−";
  else if (arg == "&sdot")
    translatedComment += "⋅";
  else if (arg == "&sim")
    translatedComment += "~";
  else if (arg == "&le")
    translatedComment += "≤";
  else if (arg == "&ge")
    translatedComment += "≥";
  else if (arg == "&larr")
    translatedComment += "←";
  else if (arg == "&rarr")
    translatedComment += "→";
  else if (arg == "&hellip")
    translatedComment += "…";
  else if (arg == "&lsquo")
    translatedComment += "'";
  else if (arg == "&rsquo")
    translatedComment += "'";
  else if (arg == "&ldquo")
    translatedComment += "\"";
  else if (arg == "&rdquo")
    translatedComment += "\"";
  else
    translatedComment += arg.substr(1);  // fallback: drop the leading '&'
}

/* Move trailing line endings of child entities up to the parent so that
 * paragraph breaks land between commands rather than inside them. Same approach
 * as javadoc.cxx. */
int SwiftDocConverter::shiftEndlinesUpTree(DoxygenEntity &root, int level) {
  DoxygenEntityListIt it = root.entityList.begin();
  while (it != root.entityList.end()) {
    int ret = shiftEndlinesUpTree(*it, level + 1);
    it++;
    for (int i = 0; i < ret; i++) {
      root.entityList.insert(it, DoxygenEntity("plainstd::endl"));
    }
  }

  if (!level) {
    return 0;
  }

  int removedCount = 0;
  while (!root.entityList.empty() && root.entityList.rbegin()->typeOfEntity == "plainstd::endl") {
    root.entityList.pop_back();
    removedCount++;
  }
  return removedCount;
}

/* Wrap the translated body into a documentation comment block, ensuring every line
 * carries the ' * ' margin. Reused from the javadoc approach; valid Swift Markup. */
std::string SwiftDocConverter::indentAndInsertAsterisks(const string &doc) {
  size_t idx = doc.find('\n');
  size_t indent = 0;
  bool singleLineComment = idx == string::npos;
  if (idx != string::npos) {
    size_t nonspaceIdx = doc.find_first_not_of(" \t", idx + 1);
    if (nonspaceIdx != string::npos) {
      indent = nonspaceIdx - idx;
    }
  }

  if (indent == 0) {
    indent = 1;
  }
  string indentStr(indent - 1, ' ');
  string translatedStr = indentStr + "/**";
  if (indent > 1) {
    translatedStr = translatedStr.substr(1);
  }

  translatedStr += doc;

  idx = translatedStr.find('\n');
  while (idx != string::npos) {
    size_t nonspaceIdx = translatedStr.find_first_not_of(" \t", idx + 1);
    if (nonspaceIdx != string::npos && translatedStr[nonspaceIdx] != '*') {
      if (translatedStr[nonspaceIdx] != '\n') {
        translatedStr = translatedStr.substr(0, nonspaceIdx) + "* " + translatedStr.substr(nonspaceIdx);
      } else {
        translatedStr = translatedStr.substr(0, idx + 1) + indentStr + "* " + translatedStr.substr(nonspaceIdx);
      }
    }
    idx = translatedStr.find('\n', nonspaceIdx);
  }

  size_t nonspaceEndIdx = translatedStr.find_last_not_of(" \t");
  if (nonspaceEndIdx != string::npos) {
    if (translatedStr[nonspaceEndIdx] != '\n') {
      if (!singleLineComment)
        translatedStr += '\n';
    } else {
      translatedStr = translatedStr.substr(0, nonspaceEndIdx + 1);
    }
  }
  translatedStr += indentStr + "*/\n";

  return translatedStr;
}

String *SwiftDocConverter::makeDocumentation(Node *node) {
  String *documentation = getDoxygenComment(node);

  if (documentation == NULL) {
    return NewString("");
  }

  if (GetFlag(node, "feature:doxygen:notranslate")) {
    string doc = Char(documentation);
    string translatedStr = indentAndInsertAsterisks(doc);
    return NewString(translatedStr.c_str());
  }

  DoxygenEntityList entityList = parser.createTree(node, documentation);

  if (m_flags & debug_translator) {
    std::cout << "---RESORTED LIST---" << std::endl;
    printTree(entityList);
  }

  currentNode = node;

  std::string swiftDocString = "/**\n * ";

  DoxygenEntity root("root", entityList);
  shiftEndlinesUpTree(root);

  // strip leading and trailing line endings
  while (!root.entityList.empty() && root.entityList.begin()->typeOfEntity == "plainstd::endl") {
    root.entityList.pop_front();
  }
  while (!root.entityList.empty() && root.entityList.rbegin()->typeOfEntity == "plainstd::endl") {
    root.entityList.pop_back();
  }

  swiftDocString += translateSubtree(root);
  swiftDocString += "\n */\n";

  /* Rewrite *references* to renamed functions to their Swift names (e.g. a
   * reference to GetVersion becomes getVersion when -autorename renamed it).
   * Only renamed functions are in the map, so type names never match.  To avoid
   * rewriting an ordinary English word that merely happens to match a method name
   * (e.g. the imperative "Set ..." that begins many @brief lines), a token is only
   * rewritten when it appears in a reference position: qualified by '.', '#', '::'
   * or a code-span backtick immediately before it, or followed immediately by '('.
   * No-op without -autorename (the map is then empty). */
  if (!swiftRenamedSymbols.empty()) {
    std::string out;
    const std::string &doc = swiftDocString;
    out.reserve(doc.size());
    size_t i = 0, n = doc.size();
    while (i < n) {
      char c = doc[i];
      if (isalnum((unsigned char)c) || c == '_') {
        size_t start = i;
        while (i < n && (isalnum((unsigned char)doc[i]) || doc[i] == '_'))
          i++;
        std::string token = doc.substr(start, i - start);
        bool reference = false;
        if (start > 0) {
          char p = doc[start - 1];
          if (p == '.' || p == '#' || p == '`')
            reference = true;
          else if (p == ':' && start >= 2 && doc[start - 2] == ':')
            reference = true;  // C++ scope qualifier Class::method
        }
        if (!reference && i < n && doc[i] == '(')
          reference = true;  // call syntax method(...)
        std::map<std::string, std::string>::const_iterator it = swiftRenamedSymbols.find(token);
        out += (reference && it != swiftRenamedSymbols.end()) ? it->second : token;
      } else {
        out += c;
        i++;
      }
    }
    swiftDocString.swap(out);
  }

  if (m_flags & debug_translator) {
    std::cout << "\n---RESULT IN SWIFTDOC---" << std::endl;
    std::cout << swiftDocString;
  }

  return NewString(swiftDocString.c_str());
}
