%module python_customdoc

#ifdef SWIGPYTHON
%feature("customdoc", "1");
%feature("python:customdoc:argtypes", "python_customdoc.describe_arguments");
%feature("python:customdoc:argtypes", "swig_customdoc_unloaded.describe") repeated;
%feature("python:customdoc:argtypes", "0") disabled_description;
%feature("python:customdoc:argtypes", "0") empty_description;
%feature("python:customdoc:argtypes", "") empty_description;
%feature("customdoc:main", "$name: $brief\n$overview$main");
%feature("customdoc:arg:normal:style_error", "$type");
%feature("customdoc:arg:only:out", "$type");
%feature("customdoc:proto:void", "$name($in)");
%feature("customdoc:proto:single_out", "$name($in) -> $out");
%feature("customdoc:proto:normal", "$name($in) -> ($out)");
%feature("customdoc:proto:constructor", "$name($in)");
%feature("customdoc:group", "GROUP\n$group$main\n");
%feature("docstring", "Integer input.\nDetailed integer documentation.") choose(int);
%feature("docstring", "Floating input.\nDetailed floating documentation.") choose(double);
%feature("docstring", "An integer method.") Example::method;
%feature("docstring", "Quote \"\"\" and backslash \\ stay intact.") quoted;
%typemap(in, doc="integer") int {
  $1 = (int)PyLong_AsLong($input);
  if (PyErr_Occurred()) SWIG_fail;
}
%typemap(out, doc="integer") int {
  $result = PyLong_FromLong($1);
}

%include <typemaps.i>
%typemap(in, numinputs=0) int *OUTPUT (int temporary) {
  $1 = &temporary;
}
%typemap(argout, doc="integer") int *OUTPUT {
  $result = SWIG_Python_AppendOutput($result, PyLong_FromLong(*$1), $isvoid);
}
%typemap(argout, doc="integer") int *INOUT = int *OUTPUT;
%apply int *OUTPUT { int *out };
%apply int *INOUT { int *inout };
%exception fail_value {
  $action
  PyErr_SetString(PyExc_ValueError, "original error");
  SWIG_fail;
}
%feature("customdoc:proto:single_out:style_error", "quoted \"$name\"($in)\nnext line") escaped;

#endif

%inline %{
int choose(int value) { return value; }
double choose(double value) { return value; }
int singleton(int value) { return value; }
int repeated(int value) { return value; }
void quoted() {}
int escaped(int value) { return value; }
int fail_value(int value) { return value; }
struct Example {
  Example(int value): value(value) {}
  int method(int argument) { return value + argument; }
  static int twice(int argument) { return 2 * argument; }
  int value;
};
int outputs(int value, int *out, int *inout) {
  *out = value + 1;
  *inout += value;
  return value;
}
%}

#ifdef SWIGPYTHON
%feature("customdoc:main", "") default_format;
%feature("customdoc:proto:single_out", "") default_format;
%feature("customdoc:arg:only:out", "") default_format;
%feature("customdoc:arg:normal:in:style_error", "kind=$type") directional;
%feature("customdoc:proto:single_out:style_error", "$name($in)") directional;
%feature("docstring", "The same documentation.") shared(int);
%feature("docstring", "The same documentation.") shared(double);
#endif
%inline %{
int default_format(int value) { return value; }
int directional(int value) { return value; }
int shared(int value) { return value; }
double shared(double value) { return value; }
%}

#ifdef SWIGPYTHON
%feature("docstring", "Literal $overview, $main and $brief stay intact.\nBody contains $group and $proto.") literal_placeholders;
%feature("docstring", "Before \\\"\"\" after \\ path \\u1234 and café.") backslash_quotes;
%feature("docstring", "Both triple quotes: \"\"\" and ''' and trailing slash\\") quote_kinds;
%feature("customdoc:arg:noname", "$i/$ip") unnamed;
%typemap(in, doc="literal $name $in $out") int labelled {
  $1 = (int)PyLong_AsLong($input);
  if (PyErr_Occurred()) SWIG_fail;
}
#endif
%inline %{
void literal_placeholders() {}
void backslash_quotes() {}
void quote_kinds() {}
int labelled_type(int labelled) { return labelled; }
int unnamed(int, int) { return 0; }
%}

#ifdef SWIGPYTHON
%exception fail_zero {
  PyErr_SetString(PyExc_TypeError, "zero argument failure");
  SWIG_fail;
}
#endif
%inline %{
void fail_zero() {}
int disabled_description(int value) { return value; }
int empty_description(int value) { return value; }
%}
