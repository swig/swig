/* This module tests whether Swig correctly parses:
   -    ordinary strings (char_t)
   - L  wide strings (wchar_t)
   - u8 unicode8 strings (char_t)
   - u  unicode16 strings (char16_t)
   - U  unicode32 strings (char32_t)

   This module also tests whether Swig correctly parses custom string delimiters.
*/

%module raw_string_literals

%inline %{
#include <iostream>
#include <string>

using namespace std;

string a="ABC";
wstring wide=L"ABC";
string c=u8"ABC";
string b=u"ABC";
string d=U"ABC";

/*string e=R"XXX[ABC"blah]XXX";
string g=u8R"XXX[ABC"blah]XXX";
string f=uR"XXX[ABC"blah]XXX";
string h=UR"XXX[ABC"blah]XXX";
*/
%}
