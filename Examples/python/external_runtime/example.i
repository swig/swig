/* File : example.i */
%module(docstring="external runtime") example
%{
#include "example.h"
%}

%typemap(in) PyObject * pyCallable
{
  if ($input)
  {
    PyObject * pyMesh = PyObject_CallMethod($input, const_cast<char *>("mesh"), const_cast<char *>("()"));
    if (!pyMesh)
      throw std::runtime_error("null pyMesh");
    void * ptr = 0;
    if (SWIG_IsOK(SWIG_ConvertPtr(pyMesh, &ptr, SWIG_TypeQuery("Mesh *"), 0)))
    {
      Mesh *mesh = reinterpret_cast< Mesh * >(ptr);
      if (!mesh)
        throw std::runtime_error("null mesh");
      const int value = mesh->value();
      std::cout << "value="<<value<<std::endl;
      if (value != 42)
        throw std::runtime_error("wrong value");
    }
  }
}


%include "example.h"

%inline %{
// The -builtin SWIG option results in SWIGPYTHON_BUILTIN being defined
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
