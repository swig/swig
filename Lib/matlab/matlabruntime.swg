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
static int moduleIsLoaded = 0;
void SWIG_Matlab_LoadModule(const char* name) {
  /* Initialize module if first load */
  if (!moduleIsLoaded) {
    moduleIsLoaded = 1;
    SWIG_InitializeModule(0);
  } else if (!SWIG_GetModule(0)) {
      /* Handle special case when mex is still loaded
       * and global module variable deleted.*/
      if (saved_swig_module) {
          /* Recreate variable using saved pointer*/
          SWIG_Matlab_SetModule(saved_swig_module);
      } else {
        mexErrMsgIdAndTxt("SWIG:LoadFailure","Global type table deleted and can't be recovered");
      }
  }
  if(false){
    mexErrMsgIdAndTxt("SWIG:LoadFailure","Could not load module %s",name);
  }
%}
