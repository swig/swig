%module rust_std_string

%include <std_string.i>

%inline %{
#include <string>

std::string echo_string(std::string value) {
  return value + "!";
}

size_t string_size(const std::string &value) {
  return value.size();
}
%}
