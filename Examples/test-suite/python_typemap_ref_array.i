%module python_typemap_ref_array

// A typemap written with an [ANY] dimension is matched behind a reference to an array as well as on
// an array, with $1_dim0 the dimension of the array the reference refers to.

%typemap(varout) int (&)[ANY] "$result = PyLong_FromLong($1_dim0);"
%typemap(varin)  int (&)[ANY] %{ SWIG_Error(SWIG_AttributeError, "read-only $name"); SWIG_fail; %}
%typemap(in)     int (&)[ANY] %{
  $1 = ($1_ltype)&ten;
  if ($1_dim0 != 10) {
    SWIG_Error(SWIG_RuntimeError, "$1_dim0"); SWIG_fail;
  }
%}

// A locals list on such a pattern used to be parsed as part of the type, registering the typemap
// under a type that is never searched for.
%typemap(in) double (&)[ANY] (double temp[$1_dim0]) "temp[0] = $1_dim0; $1 = ($1_ltype)&temp;"

// A reference to a function used to be registered as the return type alone, so this applied to every
// int rather than to nothing here, and doubled() below returned zero.
%typemap(in) int (&)(int) "$1 = 0;"

%inline %{
#include <cstring>

int numbers[4] = {1, 2, 3, 4};
int (&numbers_ref)[4] = numbers;

int wide[7] = {0, 0, 0, 0, 0, 0, 0};
int (&wide_ref)[7] = wide;

int ten[10] = {42, 0, 0, 0, 0, 0, 0, 0, 0, 0};

// The in typemaps above supply the array, so the argument passed in is ignored.
int first_of(int (&x)[10]) { return x[0]; }
double first_double(double (&x)[3]) { return x[0]; }

int doubled(int x) { return x * 2; }

// Lib/typemaps/strings.swg declares a const Char (&)[ANY] typemap, with locals, that this reaches.
int length_of(const char (&x)[6]) { return (int)strlen(x); }
%}

// A reference to a typedef'd array keeps its declared $1_type and $1_ltype, with $1_dim0 and $1_basetype from the array.
%typemap(varout) long (&)[ANY] %{ $result = Py_BuildValue("(sssi)", "$1_type", "$1_ltype", "$1_basetype", (int)$1_dim0); %}
%typemap(varin)  long (&)[ANY] %{ SWIG_Error(SWIG_AttributeError, "read-only $name"); SWIG_fail; %}

%inline %{
typedef const long ConstSeven[7];
long sevens[7] = {0, 0, 0, 0, 0, 0, 0};
ConstSeven &const_sevens_ref = sevens;
%}
