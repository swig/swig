%module lib_std_string
%include "std_string.i"

%inline %{

std::string test_value_in(std::string x) {
   return x;
}

std::string *test_pointer_in(std::string *x) {
   return x;
}

const std::string *test_const_pointer_in(const std::string *x) {
   return x;
}

std::string test_reference_in(std::string &x) {
   return x;
}

std::string test_const_reference_in(const std::string &x) {
   return x;
}

%}


