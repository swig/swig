%module python_annotations_variable_typing

// Tests Python variable annotations, containing PEP 484 types, in C++ member variables wrappers.
// Member variables are wrapped using Python properties.

%feature("python:annotations", "typing");
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

