%module rust_std_unordered_set

%include <std_unordered_set.i>

%inline %{
#include <unordered_set>

int rust_std_unordered_set_sum_values(const std::unordered_set<int> &values) {
  int total = 0;
  std::unordered_set<int>::const_iterator it;
  for (it = values.begin(); it != values.end(); ++it)
    total += *it;
  return total;
}
%}

%template(IntUnorderedSet) std::unordered_set<int>;
