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

/* Overload dispatch support: incremented by each keyword argument enabled wrapper after its arguments are
   successfully parsed and converted, just before executing the wrapped call. The dispatch wrapper reads it
   before calling an overload to tell a signature mismatch (unchanged, try the next overload) from an error
   raised while executing a matched overload (changed, propagate immediately). Per-thread storage is required
   as the GIL is released while the wrapped call runs, so another thread could otherwise increment the count
   between the save and the check in the dispatch wrapper. Where no thread local storage is available the
   counter degrades to a plain process wide static and the dispatch wrapper retries on any "TypeError",
   giving up the matched overload distinction rather than silently changing which exception the caller sees.
   Note that argument conversion itself may run Python code, such as the "index" method for the "i" format
   or a "typemap(in)" body calling back into Python, and a nested keyword dispatch then increments the count
   before this overload has matched. That reentrant case is exotic and untested; a conversion "TypeError"
   there may propagate instead of trying the next overload. */
#if defined(_MSC_VER) && !defined(__clang__)
#define SWIG_PYTHON_PARSE_COUNT_IS_THREAD_LOCAL 1
static SWIGUNUSED __declspec(thread) unsigned long SWIG_Python_parse_count = 0;
#elif defined(__GNUC__) || defined(__clang__)
#define SWIG_PYTHON_PARSE_COUNT_IS_THREAD_LOCAL 1
static SWIGUNUSED __thread unsigned long SWIG_Python_parse_count = 0;
#elif defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
#define SWIG_PYTHON_PARSE_COUNT_IS_THREAD_LOCAL 1
static SWIGUNUSED _Thread_local unsigned long SWIG_Python_parse_count = 0;
#elif defined(__cplusplus) && __cplusplus >= 201103L
#define SWIG_PYTHON_PARSE_COUNT_IS_THREAD_LOCAL 1
static SWIGUNUSED thread_local unsigned long SWIG_Python_parse_count = 0;
#else
/* No thread local storage available, the dispatch wrapper retries on any "TypeError" (see above). */
static SWIGUNUSED unsigned long SWIG_Python_parse_count = 0;
#endif

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
