/* File : example.i */

%module example

%{
#include "example.h"
%}

%include <typemaps.i>

%define TEMPLATE_ALGORITHMS(TYPE)
    // Instantiate std::pair <-> array pointer mapping
    %fortran_view(TYPE)

    %template(sort)        sort< TYPE >;
    %template(reverse)     reverse< TYPE >;
    %template(find_sorted) find_sorted< TYPE >;
    %template(get_view)    get_view< TYPE >;
    %template(print_array) print_array< TYPE >;
%enddef

%include "example.h"

TEMPLATE_ALGORITHMS(int)
TEMPLATE_ALGORITHMS(float)
TEMPLATE_ALGORITHMS(double)



