/* Python.h has to appear first */

%insert(runtime) %{
#include <Python.h>
%}

%insert(runtime) "common.swg";          /* Common type-checking code */
%insert(runtime) "pyapi.swg";           /* SWIG/Pyton API */
%insert(runtime) "pyrun.swg";           /* Python run-time code */
