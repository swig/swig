%module python_various

%inline %{
struct WrappedClass {};

// A unit test for SWIG_PyType_GetFullyQualifiedName
PyObject *GetFullyQualifiedName(PyObject *type) {
  return SWIG_PyType_GetFullyQualifiedName(Py_TYPE(type));
}
%}

%include <typemaps.i>
%apply int *INOUT { int *inout1 }
%inline %{
PyObject * pyobject_test(int *inout1) {
  PyObject *result = NULL;
  if (*inout1 > 0) {
    *inout1 *= 10;
    result = PyList_New(1);
    if (result) {
      PyObject *none = Py_None;
      SWIG_Py_INCREF(none);
      PyList_SET_ITEM(result, 0, none);
    }
  }
  if (!result) {
    PyErr_SetString(PyExc_ArithmeticError, "value is negative or PyList_New failed");
  }
  return result;
}
%}
