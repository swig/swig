/* -----------------------------------------------------------------------------
 * swig.swg
 *
 * $Header$
 *
 * Common macro definitions for various SWIG directives.  This file is always 
 * included at the top of each input file.
 * ----------------------------------------------------------------------------- */

/* Deprecated SWIG directives */

#define %disabledoc     %echo "$file:$line. Warning: %disabledoc is deprecated"
#define %enabledoc      %echo "$file:$line. Warning: %enabledoc is deprecated"
#define %doconly        %echo "$file:$line. Warning: %doconly is deprecated"
#define %style          %echo "$file:$line. Warning: %style is deprecated" /##/
#define %localstyle     %echo "$file:$line. Warning: %localstyle is deprecated" /##/
#define %title          %echo "$file:$line. Warning: %title is deprecated" /##/
#define %section        %echo "$file:$line. Warning: %section is deprecated" /##/
#define %subsection     %echo "$file:$line. Warning: %subsection is deprecated" /##/
#define %subsubsection  %echo "$file:$line. Warning: %subsubsection is deprecated" /##/
#define %text           %insert("null")

/* Code insertion directives such as %wrapper %{ ... %} */

#define %init        %insert("init")
#define %wrapper     %insert("wrapper")
#define %header      %insert("header")
#define %runtime     %insert("runtime")

/* Access control directives */

#define %readonly    %pragma(swig) readonly;
#define %readwrite   %pragma(swig) readwrite;

/* Directives for callback functions */

/*
#define %callback(x) %pragma(swig) callback=`x`;
#define %nocallback  %pragma(swig) nocallback;
*/

/* Experimental */

#define %callback(x) %feature("callback") `x`;
#define %nocallback  %feature("callback");

/* Directives for attribute functions */

#define %attributefunc(_x,_y)  %pragma(swig)   attributefunction=`_x`":"`_y`;
#define %noattributefunc       %pragma(swig)   noattributefunction;

/* %ignore directive */

#define %ignore         %rename($ignore)
#define %ignorewarn(x)  %rename("$ignore:" x)

/* Generation of default constructors/destructors */

#define %nodefault     %pragma nodefault
#define %makedefault   %pragma makedefault

/* New %except directive */

#define %exception %feature(except)

/* Default handling of certain overloaded operators */

#ifdef __cplusplus
%ignorewarn("operator new ignored")     operator new;
%ignorewarn("operator delete ignored")  operator delete;
#endif

/* Set up the typemap for handling new return strings */

#ifdef __cplusplus
%typemap(newfree) char * "delete [] $1;";
#else
%typemap(newfree) char * "free($1);";
#endif

/* Default typemap for handling char * members */

#ifdef __cplusplus
%typemap(memberin) char * {
  if ($1) delete [] $1;
  $1 = new char[strlen($input)+1];
  strcpy($1,$input);
}
%typemap(globalin) char * {
  if ($1) delete [] $1;
  $1 = new char[strlen($input)+1];
  strcpy($1,$input);
}
#else
%typemap(memberin) char * {
  if ($1) free($1);
  $1 = (char *) malloc(strlen($input)+1);
  strcpy($1,$input);
}
%typemap(globalin) char * {
  if ($1) free($1);
  $1 = (char *) malloc(strlen($input)+1);
  strcpy($1,$input);
}
#endif

  
