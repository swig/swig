/* -----------------------------------------------------------------------------
 * tcl8.swg
 *
 * Tcl8 configuration module.
 * ----------------------------------------------------------------------------- */

%runtime "common.swg"
%runtime "swigtcl8.swg"

// Typemap for character array returns

%typemap(tcl8,out) char [ANY], const char[ANY] "Tcl_SetObjResult(interp,Tcl_NewStringObj($source,-1));"

// Some special reserved words in classes

%namewarn("cget is a reserved method name") *::cget;
%namewarn("configure is a reserved method name") *::configure;
%namewarn("disown is a reserved method name") *::disown;
%namewarn("acquire is a reserved method name") *::acquire;

/* C++ overloaded operators.

   These declarations define how SWIG is going to rename C++
   overloaded operators in Tcl.  Since Tcl allows identifiers
   to be essentially any valid string, we'll just use the
   normal operator names */

#ifdef __cplusplus
%rename("+")         operator+;
%rename("u+")        operator+();     // Unary +
%rename("-")         operator-;
%rename("u-")        operator-();     // Unary -
%rename("*")         operator*;
%rename("/")         operator/;
%rename("<<")        operator<<;
%rename(">>")        operator>>;
%rename("&")         operator&;
%rename("|")         operator|;
%rename("^")         operator^;
%rename("%")         operator%;
#endif


