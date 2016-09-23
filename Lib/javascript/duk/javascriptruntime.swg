/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * Runtime code for Duktape.
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <duktape.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
%}

%insert(runtime) "swigrun.swg";       /* SWIG API */
%insert(runtime) "swigerrors.swg";    /* SWIG errors */
%insert(runtime) "javascriptrun.swg"; /* Duktape runtime */

%flatnested;

/* Note: the initialization function is closed after all code is generated */
