%module python_customdoc_c

#ifdef SWIGPYTHON
%feature("customdoc", "1");
%feature("python:customdoc:argtypes", "python_customdoc_c.describe_arguments");
%feature("customdoc:main", "$overview");
%feature("customdoc:arg:normal:style_error", "$type");
#endif

%inline %{
int add(int left, int right) {
  return left + right;
}
%}
