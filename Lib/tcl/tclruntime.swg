/* tcl.h has to appear first */
%insert(runtime) %{
#include <stdio.h>
#include <tcl.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>

/* Check, if Tcl version supports Tcl_Size,
   which was introduced in Tcl 8.7 and 9.
*/
#ifndef TCL_SIZE_MAX
    #include <limits.h>
    #define TCL_SIZE_MAX INT_MAX

    #ifndef Tcl_Size
        typedef int Tcl_Size;
    #endif

    #define TCL_SIZE_MODIFIER ""
    #define Tcl_GetSizeIntFromObj Tcl_GetIntFromObj
    #define Tcl_NewSizeIntObj     Tcl_NewIntObj
#endif
%}

%insert(runtime) "swigrun.swg";         /* Common C API type-checking code */
%insert(runtime) "swigerrors.swg"       /* SWIG errors */   
%insert(runtime) "tclerrors.swg";       /* Tcl Errors */
%insert(runtime) "tclapi.swg";          /* Tcl API */
%insert(runtime) "tclrun.swg";          /* Tcl run-time code */
