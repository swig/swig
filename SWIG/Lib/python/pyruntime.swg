%insert(runtime) %{
/* Python.h has to appear first */
#include <Python.h>
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */   
%insert(runtime) "pyhead.swg";
%insert(runtime) "pyerrors.swg";
%insert(runtime) "pythreads.swg";       /* Python thread code */
%insert(runtime) "pyapi.swg";           /* Pyton API */
%insert(runtime) "pyrun.swg";           /* Python run-time code */

