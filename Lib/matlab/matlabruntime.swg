%insert(runtime) %{
#include <mex.h>
#include <math.h> /* need this for floor() */
%}

%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "matlabrun.swg";

%insert(initbeforefunc) "swiginit.swg"

/* SWIG_Matlab_ModuleLoad, SWIG_Matlab_ModuleUnload
   These functions are called from other modules
*/
%insert(initbeforefunc) %{
int SWIG_Matlab_ModuleLoad(int resc, mxArray *resv[], int argc, mxArray *argv[]) {
  /* Return module info pointer */
  swig_module_info *pointer = &swig_module;
  resv[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
  if(!resv[0]) return 1;
  *(uint64_T *)mxGetData(resv[0]) = (uint64_T)pointer;

  /* Increase lock count */
  mexLock();

  return 0;
}

int SWIG_Matlab_ModuleUnload(int resc, mxArray *resv[], int argc, mxArray *argv[]) {
  /* Decrease lock count */
  mexUnlock();
  return 0;
}
%}

/* SWIG_Matlab_ExitFcn
   Called when a mex file is unloaded
*/
%insert(initbeforefunc) %{
#ifdef __cplusplus
extern "C"
#endif /* cplusplus */
void SWIG_Matlab_ExitFcn(void) {
  /* Unused at the moment */
}
%}

/* Define the LoadModule function.
   This will be called by mexFunction.
   Note that its bracket isn't closed here as that will be done
   in MATLAB::top() in matlab.cxx, see comments there why we do this.
*/
%insert(initbeforefunc) %{
static bool is_loaded = false;
void SWIG_Matlab_LoadModule(const char* name) {
  SWIG_InitializeModule(0);
  SWIG_PropagateClientData();
  if(false){
    mexErrMsgIdAndTxt("SWIG:LoadFailure","Could not load module %s",name);
  }
%}
