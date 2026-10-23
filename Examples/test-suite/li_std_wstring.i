%module li_std_wstring

// The languages below are yet to provide std_wstring.i
#if !(defined(SWIGD) || defined(SWIGGO) || defined(SWIGGUILE) || defined(SWIGJAVASCRIPT) || defined(SWIGLUA) || defined(SWIGOCAML) || defined(SWIGOCTAVE) || defined(SWIGPERL) || defined(SWIGPHP) || defined(SWIGR) || defined(SWIGSCILAB))

%warnfilter(SWIGWARN_TYPEMAP_WCHARLEAK) wchar_t_const_ptr_member;  // Setting a const wchar_t * variable may leak memory.

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

// The wrapper is given the default value
%feature("compactdefaultargs") wchar_default;
%feature("compactdefaultargs") wchar_default_ucn;
%feature("compactdefaultargs") wstring_default;
%feature("compactdefaultargs") wstring_nul_default;
%feature("compactdefaultargs") wstring_joined_default;
%feature("compactdefaultargs") wstring_joined_first_default;
%feature("compactdefaultargs") wstring_joined_escapes_default;
%feature("compactdefaultargs") wstring_beyond_unicode_default;
%feature("compactdefaultargs") wchar_beyond_unicode_default;

%{
// A wchar_t beyond Unicode needs 32 bits, so the literal is only used where wchar_t is not 16 bits
#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#define BEYOND_UNICODE(literal, other) other
#else
#define BEYOND_UNICODE(literal, other) literal
#endif
#define JOINED_ESCAPES L"\x100x\x263A"
%}

// SWIG gets joined literals and the compiler the wide literal above, which need not accept a narrow escape above 0xFF
%define JOINED_ESCAPES "\x100" L"x" L"" "\x263A" %enddef

#if defined(SWIGCSHARP)
// Initialised in C# rather than read from the C++ constant
%csconst(1) WSTRING_CONSTANT;
%csconst(1) WCHAR_CONSTANT;
%csconst(1) WSTRING_NUL_CONSTANT;
#endif

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

int wchar_default(wchar_t x = L'\x263A') {
  return (int)x;
}

int wchar_default_ucn(wchar_t x = L'\u263A') {
  return (int)x;
}

bool wstring_default(const wchar_t *s = L"\x263A" L"a\u00E9f\U0001F600") {
  return std::wstring(s) == L"\x263A" L"a\u00E9f\U0001F600";
}

bool wstring_nul_default(const wchar_t *s = L"a\0bc") {
  return s[0] == L'a' && s[1] == L'\0' && s[2] == L'b' && s[3] == L'c';
}

// An ordinary string literal joined to a wide one is wide, so each numeric escape sequence in it is one wchar_t
bool wstring_joined_default(const wchar_t *s = L"a" "\xC3\xA9") {
  return std::wstring(s) == L"a" "\xC3\xA9";
}

bool wstring_joined_first_default(const wchar_t *s = "\xC3\xA9" "\351" L"b") {
  return std::wstring(s) == "\xC3\xA9" "\351" L"b";
}

bool wstring_joined_escapes_default(const wchar_t *s = JOINED_ESCAPES) {
  return std::wstring(s) == L"\x100x\x263A";
}

bool wstring_beyond_unicode_default(const wchar_t *s = BEYOND_UNICODE(L"a\x110000\x7FFFFFFF\x80000000\xFFFFFFFF", L"a")) {
  return std::wstring(s) == BEYOND_UNICODE(L"a\x110000\x7FFFFFFF\x80000000\xFFFFFFFF", L"a");
}

bool wchar_beyond_unicode_default(wchar_t x = BEYOND_UNICODE(L'\x110000', L'a')) {
  return x == BEYOND_UNICODE(L'\x110000', L'a');
}

#define WSTRING_CONSTANT L"\x263A" L"a\u00E9f\U0001F600"
#define WSTRING_CONSTANT_GET L"\x263A" L"a\u00E9f"
#define WCHAR_CONSTANT L'\u00E9'
#define WSTRING_NUL_CONSTANT L"a\0bc"

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

#define WCHAR_ARRAY_LEN 3
struct wchar_test_struct {
  wchar_t wchar_t_member;
  wchar_t* wchar_t_ptr_member;
  const wchar_t* wchar_t_const_ptr_member;
  wchar_t wchar_t_array_member[WCHAR_ARRAY_LEN + 1]; // array size is an expression
  wchar_test_struct() : wchar_t_member(), wchar_t_ptr_member(), wchar_t_const_ptr_member(), wchar_t_array_member() {}
};

%}


#endif

