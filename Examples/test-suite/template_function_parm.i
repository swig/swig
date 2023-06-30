%module template_function_parm

%include <std_vector.i>

%{
#include <numeric>
static int accumulate_integers(std::vector<int> vi) {
  int sum = std::accumulate(vi.begin(), vi.end(), 0);
  return sum;
}
%}

%inline %{
template<typename A>
struct C {
  int take_function(int fp(std::vector<int>), std::vector<int> v) {
    return fp(v);
  }
};
%}

%constant int accumulate_integers(std::vector<int>);

%template(VectorInt) std::vector<int>;

// seg fault #983
%template(MyC) C<int(std::vector<int>)>;

