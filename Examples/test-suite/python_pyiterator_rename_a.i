%module python_pyiterator_rename_a

// Per-module rename to avoid SwigPyIterator type collision across modules
#define SwigPyIterator SwigPyIterator_python_pyiterator_rename_a

%include <std_vector.i>
%template(VectorInt) std::vector<int>;

%inline %{
std::vector<int> make_vector_a() {
  return {10, 20, 30};
}
%}
