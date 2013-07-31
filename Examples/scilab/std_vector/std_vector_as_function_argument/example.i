/* File : example.i */

%module example

%{
#include "example.hxx"
%}

%include stl.i

/* instantiate the required template specializations */
namespace std
{
    %template(IntVector) vector<int>;
    %template(DoubleVector) vector<double>;
    %template(StringVector) vector<std::string>;
    %template(BoolVector) vector<bool>;
    %template(ClassAPtrVector) vector<classA*>;
}

%include "example.hxx"
