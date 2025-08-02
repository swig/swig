/* File : example.i */
%module(docstring="external runtime") example

%{
#include "example.h"
%}

// Exception handling
%include <std_except.i>
%catches(std::runtime_error) MeshCaller::MeshCaller;

%include "example.h"

%inline %{
// The -builtin SWIG option results in SWIGPYTHON_BUILTIN being defined
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
