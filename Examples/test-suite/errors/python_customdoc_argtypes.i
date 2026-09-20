%module python_customdoc_argtypes
%feature("customdoc", "1");
%feature("python:customdoc:argtypes", "unqualified");
int invalid(int value);
