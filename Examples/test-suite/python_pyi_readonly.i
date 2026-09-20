%module python_pyi_readonly

%immutable Widget::readonly_value;
%feature("docstring", "A read only value.") Widget::readonly_value;
#ifdef SWIGPYTHON
%feature("python:annotations", "typing");
%typemap(pytyping, out="int") int, const int "typing.Union[int, float]"
%feature("python:annotations", "0") Untyped::value;
#endif

%inline %{
struct Widget {
  Widget(int value): writable(value), readonly_value(value + 1), constant_value(value + 2) {}
  int writable;
  int readonly_value;
  const int constant_value;
};

struct Untyped {
  Untyped(): value(7) {}
  const int value;
};
%}
