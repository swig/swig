/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */


%insert("header") %{

SWIGINTERN PyObject*
SWIG_Python_ErrorType(int code) {
  switch(code) {
  case SWIG_MemoryError:
    return PyExc_MemoryError;
    break;
  case SWIG_IOError:
    return PyExc_IOError;
    break;
  case SWIG_RuntimeError:
    return PyExc_RuntimeError;
    break;
  case SWIG_IndexError:
    return PyExc_IndexError;
    break;
  case SWIG_TypeError:
    return PyExc_TypeError;
    break;
  case SWIG_DivisionByZero:
    return PyExc_ZeroDivisionError;
    break;
  case SWIG_OverflowError:
    return PyExc_OverflowError;
    break;
  case SWIG_SyntaxError:
    return PyExc_SyntaxError;
    break;
  case SWIG_ValueError:
    return PyExc_ValueError;
    break;
  case SWIG_SystemError:
    return PyExc_SystemError;
    break;
  case SWIG_AttributeError:
    return PyExc_AttributeError;
    break;
  default:
    return PyExc_RuntimeError;
    break;
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

