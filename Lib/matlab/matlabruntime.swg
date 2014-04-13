%insert(runtime) %{
#include <cstdlib>
#include <iostream>
#include <mex.h>
%}

%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "matlabrun.swg";

%insert(initbeforefunc) "swiginit.swg"

%insert(initbeforefunc) %{
%}
