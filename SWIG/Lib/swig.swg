/* -----------------------------------------------------------------------------
 * swig.swg
 *
 * Common macro definitions and other definitions used by the SWIG parser.
 * ----------------------------------------------------------------------------- */

#define %init       %insert("init")
#define %wrapper    %insert("wrapper")
#define %runtime    %insert("runtime")
#define %shadow     %insert("shadow")

#define %readonly   %pragma "readonly";
#define %readwrite  %pragma "readwrite";
#define %new        %pragma "new";
#define %name(x)    %pragma "name" `x`;
#define %disabledoc %pragma "disabledoc";
#define %enabledoc  %pragma "enabledoc";
#define %doconly    %pragma "doconly";

#define %alpha
#define %raw

#define %title          /##/
#define %localstyle     /##/
#define %style          /##/
#define %section        /##/
#define %subsection     /##/
#define %subsubsection  /##/

#define %text       %insert("doc")


