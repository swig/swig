%module python_annotations_c

// Tests the C/C++ annotations that were automatically added by using -py3 before swig-4.1.0
// In swig-4.1.0 and later, the feature below is needed as the -py3 option was dropped
%feature("python:annotations", "c") mymethod;
%feature("python:annotations", "c") makeT<short>;
%feature("python:annotations", "c") global_ints;
%feature("python:annotations", "c") global_overloaded;
%feature("python:annotations", "c") suppressed_none;
%feature("python:annotations", "c") suppressed_one;

%inline %{
namespace Space {
template<class T>
struct Template {
  void mymethod(int, Template* tt) {}
};
}
template<typename T>
Space::Template<T> makeT(int x) {
  return Space::Template<T>();
}
int *global_ints(int &ri, Space::Template<short> t) { return &ri; }
int *global_overloaded(int &ri) { return &ri; }
int *global_overloaded() { return NULL; }
int *no_annotations(int &ri, const char *c) { return NULL; }
%}
%template(TemplateShort) Space::Template<short>;
%template(MakeShort) makeT<short>;

/* An out typemap declaring numoutputs=0 leaves nothing to return, which is annotated the way a
   void function is rather than with the suppressed C return type. */
%typemap(out, numoutputs=0) MyErr ""
%typemap(ret) MyErr %{
  if ($1 != 0) {
    PyErr_Format(PyExc_RuntimeError, "error code %d", (int)$1);
    SWIG_fail;
  }
%}

%typemap(in, numinputs=0) short *OutAppend (short temp) { $1 = &temp; }
%typemap(argout) short *OutAppend {
  $result = SWIG_AppendOutput($result, PyLong_FromLong(*$1));
}

%inline %{
typedef int MyErr;
MyErr suppressed_none(int code) { return code; }
MyErr suppressed_one(int code, short *OutAppend) { *OutAppend = 42; return code; }
%}

%inline %{
#ifdef SWIGPYTHON_BUILTIN
int is_python_builtin() { return 1; }
#else
int is_python_builtin() { return 0; }
#endif

#if defined SWIGPYTHON_FASTPROXY
int is_python_fastproxy() { return 1; }
#else
int is_python_fastproxy() { return 0; }
#endif
%}
