/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_wstring.swg
 *
 * COM typemaps for std::wstring and const std::wstring&
 * ----------------------------------------------------------------------------- */

%{
#include <string>
#include <wchar.h>
%}

namespace std {

%naturalvar wstring;
class wstring;

%typemap(ctype) wstring "WCHAR *"
%typemap(comtype) wstring "BSTR"

%typemap(in) wstring {
  if ($input) {
    $1.assign($input);
  }
}

%typemap(out) wstring %{
  {
    int SWIG_len = $1.size() + 1;
    WCHAR *SWIG_res = (WCHAR *) CoTaskMemAlloc((SWIG_len + 2) * sizeof(WCHAR));
    /* First 4 bytes contain length in bytes */
    *((unsigned int *) SWIG_res) = (unsigned int) (SWIG_len - 1) * sizeof(WCHAR);
    wcsncpy(SWIG_res + 2, $1.c_str(), SWIG_len);
    $result = SWIG_res + 2;
  }
%}

}
