%module rust_std_set

%include <std_set.i>

%template(IntSet) std::set<int>;

%inline %{
#include <set>

int rust_std_set_size(const std::set<int> &values) {
  return (int)values.size();
}

int rust_std_set_sum(const std::set<int> &values) {
  int sum = 0;
  for (std::set<int>::const_iterator it = values.begin(); it != values.end(); ++it)
    sum += *it;
  return sum;
}
%}
