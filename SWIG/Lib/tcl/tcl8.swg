/* -----------------------------------------------------------------------------
 * tcl8.swg
 *
 * Tcl8 configuration module.
 * ----------------------------------------------------------------------------- */

%runtime "common.swg"
%runtime "swigtcl8.swg"

// Typemap for character array returns

%typemap(tcl8,out) char [ANY], const char[ANY] "Tcl_SetObjResult(interp,Tcl_NewStringObj($source,-1));"

