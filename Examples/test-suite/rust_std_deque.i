%module rust_std_deque

%include <std_deque.i>

%template(IntDeque) std::deque<int>;

%inline %{
#include <deque>

int rust_std_deque_size(const std::deque<int> &values) {
  return (int)values.size();
}

int rust_std_deque_sum(const std::deque<int> &values) {
  int sum = 0;
  for (std::deque<int>::const_iterator it = values.begin(); it != values.end(); ++it)
    sum += *it;
  return sum;
}
%}
