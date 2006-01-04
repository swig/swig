%module(directors="1") example

%{
#include "example.h"
%}

%include "std_vector.i"

%director Foo;
%director Bar;
%include "example.h"


%template(VectorBar) std::vector<Bar*>;
%template(VectorFoo) std::vector<Foo*>;
