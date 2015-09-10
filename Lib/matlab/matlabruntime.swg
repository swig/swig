%insert(runtime) %{
#include <mex.h>
#include <math.h> /* need this for floor() */
%}

%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "matlabrun.swg";

%insert(initbeforefunc) "swiginit.swg"

/* Define the LoadModule function.
   This will be called by mexFunction.
   Note that its bracket isn't closed here as that will be done
   in MATLAB::top() in matlab.cxx, see comments there why we do this.
*/
%insert(initbeforefunc) %{
void SWIG_Matlab_LoadModule(const char* name) {
  static int moduleIsLoaded = 0;
  /* Initialize module if first load */
  if (!moduleIsLoaded) {
    moduleIsLoaded = 1;
    SWIG_InitializeModule(0);
  }
%}
