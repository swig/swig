%typemap(throws,noblock=1) (...) {
  SWIG_exception(SWIG_RuntimeError,"unknown exception");
}

%fragment("SWIG_exception_fail");
%insert("runtime") %{
#define SWIG_exception(code, msg) SWIG_exception_fail(code, msg)
%}
