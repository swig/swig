%module python_annotations_typing

%include <std_string.i>
%include <std_wstring.i>
%include <std_complex.i>

// Tests the typing annotations
%feature("python:annotations", "typing");

%feature("python:annotations", "0") no_annotations;

%typemap(pytyping) OptionalInt "typing.Optional[int]";
%typemap(pytyping, out = "$typemap(pytyping, short)") MyType "typing.Union[int, float]";

%typemap(in) OptionalInt {
  $1 = $input == Py_None ? OptionalInt() : OptionalInt(PyLong_AsLong($input));
}
%typemap(out) OptionalInt {
  $result = $1.has_value ? PyLong_FromLong($1.value) : Py_None;
}

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

void argcheck_bool(
  bool a_bool,
  const bool &a_bool_cref
) {}

void argcheck_char(
  char a_char,
  wchar_t a_wchar,
  const char &a_char_cref
) {}

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
  unsigned long long a_ullong,
  const short &a_short_cref,
  const int &a_int_cref
) {}

void argcheck_float(
  float a_float,
  double a_double,
  const double &a_double_cref
) {}

void argcheck_complex(
  std::complex<float> a_cfloat,
  std::complex<double> a_cdouble,
  const std::complex<double> &a_cdouble_cref
) {}

void argcheck_str(
  const char* a_cstr,
  const wchar_t *a_wcstr,
  std::string a_stdstr,
  std::wstring a_stdwstr,
  const std::string &a_stdstr_cref
) {}

void argcheck_fnptr(int(*f)(char, bool)) {}
void argcheck_array(float arr[3]) {}

struct OptionalInt {
  OptionalInt() : has_value(false) {}
  OptionalInt(int i) : has_value(true), value(i) {}
  bool has_value;
  int value;
};

OptionalInt optional_square(OptionalInt i) {
  if (i.has_value)
    return OptionalInt(i.value * i.value);
  return OptionalInt();
}

struct MyType {};
MyType docs_do_something_out_type(MyType t) { return MyType(); }

%}
