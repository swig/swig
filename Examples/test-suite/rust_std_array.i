%module rust_std_array

%include <std_array.i>

%template(IntArray3) std::array<int, 3>;

%inline %{
#include <array>

int rust_std_array_sum(const std::array<int, 3> &values) {
  return values[0] + values[1] + values[2];
}
%}
