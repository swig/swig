%module rust_std_list

%include <std_list.i>

%template(IntList) std::list<int>;

%inline %{
#include <list>

int rust_std_list_size(const std::list<int> &values) {
  return (int)values.size();
}

int rust_std_list_sum(const std::list<int> &values) {
  int sum = 0;
  for (std::list<int>::const_iterator it = values.begin(); it != values.end(); ++it)
    sum += *it;
  return sum;
}
%}
