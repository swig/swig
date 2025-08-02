%module cpp17_string_view
#if defined SWIGCSHARP || defined SWIGJAVA || defined SWIGLUA || defined SWIGPERL || defined SWIGPHP || defined SWIGPYTHON || defined SWIGRUBY || defined SWIGTCL
%include <std_string_view.i>

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%inline %{

std::string_view test_value(std::string_view x) {
   return x;
}

const std::string_view& test_const_reference(const std::string_view &x) {
   return x;
}

void test_const_reference_returning_void(const std::string_view &) {
}

void test_const_reference_returning_void(const std::string_view &, int) {
}

void test_pointer(std::string_view *x) {
}

std::string_view *test_pointer_out() {
   static std::string_view x = "x";
   return &x;
}

void test_const_pointer(const std::string_view *x) {
}

const std::string_view *test_const_pointer_out() {
   static std::string_view x = "x";
   return &x;
}

void test_reference(std::string_view &x) {
}

std::string_view& test_reference_out() {
   static std::string_view x = "test_reference_out message";
   return x;
}

std::string_view test_reference_input(std::string_view &input) {
  return input;
}

void test_multiple(std::string_view aa, std::string_view bb, const std::string_view &cc, const std::string_view &dd) {
}

void test_throw() TESTCASE_THROW1(std::string_view){
  static std::string_view x = "test_throw message";
  throw x;
}

void test_const_reference_throw() TESTCASE_THROW1(const std::string_view &){
  static const std::string_view x = "test_const_reference_throw message";
  throw x;
}

void test_pointer_throw() TESTCASE_THROW1(std::string_view *) {
  throw new std::string_view("foo");
}

void test_const_pointer_throw() TESTCASE_THROW1(const std::string_view *) {
  throw static_cast<const std::string_view*>(new std::string_view("foo"));
}
%}

#ifdef SWIGSCILAB
%rename(ConstStr) ConstMemberString;
%rename(ConstStaticStr) ConstStaticMemberString;
#endif

%inline %{
const std::string_view ConstGlobalString = "const global string";

struct Structure {
  const std::string_view ConstMemberString;
  static const std::string_view ConstStaticMemberString;

  Structure() : ConstMemberString("const member string") {}
};
%}

%{
  const std::string_view Structure::ConstStaticMemberString = "const static member string";
%}


%inline %{
  std::string_view stdstringview_empty() {
    return std::string_view();
  }

  char *c_empty() {
    return (char *)"";
  }

  char *c_null() {
    return 0;
  }

  const char *get_null(const char *a) {
    return a == 0 ? a : "non-null";
  }
%}
#endif
