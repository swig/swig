%typemap(throws,noblock=1) (...) {
  SWIG_exception(SWIG_RuntimeError,"unknown exception");
}

%fragment("SWIG_exception");
