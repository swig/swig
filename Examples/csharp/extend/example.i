/* File : example.i */
%module(directors="1") example
%{
#include "example.h"
%}

%include "std_vector.i"
%include "std_string.i"

%feature("csdirectordelegatemodifiers") "[UnmanagedFunctionPointer(CallingConvention.StdCall)] public"

/* turn on director wrapping for Manager */
%feature("director") Employee;
%feature("director") Manager;

%typemap(csattributes) Manager          ""
%csattributes Manager::SwigDirectorMethodgetPosition "[MonoPInvokeCallback(typeof(SwigDelegateAliceListener_0))]"

%include "example.h"


