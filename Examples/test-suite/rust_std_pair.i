%module rust_std_pair

%include <std_pair.i>

%template(IntPair) std::pair<int, int>;

%inline %{
#include <utility>

std::pair<int, int> rust_std_pair_make(int first, int second) {
  return std::pair<int, int>(first, second);
}

int rust_std_pair_sum(const std::pair<int, int> &value) {
  return value.first + value.second;
}
%}
