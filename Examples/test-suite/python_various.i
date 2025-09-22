%module python_various

%inline %{
struct WrappedClass {};

// A unit test for SWIG_PyType_GetFullyQualifiedName
PyObject *GetFullyQualifiedName(PyObject *type) {
  return SWIG_PyType_GetFullyQualifiedName(Py_TYPE(type));
}
%}
