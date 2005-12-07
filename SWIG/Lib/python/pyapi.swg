/* -----------------------------------------------------------------------------
 * Python API portion that goes into the runtime
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#if 0
} /* cc-mode */
#endif
#endif

/* -----------------------------------------------------------------------------
 * Constant declarations
 * ----------------------------------------------------------------------------- */

/* Constant Types */
#define SWIG_PY_POINTER 4
#define SWIG_PY_BINARY  5

/* Constant information structure */
typedef struct swig_const_info {
  int type;
  char *name;
  long lvalue;
  double dvalue;
  void   *pvalue;
  swig_type_info **ptype;
} swig_const_info;

<<<<<<< pyapi.swg
=======


/* -----------------------------------------------------------------------------
 * Safe Py_None and Py_Void accessors
 * ----------------------------------------------------------------------------- */

SWIGRUNTIME PyObject * 
SWIG_Py_None(void)
{
  static PyObject *none = 0;
  if (!none) {
    none = Py_BuildValue("");
    Py_DECREF(none);
  }
  return none;
}

SWIGRUNTIMEINLINE PyObject * 
SWIG_Py_Void(void)
{
  PyObject *none = SWIG_Py_None();
  Py_INCREF(none);
  return none;
}


/* -----------------------------------------------------------------------------
 * Append a value to the result obj
 * ----------------------------------------------------------------------------- */
SWIGINTERN PyObject*
SWIG_Python_AppendOutput(PyObject* result, PyObject* obj) {
  if (!result) {
    result = obj;
  } else if (result == SWIG_Py_None()) {
    Py_DECREF(result);
    result = obj;
  } else {
    if (!PyList_Check(result)) {
      PyObject *o2 = result;
      result = PyList_New(1);
      PyList_SetItem(result, 0, o2);
    }
    PyList_Append(result,obj);
    Py_DECREF(obj);
  }
  return result;
}

>>>>>>> 1.13
#ifdef __cplusplus
#if 0
{ /* cc-mode */
#endif
}
#endif

