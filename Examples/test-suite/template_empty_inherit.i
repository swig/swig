%module template_empty_inherit

%rename(FunctorOperator) operator();

%inline %{
template<class Arg, typename Result> struct Functor {
  virtual Result operator()(Arg x) const = 0;
  virtual ~Functor() {}
};
%}

// Bug fix - %ignore was resulting in this warning:
// Warning 401: Base class 'Functor< int,int >' has no name as it is an empty template instantiated with '%template()'. Ignored.
%ignore Functor<int, int>;
%template() Functor<int, int>;

%inline %{
#include <algorithm>
#include <iterator>
struct SquareFunctor : Functor<int, int> {
  int operator()(int v) const { return v*v; }
};
%}

%include <std_vector.i>
%template(VectorInt) std::vector<int>;

%inline %{
std::vector<int> squares(const std::vector<int>& vi) {
  std::vector<int> result;
  std::transform(vi.begin(), vi.end(), std::back_inserter(result), SquareFunctor());
  return result;
}
%}
