%module python_annotations_typing

%include <std_string.i>
%include <std_wstring.i>

// Tests the typing annotations
%feature("python:annotations", "typing") mymethod;
%feature("python:annotations", "typing") makeT<short>;
%feature("python:annotations", "typing") global_ints;
%feature("python:annotations", "typing") argcheck_bool;
%feature("python:annotations", "typing") argcheck_char;
%feature("python:annotations", "typing") argcheck_int;
%feature("python:annotations", "typing") argcheck_float;
%feature("python:annotations", "typing") argcheck_str;
%feature("python:annotations", "typing") use_callable;

%typemap(pytyping) MyCallable "typing.Callable[[]]";

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
};
int *global_ints(int &ri, Space::Template<short> t) { return &ri; }
int *global_overloaded(int &ri) { return &ri; }
int *global_overloaded() { return NULL; }
int *no_annotations(int &ri, const char *c) { return NULL; }
%}
%template(TemplateShort) Space::Template<short>;
%template(MakeShort) makeT<short>;

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

%inline %{

void argcheck_bool(bool a_bool) {}

void argcheck_char(
  char a_char,
  wchar_t a_wchar
) {};

void argcheck_int(
  signed char a_schar,
  unsigned char a_uchar,
  short a_short,
  unsigned short a_ushort,
  int a_int,
  unsigned int a_uint,
  long a_long,
  unsigned long a_ulong,
  long long a_llong,
  unsigned long long a_ullong
) {}

void argcheck_float(
  float a_float,
  double a_double
) {}

void argcheck_str(
  const char* a_cstr,
  const wchar_t *a_wcstr
) {}

struct MyCallable {
  void operator()() {}
};

void use_callable(MyCallable c){}

%}
