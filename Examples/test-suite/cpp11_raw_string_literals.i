/* This module tests whether SWIG correctly parses:
   -    ordinary strings (char_t)
   - L  wide strings (wchar_t)
   - u8 unicode8 strings (char_t)
   - u  unicode16 strings (char16_t)
   - U  unicode32 strings (char32_t)

   This module also tests whether SWIG correctly parses custom string delimiters.
*/
%module cpp11_raw_string_literals
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) bb;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) ee;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) gg;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) xx;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) cc;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) dd;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) hh;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) ii;

#if defined(SWIGTCL) || defined(SWIGCSHARP) || defined(SWIGOCTAVE) || defined(SWIGRUBY) || defined(SWIGPYTHON) || defined(SWIGJAVA)
%include <std_wstring.i>
#endif

%inline %{
#include <iostream>
#include <string>

using namespace std;

int L  = 100;
int u8 = 100;
int u  = 100;
struct UStruct {
  static const int U  = 100;
};

int R   = 100;
int LR  = 100;
int u8R = 100;
int uR  = 100;
struct URStruct {
  static const int UR  = 100;
};

// New string literals
wstring         aa =  L"Wide string";
const char     *bb = u8"UTF-8 string";
const char16_t *cc =  u"UTF-16 string";
const char32_t *dd =  U"UTF-32 string";
// New char literals
char16_t char16_t_char = u'a';
char32_t char32_t_char = U'b';
%}

/* Raw string literals */
%inline %{
const char      *xx =        ")I'm an \"ascii\" \\ string.";
const char      *ee =   R"XXX()I'm an "ascii" \ string.)XXX";
wstring          ff =  LR"XXX(I'm a "raw wide" \ string.)XXX";
const char      *gg = u8R"XXX(I'm a "raw UTF-8" \ string.)XXX";
const char16_t  *hh =  uR"XXX(I'm a "raw UTF-16" \ string.)XXX";
const char32_t  *ii =  UR"XXX(I'm a "raw UTF-32" \ string.)XXX";
%}

// Constants
#if defined(SWIGJAVA)
%javaconst(1);
#elif SWIGCSHARP
%csconst(1);
#elif SWIGD
%dmanifestconst;
#endif

%inline %{
#define   jj          ")I'm an \"ascii\" \\ string constant."
#define   kk     R"XXX()I'm an "ascii" \ string constant.)XXX";
%}

%constant mm =   R"XXX()I'm an "ascii" \ string constant with multiple

lines.)XXX";

// docstring feature
%feature("docstring") RawStringDoc::WW "Single line documentation comment"
%feature("docstring") RawStringDoc::XX %{
Multi-line
documentation
comment
%}
%feature("docstring") RawStringDoc::YY R"RRR(Single line "raw string" documentation comment)RRR"
%feature("docstring") RawStringDoc::ZZ R"FOO(Documentation comment

as a "raw string"
on multiple lines including a \ backslash)FOO"

%inline %{
struct RawStringDoc {
  void WW() {}
  void XX() {}
  void YY() {}
  void ZZ() {}
};
%}

