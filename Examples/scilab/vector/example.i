/* File : example.i */
%module example

%{
#include "example.hxx"
%}

%include "std_vector.i"
namespace std {
    %template(nlopt_doublevector) vector<double>;
 };

%include "example.hxx";
