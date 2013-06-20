/* File : example.i */

%module example

%{
#include "example.hxx"
%}

%include "std_vector.i"

%apply std::vector<double> &INOUT { std::vector<double>& inout_dvector };
%apply std::vector<int> &INOUT { std::vector<int>& inout_ivector };
%apply std::vector<std::string> &INOUT { std::vector<std::string>& inout_svector };

%include "example.hxx"
