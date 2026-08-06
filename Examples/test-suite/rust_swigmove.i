%module rust_swigmove

%include <swigmove.i>

%inline %{
struct RustMoveThing {
  RustMoveThing() : value(0) {}
  int value;
};
%}
