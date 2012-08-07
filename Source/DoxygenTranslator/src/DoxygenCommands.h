
#ifndef DOXYGENCOMMANDS_H
#define DOXYGENCOMMANDS_H

const char *sectionIndicators[] = {
  "attention", "author", "authors", "brief", "bug", "cond", "date", "deprecated", "details",
  "else", "elseif", "endcond", "endif", "exception", "if", "ifnot", "invariant", "note", "par", "param",
  "tparam", "post", "pre", "remarks", "remark", "result", "return", "returns", "retval", "sa", "see", "since", "test", "throw", "throws", "todo", "version", "warning", "xrefitem"};
const int sectionIndicatorsSize = sizeof(sectionIndicators) / sizeof(*sectionIndicators);

/* All of the doxygen commands divided up by how they are parsed */
const char *simpleCommands[] = {
  "n", "$", "@", "\\", "&", "~", "<", ">", "#", "%", "\"", ".", "::", "endcond",
  "callgraph", "callergraph", "showinitializer", "hideinitializer", "internal",
  "nosubgrouping", "public", "publicsection", "private", "privatesection",
  "protected", "protectedsection", "tableofcontents"};
const int simpleCommandsSize = sizeof(simpleCommands) / sizeof(*simpleCommands);

const char *commandWords[] = {
  "a", "b", "c", "e", "em", "p", "def", "enum", "package", "relates", "namespace", "relatesalso", "anchor", "dontinclude", "include",
  "includelineno", "copydoc", "copybrief", "copydetails", "verbinclude", "htmlinclude", "extends", "implements", "memberof", "related",
  "relatedalso", "cite"};
const int commandWordsSize = sizeof(commandWords) / sizeof(*commandWords);

const char *commandLines[] = {
  "addindex", "fn", "name", "line", "var", "skipline", "typedef", "skip", "until", "property"};
const int commandLinesSize = sizeof(commandLines) / sizeof(*commandLines);

const char *commandParagraph[] = {
  "partofdescription", "result", "return", "returns", "remarks", "remark", "since", "test", "sa", "see", "pre", "post", "details", "invariant",
  "deprecated", "date", "note", "warning", "version", "todo", "bug", "attention", "brief", "author", "authors",
  "copyright", "short"};
const int commandParagraphSize = sizeof(commandParagraph) / sizeof(*commandParagraph);

const char *commandEndCommands[] = {
  "htmlonly", "latexonly", "manonly", "xmlonly", "link", "rtfonly"};
const int commandEndCommandsSize = sizeof(commandEndCommands) / sizeof(*commandEndCommands);

const char *commandWordParagraphs[] = {
  "param", "tparam", "throw", "throws", "retval", "exception", "example"};
const int commandWordParagraphsSize = sizeof(commandWordParagraphs) / sizeof(*commandWordParagraphs);

const char *commandWordLines[] = {
  "page", "subsection", "subsubsection", "section", "paragraph", "defgroup", "snippet", "mainpage"};
const int commandWordLinesSize = sizeof(commandWordLines) / sizeof(*commandWordLines);

const char *commandWordOWordOWords[] = {
  "category", "class", "protocol", "interface", "struct", "union"};
const int commandWordOWordOWordsSize = sizeof(commandWordOWordOWords) / sizeof(*commandWordOWordOWords);

const char *commandOWords[] = {
  "dir", "file", "cond"};
const int commandOWordsSize = sizeof(commandOWords) / sizeof(*commandOWords);

const char *commandErrorThrowings[] = {
  "annotatedclassstd::list", "classhierarchy", "define", "functionindex", "header",
  "headerfilestd::list", "inherit", "l", "postheader", "endcode", "enddot", "endmsc", "endhtmlonly",
  "endlatexonly", "endmanonly", "endlink", "endverbatim", "endxmlonly", "f]", "f}", "endif", "else",
  "endrtfonly"};
const int commandErrorThrowingsSize = sizeof(commandErrorThrowings) / sizeof(*commandErrorThrowings);

const char *commandUniques[] = {
  "xrefitem", "arg", "ingroup", "par", "headerfile", "overload", "weakgroup", "ref", "subpage", "dotfile", "image", "addtogroup", "li",
  "if", "ifnot", "elseif", "else", "mscfile", "code", "verbatim", "f{", "f[", "f$", "dot", "msc"};
const int commandUniquesSize = sizeof(commandUniques) / sizeof(*commandUniques);

#endif
