%module python_annotations_typing

%include <std_string.i>
%include <std_wstring.i>

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

// Test that a changed type for MyEnum will be picked up correctly.
%typemap(pytyping) MyEnum "bool";
%rename(MyNamespaced2) MyNamespace::Inner::MyNamespaced1;

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

void argcheck_bool(bool a_bool) {}

void argcheck_char(
  char a_char,
  wchar_t a_wchar
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

int &make_int_ref() {
  static int v = 1;
  return v;
}

const int &make_int_cref() {
  static int v = 1;
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

%}
