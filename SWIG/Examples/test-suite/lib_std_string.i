%module lib_std_string
%include "std_string.i"

%inline %{

std::string test_value(std::string x) {
   return x;
}

std::string *test_pointer(std::string *x) {
   return x;
}

std::string test_reference(std::string &x) {
   return x;
}

%}


