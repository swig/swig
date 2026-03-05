%module python_pyiterator_rename_b

// Per-module rename to avoid SwigPyIterator type collision across modules
#define SwigPyIterator SwigPyIterator_python_pyiterator_rename_b

%include <std_vector.i>
%template(VectorInt) std::vector<int>;

%inline %{
std::vector<int> make_vector_b() {
  return {40, 50, 60};
}
%}
