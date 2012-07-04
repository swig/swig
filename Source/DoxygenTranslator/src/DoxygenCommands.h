
#ifndef DOXYGENCOMMANDS_H
#define DOXYGENCOMMANDS_H

const char *commandArray[] = {
  "a", "addindex", "addtogroup", "anchor", "arg", "attention",
  "author", "b", "brief", "bug", "c", "callgraph", "callergraph", "category",
  "class", "code", "cond", "copybrief", "copydetails", "copydoc", "date", "def",
  "defgroup", "deprecated", "details", "dir", "dontinclude", "dot", "dotfile", "e",
  "else", "elseif", "em", "endcode", "endcond", "enddot", "endhtmlonly", "endif",
  "endlatexonly", "endlink", "endmanonly", "endmsc", "endverbatim", "endxmlonly",
  "enum", "example", "exception", "f$", "f[", "f]", "f{", "f}", "file", "fn", "headerfile",
  "hideinitializer", "htmlinclude", "htmlonly", "if", "ifnot", "image", "include",
  "includelineno", "ingroup", "internal", "invariant", "interface", "latexonly", "li",
  "line", "link", "mainpage", "manonly", "msc", "n", "name", "namespace", "nosubgrouping",
  "note", "overload", "p", "package", "page", "par", "paragraph", "param", "post", "pre",
  "private", "privatesection", "property", "protected", "protectedsection", "protocol",
  "public", "publicsection", "ref", "relates", "relatesalso", "remarks", "return", "retval",
  "sa", "section", "see", "showinitializer", "since", "skip", "skipline", "struct", "subpage",
  "subsection", "subsubsection", "test", "throw", "throws", "todo", "tparam", "typedef", "union", "until",
  "var", "verbatim", "verbinclude", "version", "warning", "weakgroup", "xmlonly", "xrefitem", "$", "@", "\\", "&", "~", "<", ">", "#", "%"};


const char *sectionIndicators[] = {
  "attention", "author", "brief", "bug", "cond", "date", "deprecated", "details",
  "else", "elseif", "endcond", "endif", "exception", "if", "ifnot", "invariant", "note", "par", "param",
  "tparam", "post", "pre", "remarks", "return", "retval", "sa", "see", "since", "test", "throw", "throws", "todo", "version", "warning", "xrefitem"};
const int sectionIndicatorsSize = sizeof(sectionIndicators) / sizeof(*sectionIndicators);

/* All of the doxygen commands divided up by how they are parsed */
const char *simpleCommands[] = {
  "n", "$", "@", "\\", "&", "~", "<", ">", "#", "%"};
const int simpleCommandsSize = sizeof(simpleCommands) / sizeof(*simpleCommands);

const char *ignoredSimpleCommands[] = {
  "nothing at the moment"};
const int ignoredSimpleCommandsSize = sizeof(ignoredSimpleCommands) / sizeof(*ignoredSimpleCommands);

const char *commandWords[] = {
  "a", "b", "c", "e", "em", "p", "def", "enum", "example", "package", "relates", "namespace", "relatesalso", "anchor", "dontinclude", "include", "includelineno"};
const int commandWordsSize = sizeof(commandWords) / sizeof(*commandWords);

const char *ignoredCommandWords[] = {
  "copydoc", "copybrief", "copydetails", "verbinclude", "htmlinclude"};
const int ignoredCommandWordsSize = sizeof(ignoredCommandWords) / sizeof(*ignoredCommandWords);

const char *commandLines[] = {
  "addindex", "fn", "name", "line", "var", "skipline", "typedef", "skip", "until", "property"};
const int commandLinesSize = sizeof(commandLines) / sizeof(*commandLines);

const char *ignoreCommandLines[] = {
  "nothing at the moment"};
const int ignoreCommandLinesSize = sizeof(ignoreCommandLines) / sizeof(*ignoreCommandLines);

const char *commandParagraph[] = {
  "partofdescription", "return", "remarks", "since", "test", "sa", "see", "pre", "post", "details", "invariant",
  "deprecated", "date", "note", "warning", "version", "todo", "bug", "attention", "brief", "author"};
const int commandParagraphSize = sizeof(commandParagraph) / sizeof(*commandParagraph);

const char *ignoreCommandParagraphs[] = {
  "nothing at the moment"};
const int ignoreCommandParagraphsSize = sizeof(ignoreCommandParagraphs) / sizeof(*ignoreCommandParagraphs);

const char *commandEndCommands[] = {
  "code", "dot", "msc", "f$", "f[", "f{environment}{", "htmlonly", "latexonly", "manonly", "verbatim", "xmlonly", "cond", "if", "ifnot", "link"};
const int commandEndCommandsSize = sizeof(commandEndCommands) / sizeof(*commandEndCommands);

const char *commandWordParagraphs[] = {
  "param", "tparam", "throw", "throws", "retval", "exception"};
const int commandWordParagraphsSize = sizeof(commandWordParagraphs) / sizeof(*commandWordParagraphs);

const char *commandWordLines[] = {
  "page", "subsection", "subsubsection", "section", "paragraph", "defgroup"};
const int commandWordLinesSize = sizeof(commandWordLines) / sizeof(*commandWordLines);

const char *commandWordOWordOWords[] = {
  "category", "class", "protocol", "interface", "struct", "union"};
const int commandWordOWordOWordsSize = sizeof(commandWordOWordOWords) / sizeof(*commandWordOWordOWords);

const char *commandOWords[] = {
  "dir", "file", "cond"};
const int commandOWordsSize = sizeof(commandOWords) / sizeof(*commandOWords);

const char *commandErrorThrowings[] = {
  "annotatedclassstd::list", "classhierarchy", "define", "functionindex", "header",
  "headerfilestd::list", "inherit", "l", "postheader", "private", "privatesection", "protected",
  "protectedsection", "public", "publicsection", "endcode", "enddot", "endmsc", "endhtmlonly",
  "endlatexonly", "endmanonly", "endlink", "endverbatim", "endxmlonly", "f]", "f}", "endcond", "endif"};
const int commandErrorThrowingsSize = sizeof(commandErrorThrowings) / sizeof(*commandErrorThrowings);

const char *commandUniques[] = {
  "xrefitem", "arg", "ingroup", "par", "headerfile", "overload", "weakgroup", "ref", "subpage", "dotfile", "image", "addtogroup", "li"};
const int commandUniquesSize = sizeof(commandUniques) / sizeof(*commandUniques);

#endif