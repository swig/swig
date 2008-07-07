#include "DoxygenEntity.h"
#include <string>

/* Little data class for Doxygen Commands */


/* Basic node for commands that have
 * nothing after them
 * example: \n
 */
string commandArray2[] = {"a", "addindex", "addtogroup", "anchor", "arg", "attention",
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
		"subsection", "subsubsection", "test", "throw", "todo", "tparam", "typedef", "union", "until",
		"var", "verbatim", "verbinclude", "version", "warning", "weakgroup", "xmlonly", "xrefitem",
		"$", "@", string(1, 92), string(1, '&'), "~", "<", ">", string(1, '#'), "%"};

string findCommand(int commandNum){

	int arraySize = sizeof(commandArray2)/sizeof(*commandArray2);
	if (commandNum - 101 >= 0 && commandNum - 101 < arraySize){
		return commandArray2[commandNum - 101];
	}

	return "" ;
}

DoxygenEntity::DoxygenEntity(string typeEnt){
    typeOfEntity = typeEnt;
    data = "";
    isLeaf = 1;
}

/* Basic node for commands that have
 * only 1 thing after them
 * example: \b word
 * OR holding a string
 */
DoxygenEntity::DoxygenEntity(string typeEnt, string param1){
    typeOfEntity = typeEnt;
    data = param1;
    isLeaf = 1;
}

/* Nonterminal node
 * contains
 */
DoxygenEntity::DoxygenEntity(string typeEnt, list <DoxygenEntity> entList){
    typeOfEntity = typeEnt;
    data = "";
    isLeaf = 0;
    entityList = entList;
}


void DoxygenEntity::printEntity(int level){
	if (isLeaf) {
		for (int i = 0; i < level; i++) {cout << "\t";}
		cout << "Node Command: " << typeOfEntity << " ";
		if (data.compare("") != 0) cout << "Node Data: " << data;
		cout << endl;
	}
	else{
		cout << "Node Command : " << typeOfEntity << endl;
		list<DoxygenEntity>::iterator p = entityList.begin();
		level++;
		while (p != entityList.end()){
			(*p).printEntity(level);
			p++;
		}
	}
}

DoxygenEntity::~DoxygenEntity()
{
}
