/* File : example.i */

%module example

%{
#include "example.hxx"
%}

%include stl.i

/* instantiate the required template specializations */
namespace std
{
    %template(IntList) list<int>;
    %template(StringList) list<std::string>;
}

%include "example.hxx"
