%module swig_exception_default

#ifdef SWIGC
// There is no SWIG_CException when wrapping C code, so the wrapper passes the error to this SWIG_exception macro
%begin %{
#define SWIG_exception(code, msg) (error_code = (code), error_msg = (msg))
%}
%inline %{
int error_code = 0;
const char *error_msg = 0;
%}
#endif

// SWIG_exception without %include <exception.i>, in a typemap (canthrow=1 for C, C# and D) and in %exception code
%typemap(check, canthrow=1) int positive {
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
