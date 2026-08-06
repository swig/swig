%module rust_wchar

%include <wchar.i>

%inline %{
#include <wchar.h>

wchar_t rust_wchar_identity(wchar_t value) {
  return value;
}
%}
