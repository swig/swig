%module python_pyiterator_rename_a

// Per-module rename to avoid SwigPyIterator type collision across modules
#define SwigPyIterator SwigPyIterator_python_pyiterator_rename_a

%include <std_vector.i>
%template(VectorInt) std::vector<int>;

%inline %{
class VecHolder_a {
public:
  std::vector<int> data;
  VecHolder_a() : data({10, 20, 30}) {}
  std::vector<int>& get() { return data; }
};
%}
