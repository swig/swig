%module python_annotations_typing

%include <std_string.i>
%include <std_wstring.i>
%include <std_complex.i>

// Tests the typing annotations
%feature("python:annotations", "typing");

// The default library 'pytyping' typemaps annotate wrapped C/C++ types as typing.Any.
// Opt this test module in to proxy-name annotations by defining the SWIGTYPE 'pytyping'
// typemaps explicitly, which exercises the $pytypename and $&pytypename special variables.
%typemap(pytyping) SWIGTYPE      "$&pytypename";
%typemap(pytyping) SWIGTYPE []   "typing.Optional[$pytypename]";
%typemap(pytyping) SWIGTYPE *    "typing.Optional[$pytypename]";
%typemap(pytyping) SWIGTYPE &    "$pytypename";
%typemap(pytyping) SWIGTYPE &&   "$pytypename";
%typemap(pytyping) enum SWIGTYPE "int";

// Exercise $*pytypename, which removes one pointer level: for a MyStruct ** argument it
// yields the MyStruct proxy name.
%typemap(pytyping) MyStruct ** "typing.Optional[$*pytypename]";

%feature("python:annotations", "0") no_annotations;

%typemap(pytyping) OptionalInt "typing.Optional[int]";
%typemap(pytyping, out = "$typemap(pytyping, short)") MyType "typing.Union[int, float]";

%typemap(in) OptionalInt {
  $1 = $input == Py_None ? OptionalInt() : OptionalInt(PyLong_AsLong($input));
}
%typemap(out) OptionalInt {
  $result = $1.has_value ? PyLong_FromLong($1.value) : Py_None;
}

// Test that a changed type for MyEnum will be picked up correctly.
%typemap(pytyping) MyEnum "bool";
%rename(MyNamespaced2) MyNamespace::Inner::MyNamespaced1;

// Test a typemap using $pytypename for an enum - it should expand to "int" as Python wraps enums as ints.
%typemap(pytyping) PytypenameEnum "typing.Optional[$pytypename]";

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

%typemap(in) (int argc, char **argv) {
  /* Check if is a list */
  if (PyList_Check($input)) {
    int i;
    $1 = (int)PyList_Size($input);
    $2 = (char **)malloc(($1+1)*sizeof(char *));
    for (i = 0; i < $1; i++) {
      PyObject *o = PyList_GetItem($input, i);
      if (PyBytes_Check(o)) {
        $2[i] = PyBytes_AsString(PyList_GetItem($input, i));
      } else {
        PyErr_SetString(PyExc_TypeError, "list must contain strings");
        SWIG_fail;
      }
    }
    $2[i] = 0;
  } else {
    PyErr_SetString(PyExc_TypeError, "not a list");
    SWIG_fail;
  }
}

%typemap(freearg) (int argc, char **argv) {
  free((char *) $2);
}

%typemap(pytyping) (int argc, char **argv) "typing.List[str]"

%typemap(in, numinputs=0) short *OutAppend (short temp) { $1 = &temp; }
%typemap(argout) (short *OutAppend) {
  $result = SWIG_AppendOutput($result, PyLong_FromLong(*$1));
}
%typemap(pytyping) short *OutAppend "int"
%apply short *OutAppend { short *OutAppend2 };

%inline %{
#include <cstddef>

void take_argv(int argc, char **argv) {}

void take_argv_surround(double before, int argc, char **argv, short after) {}

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
  size_t a_size,
  std::size_t a_stdsize,
  ptrdiff_t a_ptrdiff,
  std::ptrdiff_t a_stdptrdiff,
  const short &a_short_cref,
  const int &a_int_cref,
  const size_t &a_size_cref,
  const std::size_t &a_stdsize_cref,
  const ptrdiff_t &a_ptrdiff_cref,
  const std::ptrdiff_t &a_stdptrdiff_cref
) {}

void argcheck_float(
  float a_float,
  double a_double,
  const double &a_double_cref
) {}

/* long double has no in/out typemaps of its own, so it is wrapped as a pointer to an
   opaque type and a Python float is not accepted. Both forms must stay typing.Any. */
void argcheck_long_double(
  long double a_ldouble,
  const long double &a_ldouble_cref
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

struct MyStruct {
  void do_something(MyStruct& ref, MyStruct* ptr, const MyStruct& cref) {}
};

typedef int MyTypedef;
typedef MyStruct MyStructTypedef;
void use_typedefs(int i, MyTypedef mt, const MyStructTypedef &cref_mst) {}

void use_memberfn_ptr(void (MyStruct::* ptr)(MyStruct&, MyStruct*, const MyStruct&)) {}

void use_member_ptr(int OptionalInt::*ptr) {}

void use_deref(MyStruct **pp) {}

enum MyEnum {
  MyEnumMember1,
  MyEnumMember2,
  MyEnumMember3,
};
typedef MyEnum MyEnumTypedef;

enum MyOtherEnum {
  MyOtherEnumMember1,
  MyOtherEnumMember2,
};
typedef MyOtherEnum MyOtherEnumTypedef;

void use_enums(MyEnum me, MyEnumTypedef met, MyOtherEnum moe, MyOtherEnumTypedef moet) {}

enum PytypenameEnum {
  PytypenameEnumMember1,
};
void use_pytypename_enum(PytypenameEnum e) {}

namespace MyNamespace {
  struct MyNamespaced1 {
    int foo;
  };
  namespace Inner {
    struct MyInner {
      int bar;
    };
    struct MyNamespaced1 {
      int baz;
    };
  }
}

void use_namespaced(MyNamespace::MyNamespaced1 ns1, const MyNamespace::Inner::MyInner &inner1, MyNamespace::Inner::MyNamespaced1 *inner_ns1) {}

void *wrap_ptr(size_t val) { return (void *)val; }
size_t unwrap_ptr(void *ptr) { return (size_t)ptr; }

short &make_short_ref() {
  static short v = 1;
  return v;
}

const short &make_short_cref() {
  static short v = 1;
  return v;
}

MyStruct &make_struct_ref() {
  static MyStruct v;
  return v;
}

const MyStruct &make_struct_cref() {
  static MyStruct v;
  return v;
}

struct HasClassMembers {
  MyStruct member_value;
  MyStruct *member_pointer;
};

// Forward-declared only: no proxy class, so $pytypename falls back to an opaque
// SWIGTYPE_ type wrapper class.
struct ForwardOnly;
void use_forward_only(ForwardOnly *fp) { (void)fp; }

void argoutVoidSingleAppend(bool arg, short *OutAppend) { *OutAppend = 42; }

bool argoutBoolSingleAppend(bool arg, short *OutAppend) {
  *OutAppend = 42;
  return arg;
}

void argoutVoidAppendTwice(bool arg, short *OutAppend, short *OutAppend2) {
  *OutAppend = 42;
  *OutAppend2 = 43;
}

bool argoutBoolAppendTwice(bool arg, short *OutAppend, short *OutAppend2) {
  *OutAppend = 42;
  *OutAppend2 = 43;
  return arg;
}

%}

// A class-typed %constant is annotated at module level.
%constant MyStruct *CONST_STRUCT = 0;
