%module python_typemap_numoutputs

// Test the numoutputs and overwrite attributes on the out and argout typemaps.

%include "typemaps.i"

// An out typemap that does not return the function return value. The error code is
// turned into an exception instead, so only the argout values are returned.
%typemap(out, numoutputs=0) MyErr ""

%typemap(ret) MyErr %{
  if ($1 != 0) {
    PyErr_Format(PyExc_RuntimeError, "error code %d", (int)$1);
    SWIG_fail;
  }
%}

%apply int *OUTPUT { int *out1, int *out2 };

%inline %{
typedef int MyErr;

MyErr suppressed_two(int code, int *out1, int *out2) { *out1 = 11; *out2 = 12; return code; }
MyErr suppressed_one(int code, int *out1) { *out1 = 11; return code; }
MyErr suppressed_none(int code) { return code; }
%}
