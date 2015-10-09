%insert(runtime) %{
#include <mex.h>
#include <math.h> /* need this for floor() */
#include <string.h> /* need this for strcmp() */
#include <stdarg.h> /* need this for SWIG_Error below */
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
void SWIG_Matlab_LoadModule() {
  /* Only call once */
  static int moduleIsLoaded = 0;
  if (moduleIsLoaded) return;
  moduleIsLoaded = 1;

  /* Prevent unloading this file until MATLAB exits */
  mexLock();

  /* Exit function (called when unloaded) */
  mexAtExit(SWIG_Matlab_ExitFcn);

  /* Load dependent modules and initialize */
%}
