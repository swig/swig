/* Python.h has to appear first */
%insert(runtime) %{
#include <Python.h>
%}

%insert(runtime) "swigrun.swg";         /* Common C API type-checking code */
%insert(runtime) "pyapi.swg";           /* SWIG/Pyton API */
%insert(runtime) "pyrun.swg";           /* Python run-time code */
