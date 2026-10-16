%module python_nondynamic_cpp

// Tests of the nondynamic feature, see python_nondynamic.i, which need C++.

%pythonnondynamic;

// The elements returned by __getitem__() keep a reference to their container,
// which must be possible even though they don't allow adding attributes.
%include <std_vector.i>

%inline %{
  struct Element
  {
    int value;
  };
%}

%template(VectorElement) std::vector<Element>;
