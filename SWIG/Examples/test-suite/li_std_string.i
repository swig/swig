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
   static std::string x = "test_reference_out message";
   return x;
}

void test_throw() throw(std::string){
  static std::string x = "test_throw message";
  throw x;
}

void test_const_reference_throw() throw(const std::string &){
  static std::string x = "test_const_reference_throw message";
  throw x;
}

void test_pointer_throw() throw(std::string *) {
  throw new std::string("foo");
}

void test_const_pointer_throw() throw(const std::string *) {
  throw new std::string("foo");
}

%}

%apply const std::string& { std::string *GlobalString2, 
                            std::string *MemberString2, 
                            std::string *Structure::StaticMemberString2 };

%inline %{
std::string GlobalString;
std::string GlobalString2 = "global string 2";

struct Structure {
  std::string MemberString;
  std::string MemberString2;
  static std::string StaticMemberString;
  static std::string StaticMemberString2;

  const std::string ConstMemberString;
  static const std::string ConstStaticMemberString;

  Structure() : ConstMemberString("const member string"), MemberString2("member string 2") {}
};
%}

%{
  std::string Structure::StaticMemberString = "static member string";
  std::string Structure::StaticMemberString2 = "static member string 2";
  const std::string Structure::ConstStaticMemberString = "const static member string";
%}

