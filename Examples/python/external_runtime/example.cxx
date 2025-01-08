#include <Python.h>
#include "swig_runtime.hxx"
#include "example.h"

Function::Function(PyObject * pyCallable)
: pyObj_(pyCallable), meshValue_(0)
{
  // stuff happens in the typemap of PyObject * pyCallable
}
