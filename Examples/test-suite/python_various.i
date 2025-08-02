%module python_various

%inline %{
struct WrappedClass {};

// A unit test for SWIG_PyType_GetFullyQualifiedName
PyObject *GetFullyQualifiedName(PyObject *type) {
#if PY_VERSION_HEX >= 0x03000000
  return SWIG_PyType_GetFullyQualifiedName(Py_TYPE(type));
#else
  return type;
#endif
}
%}
