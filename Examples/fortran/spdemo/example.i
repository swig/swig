/* File : spdemo.i */

%module spdemo

%{
#include "spdemo.h"
%}

%include <std_shared_ptr.i>
%shared_ptr(Foo);
%include "spdemo.h"



