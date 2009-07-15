/* This module tests whether Swig correctly parses:
   -    ordinary strings (char_t)
   - L  wide strings (wchar_t)
   - u8 unicode8 strings (char_t)
   - u  unicode16 strings (char16_t)
   - U  unicode32 strings (char32_t)

   This module also tests whether Swig correctly parses custom string delimiters.
*/
%module cpp0x_raw_string_literals

%inline %{
#include <iostream>
#include <string>

using namespace std;

int L  = 100;
int u8 = 100;
int u  = 100;
int U  = 100;

int R   = 100;
int LR  = 100;
int u8R = 100;
int uR  = 100;
int UR  = 100;

char      *a = "ABC";
wstring wide = L"ABC";
//char    *b = u8"ABC"; // not supported by GCC
char16_t  *c = u"ABC";
char32_t  *d = U"ABC";

/* Raw string literals are not supported by GCC yet */
/*char       *e = R"XXX[to be or "not" to be [these are parenthesis], this is the question!]XXX";
wstring wide2 = LR"XXX[to be or "not" to be [these are parenthesis], this is the question!]XXX";
char       *f = u8R"XXX[to be or "not" to be [these are parenthesis], this is the question!]XXX";
char16_t   *g = uR"XXX[to be or "not" to be [these are parenthesis], this is the question!]XXX";
char32_t   *h = UR"XXX[to be or "not" to be [these are parenthesis], this is the question!]XXX";
*/
%}
