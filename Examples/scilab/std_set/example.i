/* File : example.i */

%module example

%{
#include "example.hxx"
%}

%include stl.i

/* instantiate the required template specializations */
namespace std
{
    %template(IntSet) set<int>;
    %template(StringSet) set<std::string>;
}

%include "example.hxx"
