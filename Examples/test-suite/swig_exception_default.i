%module swig_exception_default

// SWIG_exception without %include <exception.i>, in a typemap and in %exception code
%typemap(check) int positive {
  if ($1 <= 0)
    SWIG_exception(SWIG_ValueError, "Expected a positive value.");
}

%exception positive_result {
  $action
  if (result <= 0)
    SWIG_exception(SWIG_ValueError, "Expected a positive result.");
}

%inline %{
int positive_only(int positive) {
  return positive;
}

int positive_result(int value) {
  return value;
}
%}
