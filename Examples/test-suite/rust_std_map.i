%module rust_std_map

%include <std_map.i>

%template(IntIntMap) std::map<int, int>;

%inline %{
#include <map>

int rust_std_map_size(const std::map<int, int> &values) {
  return (int)values.size();
}

int rust_std_map_sum_values(const std::map<int, int> &values) {
  int sum = 0;
  for (std::map<int, int>::const_iterator it = values.begin(); it != values.end(); ++it)
    sum += it->second;
  return sum;
}
%}
