/* -----------------------------------------------------------------------------
 * swig.swg
 *
 * Common macro definitions and other definitions used by the SWIG parser.
 * ----------------------------------------------------------------------------- */

#define %init       %insert("init")
#define %wrapper    %insert("wrapper")
#define %runtime    %insert("runtime")
#define %shadow     %insert("shadow")

#define %readonly   %scope("readonly")

#define %new        %pragma "new";
#define %name(x)    %pragma "name" `x`;
#define %disabledoc %pragma "disabledoc";
#define %enabledoc  %pragma "enabledoc";
#define %doconly    %pragma "doconly";

#define %alpha      %echo "$file.$line. %alpha directive is obsolete"
#define %raw        %echo "$file:$line. %raw directive is obsolete"

#define %title          /##/
#define %localstyle     /##/
#define %style          /##/
#define %section        /##/
#define %subsection     /##/
#define %subsubsection  /##/

#define %text       %insert("doc")
#define %native     %scope("native")

