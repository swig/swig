%module rust_std_unordered_map

%include <std_unordered_map.i>

%inline %{
#include <unordered_map>

int rust_std_unordered_map_sum_values(const std::unordered_map<int, int> &values) {
  int total = 0;
  std::unordered_map<int, int>::const_iterator it;
  for (it = values.begin(); it != values.end(); ++it)
    total += it->second;
  return total;
}
%}

%template(IntIntUnorderedMap) std::unordered_map<int, int>;
