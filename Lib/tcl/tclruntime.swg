/* tcl.h has to appear first */
%insert(runtime) %{
#include <stdio.h>
#include <tcl.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>
%}

%insert(runtime) "swigrun.swg";         /* Common C API type-checking code */
%insert(runtime) "tclapi.swg";          /* SWIG/Tcl API */
%insert(runtime) "tclrun.swg";          /* Tcl run-time code */
