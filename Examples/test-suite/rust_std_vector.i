%module rust_std_vector

%include <std_vector.i>

%template(IntVector) std::vector<int>;

%inline %{
#include <vector>

int vector_sum(const std::vector<int> &values) {
  int result = 0;
  for (std::vector<int>::const_iterator it = values.begin(); it != values.end(); ++it)
    result += *it;
  return result;
}
%}
