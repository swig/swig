%module example
%{
#include "example.h"
%}

%include stl.i

%feature("director");
namespace std {
	%template(StringVector) std::vector<string>;
};

%include example.h
