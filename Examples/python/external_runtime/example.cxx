#include <Python.h>
#include "swig_runtime.hxx"
#include "example.h"

Function::Function(PyObject * pyCallable)
: pyObj_(pyCallable), meshValue_(0)
{
  if (pyCallable)
  {
    Py_XINCREF(pyCallable);
    PyObject * pyMesh = PyObject_CallMethod(pyObj_, const_cast<char *>("mesh"), const_cast<char *>("()"));
    if (!pyMesh)
      throw std::runtime_error("null pyMesh");
    void * ptr = 0;
    if (SWIG_IsOK(SWIG_ConvertPtr(pyMesh, &ptr, SWIG_TypeQuery("Mesh *"), 0)))
    {
      Mesh *mesh = reinterpret_cast< Mesh * >(ptr);
      if (!mesh)
        throw std::runtime_error("null mesh");
      meshValue_ = mesh->value();
    }
    else
    {
      throw;
    }
    Py_XDECREF(pyMesh);
  }
}
