/* File : example.i */
%module example
%include <std_string.i>
%include <std_vector.i>

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"

%template(Vint) std::vector<int>;
%template(VA) std::vector<A>;
