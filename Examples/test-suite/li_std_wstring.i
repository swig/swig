%module li_std_wstring

// The languages below are yet to provide std_wstring.i
#if !(defined(SWIGD) || defined(SWIGGO) || defined(SWIGGUILE) || defined(SWIGJAVASCRIPT) || defined(SWIGLUA) || defined(SWIGMZSCHEME) || defined(SWIGOCAML) || defined(SWIGOCTAVE) || defined(SWIGPERL) || defined(SWIGPHP) || defined(SWIGR) || defined(SWIGSCILAB))

%warnfilter(SWIGWARN_TYPEMAP_WCHARLEAK_MSG) wchar_t_const_ptr_member;  // Setting a const wchar_t * variable may leak memory.

%include <std_wstring.i>


// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%{
// Unicode strings are stored in li_std_wstring.h file which has the BOM appropriately set, primarily for Visual C++ to correctly interpret the wide strings
#include "li_std_wstring.h"
%}

%inline %{
#include <string>
#include <iostream>

bool trace = false;

void show_wstring_bytes(const std::wstring &s) {
  unsigned char *p = (unsigned char *)s.data();
  size_t len = s.size()*sizeof(wchar_t);
  std::wcout << L"s: " << /*s <<*/ L"[";
  for (size_t i = 0; i<len; i++) {
    std::wcout << std::hex << *p << L" ";
    p++;
  }
  std::wcout << L"]" << std::endl;
  std::wcout << std::flush;
}

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
  if (trace) {
    std::wcout << "received(C++): " /*<< x */<< std::endl;
    show_wstring_bytes(x);
  }
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

bool test_equal(const wchar_t *wcs, const std::wstring& s) {
  if (trace) {
    show_wstring_bytes(wcs);
    show_wstring_bytes(s);
  }
  return wcs == s;
}

bool test_equal_abc(const std::wstring &s) {
  return test_equal(L"abc", s);
}

bool test_equal_jp(const std::wstring &s) {
  return test_equal(JP_WSTRING, s);
}

bool test_equal_de(const std::wstring &s) {
  return test_equal(DE_WSTRING, s);
}

bool test_equal_ru(const std::wstring &s) {
  return test_equal(RU_WSTRING, s);
}

void test_throw() TESTCASE_THROW1(std::wstring) {
  static std::wstring x = L"throwing test_throw";
  throw x;
}

void test_throw_wchar_t_ptr() TESTCASE_THROW1(std::wstring) {
  static std::wstring x = JP_WSTRING;
  throw x;
}

void test_throw_jp() TESTCASE_THROW1(std::wstring) {
  static std::wstring x = JP_WSTRING;
  throw x;
}

void test_throw_ref_jp() TESTCASE_THROW1(const std::wstring&) {
  static std::wstring x = JP_WSTRING;
  throw x;
}

const char * non_utf8_c_str() {
  return "h\xe9llo";
}

size_t size_wstring(const std::wstring& s) {
  return s.size();
}

struct wchar_test_struct {
  wchar_t wchar_t_member;
  wchar_t* wchar_t_ptr_member;
  const wchar_t* wchar_t_const_ptr_member;
  wchar_test_struct() : wchar_t_member(), wchar_t_ptr_member(), wchar_t_const_ptr_member() {}
};

%}

#endif

