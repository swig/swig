%module rust_std_wstring

%include <std_wstring.i>

%inline %{
#include <string>

size_t rust_wstring_size(const std::wstring &value) {
  return value.size();
}
%}
