%module not_c_keywords

%extend ComplexStruct {
void init() {
  $self->complex = 123;
}
}

%inline %{
struct ComplexStruct {
  int complex; /* complex as variable name */
};
%}

/* A global function named 'this' is called by that name in the generated wrapper, which Octave and
   Javascript (v8/napi) compile as C++ even for a C interface. */
#if !defined(SWIGOCTAVE) && !defined(SWIG_JAVASCRIPT_V8) && !defined(SWIG_JAVASCRIPT_NAPI)

/* SWIG renames a target language keyword itself, but the test suite's -Werror makes that warning fatal
   and the name it picks varies by language, so rename explicitly for the runme tests. */
%rename(this_function) ::this;

%inline %{
int this(int v) { /* this as function name */
  return v + 1;
}
%}
#endif
