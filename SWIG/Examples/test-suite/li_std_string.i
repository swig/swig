%module li_std_string
%include "std_string.i"

%inline %{

std::string test_value(std::string x) {
   return x;
}

const std::string& test_const_reference(const std::string &x) {
   return x;
}

void test_pointer(std::string *x) {
}

std::string *test_pointer_out() {
   static std::string x = "x";
   return &x;
}

void test_const_pointer(const std::string *x) {
}

const std::string *test_const_pointer_out() {
   static std::string x = "x";
   return &x;
}

void test_reference(std::string &x) {
}

std::string& test_reference_out() {
   static std::string x = "x";
   return x;
}

void test_throw() throw(std::string){
  static std::string x = "x";
  throw x;
}

void test_const_reference_throw() throw(const std::string &){
  static std::string x = "x";
  throw x;
}

void test_pointer_throw() throw(std::string *) {
  throw new std::string("foo");
}

void test_const_pointer_throw() throw(const std::string *) {
  throw new std::string("foo");
}

%}


