/* Python.h has to appear first */

%insert(runtime) %{
#include <Python.h>
%}

%insert(runtime) "precommon.swg";
%insert(runtime) "common.swg";          /* Common type-checking code */
%insert(runtime) "pyrun.swg";           /* Python run-time code */
