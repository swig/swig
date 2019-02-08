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
SWIGRUNTIME PyMethodDef *SWIG_PythonGetProxyDoc(const char *name);

/* -----------------------------------------------------------------------------
 * Wrapper of PyInstanceMethod_New() used in Python 3
 * It is exported to the generated module, used for -fastproxy
 * ----------------------------------------------------------------------------- */
SWIGRUNTIME PyObject *SWIG_PyInstanceMethod_New(PyObject *SWIGUNUSEDPARM(self), PyObject *func) {
  if (PyCFunction_Check(func)) {
    PyCFunctionObject *funcobj = (PyCFunctionObject *)func;
    PyMethodDef *ml = SWIG_PythonGetProxyDoc(funcobj->m_ml->ml_name);
    if (ml)
      func = PyCFunction_NewEx(ml, funcobj->m_self, funcobj->m_module);
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
SWIGRUNTIME PyObject *SWIG_PyStaticMethod_New(PyObject *SWIGUNUSEDPARM(self), PyObject *func) {
  if (PyCFunction_Check(func)) {
    PyCFunctionObject *funcobj = (PyCFunctionObject *)func;
    PyMethodDef *ml = SWIG_PythonGetProxyDoc(funcobj->m_ml->ml_name);
    if (ml)
      func = PyCFunction_NewEx(ml, funcobj->m_self, funcobj->m_module);
  }
  return PyStaticMethod_New(func);
}

#ifdef __cplusplus
}
#endif

