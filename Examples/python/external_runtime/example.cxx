/* File : example.cxx */

#include <Python.h>
#include <stdio.h>
#include "example.h"

#include "swig_runtime.hxx"

MeshCaller::MeshCaller(PyObject *pyCallable) : pyObj_(pyCallable) {
  if (pyObj_) {
    PyObject *pyMesh = PyObject_CallMethod(pyObj_, const_cast<char *>("mesh"), const_cast<char *>("()"));
    if (!pyMesh)
      throw std::runtime_error("null pyMesh");
    void *ptr = 0;

    // Use SWIG_ConvertPtr and SWIG_TypeQuery in the SWIG external runtime
    if (SWIG_IsOK(SWIG_ConvertPtr(pyMesh, &ptr, SWIG_TypeQuery("Mesh *"), 0))) {
      Mesh *mesh = reinterpret_cast<Mesh *>(ptr);
      if (!mesh)
        throw std::runtime_error("null mesh");
      const int value = mesh->value();
      std::cout << "value = "<<value<<std::endl;
      if (value != 42)
        throw std::runtime_error("wrong value");
    } else {
      throw std::runtime_error("SWIG_ConvertPtr failed");
    }
  }
}
