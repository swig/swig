%module rust_std_string_view

%include <std_string_view.i>

%inline %{
#include <string_view>

size_t rust_string_view_size(std::string_view value) {
  return value.size();
}
%}
