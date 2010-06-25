/* This module tests whether Swig correctly parses:
   -    ordinary strings (char_t)
   - L  wide strings (wchar_t)
   - u8 unicode8 strings (char_t)
   - u  unicode16 strings (char16_t)
   - U  unicode32 strings (char32_t)

   This module also tests whether Swig correctly parses custom string delimiters.
*/
%module cpp0x_raw_string_literals
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) aa;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) bb;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) ee;
%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) ff;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) cc;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) dd;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) gg;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) hh;

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

const char      *aa = "ABC";
wstring        wide = L"ABC";
const char      *bb = u8"ABC";
const char16_t  *cc = u"ABC";
const char32_t  *dd = U"ABC";
%}

/* Raw string literals */

#warning TODO: change SWIG support from old R"[ ... ]" to new R"( ... )"

const char      *ee = R"XXX[to be or "not" to be [square parenthesis] (round parenthesis), that is the question!]XXX";
wstring       wide2 = LR"XXX[to be or "not" to be [square parenthesis] (round parenthesis), that is the question!]XXX";
const char      *ff = u8R"XXX[to be or "not" to be [square parenthesis] (round parenthesis), that is the question!]XXX";
const char16_t  *gg = uR"XXX[to be or "not" to be [square parenthesis] (round parenthesis), that is the question!]XXX";
const char32_t  *hh = UR"XXX[to be or "not" to be [square parenthesis] (round parenthesis), that is the question!]XXX";
%{
const char      *ee = R"XXX(to be or "not" to be [square parenthesis] (round parenthesis), that is the question!)XXX";
wstring       wide2 = LR"XXX(to be or "not" to be [square parenthesis] (round parenthesis), that is the question!)XXX";
const char      *ff = u8R"XXX(to be or "not" to be [square parenthesis] (round parenthesis), that is the question!)XXX";
const char16_t  *gg = uR"XXX(to be or "not" to be [square parenthesis] (round parenthesis), that is the question!)XXX";
const char32_t  *hh = UR"XXX(to be or "not" to be [square parenthesis] (round parenthesis), that is the question!)XXX";
%}

