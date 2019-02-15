%module example
%{
#include <iostream>
#include <string>

using std::cin;
using std::cout;
using std::endl;
using std::string;

#include "example.h"
%}

%include "std_string.i"
%apply std::string& INOUT { std::string &inout }
%include example.h
