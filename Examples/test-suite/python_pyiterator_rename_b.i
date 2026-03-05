%module python_pyiterator_rename_b

// Per-module rename to avoid SwigPyIterator type collision across modules
#define SwigPyIterator SwigPyIterator_python_pyiterator_rename_b

%include <std_vector.i>
%template(VectorInt) std::vector<int>;

%inline %{
class VecHolder_b {
public:
  std::vector<int> data;
  VecHolder_b() : data({40, 50, 60}) {}
  std::vector<int>& get() { return data; }
};
%}
