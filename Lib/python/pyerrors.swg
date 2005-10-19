/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */


%insert("header") %{

SWIGINTERN PyObject*
SWIG_Python_ErrorType(int code) {
  switch(code) {
  case SWIG_MemoryError:
    return PyExc_MemoryError;
  case SWIG_IOError:
    return PyExc_IOError;
  case SWIG_RuntimeError:
    return PyExc_RuntimeError;
  case SWIG_IndexError:
    return PyExc_IndexError;
  case SWIG_TypeError:
    return PyExc_TypeError;
  case SWIG_DivisionByZero:
    return PyExc_ZeroDivisionError;
  case SWIG_OverflowError:
    return PyExc_OverflowError;
  case SWIG_SyntaxError:
    return PyExc_SyntaxError;
  case SWIG_ValueError:
    return PyExc_ValueError;
  case SWIG_SystemError:
    return PyExc_SystemError;
  case SWIG_AttributeError:
    return PyExc_AttributeError;
  default:
    return PyExc_RuntimeError;
  }
}

SWIGINTERN void
SWIG_Python_SetErrorMsg(PyObject *type, const char *mesg) {
  PyErr_SetString(type, mesg);
}

SWIGINTERNINLINE void
SWIG_Python_SetExceptionObj(swig_type_info *desc, PyObject *obj) {
  PyErr_SetObject((desc && desc->clientdata ? (PyObject *)(desc->clientdata) : PyExc_RuntimeError), obj);
}
 

SWIGINTERN void
SWIG_Python_AddErrorMsg(const char* mesg)
{
  PyObject *type = 0;
  PyObject *value = 0;
  PyObject *traceback = 0;

  if (PyErr_Occurred()) PyErr_Fetch(&type, &value, &traceback);
  if (value) {
    PyObject *old_str = PyObject_Str(value);
    Py_XINCREF(type);
    PyErr_Clear();
    PyErr_Format(type, "%s %s", PyString_AsString(old_str), mesg);
    Py_DECREF(old_str);
  } else {
    PyErr_Format(PyExc_RuntimeError, mesg);
  }
}

%}

