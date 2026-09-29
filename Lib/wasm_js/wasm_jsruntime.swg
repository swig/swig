/* Runtime fragments for the WebAssembly JavaScript target. */

%insert(runtime) %{
#include <emscripten.h>
#include <stdint.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <limits.h>
%}

%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "wasm_jsrun.swg";

/* Director support is inserted by the language module when enabled.
   The module also initializes the static type and cast tables. */
