%module python_annotations_variable_c

// Tests Python variable annotations, containing C/C++ types, in C++ member variables wrappers.
// Member variables are wrapped using Python properties.
// This is in a separate test to python_annotations_c.i (which tests function annotations) so that runtime testing
// of variable annotations can be done which requires Python 3.6 and later. A syntax error occurs in earlier
// versions of Python when importing code containing variable annotations.

%feature("python:annotations", "c");
%feature("python:annotations:novar") member_variable_not_annotated;


%inline %{
namespace Space {
template<class T>
struct Template {
  int member_variable;
  int member_variable_not_annotated;
};
struct StructWithVar{
  int member_variable;
};
struct StructWithVarNotAnnotated {
  int member_variable_not_annotated;
};
short global_variable;
}
%}
%template(TemplateShort) Space::Template<short>;

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

