/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

SWIGRUNTIME PyObject*
SWIG_Python_ErrorType(int code) {
  PyObject* type = 0;
  switch(code) {
  case SWIG_MemoryError:
    type = PyExc_MemoryError;
    break;
  case SWIG_IOError:
    type = PyExc_IOError;
    break;
  case SWIG_RuntimeError:
    type = PyExc_RuntimeError;
    break;
  case SWIG_IndexError:
    type = PyExc_IndexError;
    break;
  case SWIG_TypeError:
    type = PyExc_TypeError;
    break;
  case SWIG_DivisionByZero:
    type = PyExc_ZeroDivisionError;
    break;
  case SWIG_OverflowError:
    type = PyExc_OverflowError;
    break;
  case SWIG_SyntaxError:
    type = PyExc_SyntaxError;
    break;
  case SWIG_ValueError:
    type = PyExc_ValueError;
    break;
  case SWIG_SystemError:
    type = PyExc_SystemError;
    break;
  case SWIG_AttributeError:
    type = PyExc_AttributeError;
    break;
  case SWIG_NullReferenceError:
    type = PyExc_TypeError;
    break;
  default:
    type = PyExc_RuntimeError;
  }
  return type;
}


SWIGRUNTIME void
SWIG_Python_AddErrorMsg(const char* mesg)
{
  PyObject *type = 0;
  PyObject *value = 0;
  PyObject *traceback = 0;

  if (PyErr_Occurred())
    PyErr_Fetch(&type, &value, &traceback);
  if (value) {
    PyObject *old_str = PyObject_Str(value);
    PyObject *bytes = NULL;
    const char *tmp = SWIG_PyUnicode_AsUTF8AndSize(old_str, NULL, &bytes);
    PyErr_Clear();
    SWIG_Py_XINCREF(type);
    if (tmp)
      PyErr_Format(type, "%s %s", tmp, mesg);
    else
      PyErr_Format(type, "%s", mesg);
    SWIG_Py_XDECREF(bytes);
    SWIG_Py_DECREF(old_str);
    SWIG_Py_DECREF(value);
  } else {
    PyErr_SetString(PyExc_RuntimeError, mesg);
  }
}

SWIGRUNTIME int
SWIG_Python_TypeErrorOccurred(PyObject *obj)
{
  PyObject *error;
  if (obj)
    return 0;
  error = PyErr_Occurred();
  return error && PyErr_GivenExceptionMatches(error, PyExc_TypeError);
}

SWIGRUNTIME void
SWIG_Python_RaiseOrModifyTypeError(const char *message)
{
  if (SWIG_Python_TypeErrorOccurred(NULL)) {
    /* Use existing TypeError to preserve stacktrace and enhance with given message */
    PyObject *newvalue;
    PyObject *type = NULL, *value = NULL, *traceback = NULL;
    PyErr_Fetch(&type, &value, &traceback);
    newvalue = PyUnicode_FromFormat("%S\nAdditional information:\n%s", value, message);
    if (newvalue) {
      SWIG_Py_XDECREF(value);
      PyErr_Restore(type, newvalue, traceback);
    } else {
      PyErr_Restore(type, value, traceback);
    }
  } else {
    /* Raise TypeError using given message */
    PyErr_SetString(PyExc_TypeError, message);
  }
}

/* Append an optional argument description without allowing diagnostic callbacks
   to replace the original exception. All objects retained across Python calls
   own their references, including the tuple built for METH_O wrappers. */
SWIGRUNTIME void
SWIG_Python_AddArgumentDescription(const char *module_name, const char *callback_name, PyObject *args, int single_argument)
{
  PyObject *type = NULL, *value = NULL, *traceback = NULL;
  PyObject *module, *callback = NULL, *arguments = NULL, *result = NULL, *description = NULL, *bytes = NULL;
  const char *text = NULL;
  if (!PyErr_ExceptionMatches(PyExc_TypeError))
    return;
  PyErr_Fetch(&type, &value, &traceback);
  module = PyDict_GetItemString(PyImport_GetModuleDict(), module_name);
  if (module && PyModule_Check(module)) {
    callback = PyDict_GetItemString(PyModule_GetDict(module), callback_name);
    SWIG_Py_XINCREF(callback);
    if (callback && PyCallable_Check(callback)) {
      if (single_argument)
        arguments = args ? PyTuple_Pack(1, args) : PyTuple_New(0);
      else if (args && PyTuple_Check(args)) {
        arguments = args;
        SWIG_Py_INCREF(arguments);
      } else if (!args)
        arguments = PyTuple_New(0);
      if (arguments)
        result = PyObject_CallObject(callback, arguments);
      if (result)
        description = PyUnicode_FromFormat("You have: %R", result);
      if (description)
        bytes = PyUnicode_AsUTF8String(description);
      if (bytes)
        text = PyBytes_AsString(bytes);
    }
  }
  SWIG_Py_XDECREF(description);
  SWIG_Py_XDECREF(result);
  SWIG_Py_XDECREF(arguments);
  SWIG_Py_XDECREF(callback);
  PyErr_Clear();
  PyErr_Restore(type, value, traceback);
  if (text)
    SWIG_Python_RaiseOrModifyTypeError(text);
  SWIG_Py_XDECREF(bytes);
}
