/* -----------------------------------------------------------------------------
 * Python API portion that goes into the runtime
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
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
  const char *name;
  long lvalue;
  double dvalue;
  void   *pvalue;
  swig_type_info **ptype;
} swig_const_info;

/* -----------------------------------------------------------------------------
 * Function to find the method definition with the correct docstring for the
 * proxy module as opposed to the low-level API
 * ----------------------------------------------------------------------------- */
PyMethodDef* getProxyDoc(const char* name);

/* -----------------------------------------------------------------------------
 * Wrapper of PyInstanceMethod_New() used in Python 3
 * It is exported to the generated module, used for -fastproxy
 * ----------------------------------------------------------------------------- */
SWIGRUNTIME PyObject* SWIG_PyInstanceMethod_New(PyObject *SWIGUNUSEDPARM(self), PyObject *func)
{
  if (PyCFunction_Check(func)) {
    /* Unpack the existing PyCFunction */
    PyMethodDef* ml = ((PyCFunctionObject*) func)->m_ml;
    PyObject* self = ((PyCFunctionObject*) func)->m_self;
    PyObject* module = ((PyCFunctionObject*) func)->m_module;
    /* Use the copy with the modified docstring if available */
    ml = getProxyDoc(ml->ml_name);
    if (ml != NULL) {
      func = PyCFunction_NewEx(ml, self, module);
    }
  }
#if PY_VERSION_HEX >= 0x03000000
  return PyInstanceMethod_New(func);
#else
  return PyMethod_New(func, NULL, NULL);
#endif
}

/* -----------------------------------------------------------------------------
 * Wrapper of PyStaticMethod_New()
 * It is exported to the generated module, used for -fastproxy
 * ----------------------------------------------------------------------------- */
SWIGRUNTIME PyObject* SWIG_PyStaticMethod_New(PyObject *SWIGUNUSEDPARM(self), PyObject *func)
{
  if (PyCFunction_Check(func)) {
    /* Unpack the existing PyCFunction */
    PyMethodDef* ml = ((PyCFunctionObject*) func)->m_ml;
    PyObject* self = ((PyCFunctionObject*) func)->m_self;
    PyObject* module = ((PyCFunctionObject*) func)->m_module;
    /* Use the copy with the modified docstring if available */
    ml = getProxyDoc(ml->ml_name);
    if (ml != NULL) {
      func = PyCFunction_NewEx(ml, self, module);
    }
  }
  return PyStaticMethod_New(func);
}

#ifdef __cplusplus
}
#endif

