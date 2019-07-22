%module li_std_wstring

// The languages below are yet to provide std_wstring.i
#if !(defined(SWIGD) || defined(SWIGGO) || defined(SWIGGUILE) || defined(SWIGJAVASCRIPT) || defined(SWIGLUA) || defined(SWIGMZSCHEME) || defined(SWIGOCAML) || defined(SWIGOCTAVE) || defined(SWIGPERL) || defined(SWIGPHP) || defined(SWIGR) || defined(SWIGSCILAB))

%include <std_wstring.i>

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%inline %{
#include <string>

wchar_t test_wcvalue(wchar_t x) {
   return x;
}

const wchar_t* test_ccvalue(const wchar_t* x) {
   return x;
}

wchar_t* test_cvalue(wchar_t* x) {
   return x;
}
  

wchar_t* test_wchar_overload() {
   return 0;
}

wchar_t* test_wchar_overload(wchar_t *x) {
   return x;
}

std::wstring test_value(std::wstring x) {
   return x;
}

const std::wstring& test_const_reference(const std::wstring &x) {
   return x;
}

void test_pointer(std::wstring *x) {
}

void test_const_pointer(const std::wstring *x) {
}

void test_reference(std::wstring &x) {
}

bool test_equal_abc(const std::wstring &s) {
  return L"abc" == s;
}

void test_throw() TESTCASE_THROW1(std::wstring){
  static std::wstring x = L"throwing test_throw";
  
  throw x;
}

const char * non_utf8_c_str() {
  return "h\xe9llo";
}

size_t size_wstring(const std::wstring& s) {
  return s.size();
}

%}

#endif

