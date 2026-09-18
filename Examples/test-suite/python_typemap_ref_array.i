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

%inline %{
int numbers[4] = {1, 2, 3, 4};
int (&numbers_ref)[4] = numbers;

int wide[7] = {0, 0, 0, 0, 0, 0, 0};
int (&wide_ref)[7] = wide;

int ten[10] = {42, 0, 0, 0, 0, 0, 0, 0, 0, 0};

// The in typemap above supplies the array, so the argument passed in is ignored.
int first_of(int (&x)[10]) { return x[0]; }
%}

// A reference to a typedef'd array keeps its declared $1_type and $1_ltype, with $1_dim0 and $1_basetype from the array.
%typemap(varout) long (&)[ANY] %{ $result = Py_BuildValue("(sssi)", "$1_type", "$1_ltype", "$1_basetype", (int)$1_dim0); %}
%typemap(varin)  long (&)[ANY] %{ SWIG_Error(SWIG_AttributeError, "read-only $name"); SWIG_fail; %}

%inline %{
typedef const long ConstSeven[7];
long sevens[7] = {0, 0, 0, 0, 0, 0, 0};
ConstSeven &const_sevens_ref = sevens;
%}
