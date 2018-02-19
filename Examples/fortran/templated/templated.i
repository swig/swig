/* File : templated.i */
%module "templated"

%{
#include "templated.h"
%}
%include "templated.h"

// Note that template instantiation is after the header include
%template(Thing_Int)  Thing<int>;
%template(Thing_Dbl)  Thing<double>;

// Instantiate and overload a function
%template(print_thing)  print_thing<int>;
%template(print_thing)  print_thing<double>;
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
