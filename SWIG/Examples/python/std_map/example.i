/* File : example.i */
%module example

%{
#include "example.h"
%}

%include std_string.i
%include std_pair.i
%include std_map.i

/* instantiate the required template specializations */
namespace std {
  /* remember to instantiate the key,value pair! */
  %template() pair<std::string,double>;
  %template() pair<std::string,int>;
  %template(DoubleMap) map<std::string,double>;
  %template() map<std::string,int>;
}

/* Let's just grab the original header file here */
%include "example.h"

%template(halfd) half_map<std::string,double>;
%template(halfi) half_map<std::string,int>;

