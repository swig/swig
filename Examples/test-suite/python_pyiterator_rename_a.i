%module python_pyiterator_rename_a

// Per-module rename to avoid SwigPyIterator type collision across modules
#define SwigPyIterator SwigPyIterator_python_pyiterator_rename_a

%include <std_vector.i>
%template(VectorInt) std::vector<int>;

%inline %{
class VecHolder_a {
public:
  std::vector<int> data;
  VecHolder_a() {
    data.push_back(10);
    data.push_back(20);
    data.push_back(30);
  }
  std::vector<int>& get() { return data; }
};
%}
