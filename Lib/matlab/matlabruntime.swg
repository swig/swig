%insert(runtime) %{
#include <cstdlib>
#include <iostream>
#include <mex.h>
#include <math.h>
%}

%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "matlabrun.swg";

%insert(initbeforefunc) "swiginit.swg"

%insert(initbeforefunc) %{
static bool is_loaded = false;
void SWIG_Matlab_LoadModule(const char* name) {
  SWIG_InitializeModule(0);
  SWIG_PropagateClientData();
  if(false){
    mexErrMsgIdAndTxt("SWIG:LoadFailure","Could not load module %s",name);
  }
}
%}
