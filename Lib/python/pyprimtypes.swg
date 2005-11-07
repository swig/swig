/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE PyObject*
  SWIG_From_dec(bool)(bool value)
{
  PyObject *obj = value ? Py_True : Py_False;
  Py_INCREF(obj);
  return obj;
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
SWIG_AsVal_dec(bool)(PyObject *obj, bool *val)
{
  if (obj == Py_True) {
    if (val) *val = true;
    return SWIG_OK;
  } else if (obj == Py_False) {
    if (val) *val = false;
    return SWIG_OK;
  } else {
    long v = 0;
    int res = SWIG_AsVal(long)(obj, val ? &v : 0);
    if (res == SWIG_OK && val) *val = v ? true : false;
    return res;
  }
}
}

/* long */

%fragment(SWIG_From_frag(long),"header",
	  fragment="<limits.h>") {
  %define_as(SWIG_From_dec(long),           PyInt_FromLong)
}

%fragment(SWIG_AsVal_frag(long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(long)(PyObject *obj, long* val)
{
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return SWIG_OK;
  } else if (PyLong_Check(obj)) {
    long v = PyLong_AsLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  }
  return SWIG_TypeError;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
	  fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE PyObject* 
SWIG_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLong(value) : PyInt_FromLong(%numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(PyObject *obj, unsigned long *val) 
{
  if (PyInt_Check(obj)) {
    long v = PyInt_AsLong(obj);
    if (v >= 0) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      return SWIG_OverflowError;
    }
  } else if (PyLong_Check(obj)) {
    unsigned long v = PyLong_AsUnsignedLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  }
  return SWIG_TypeError;
}
}

/* long long */

%fragment(SWIG_From_frag(long long),"header",
	  fragment=SWIG_From_frag(long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE PyObject* 
SWIG_From_dec(long long)(long long value)
{
  return ((value < LONG_MIN) || (value > LONG_MAX)) ?
    PyLong_FromLongLong(value) : PyInt_FromLong(%numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(long long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(long long)(PyObject *obj, long long *val)
{
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return SWIG_OK;
  } else if (PyLong_Check(obj)) {
    long long v = PyLong_AsLongLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  } 
  return SWIG_TypeError;
}
}

/* unsigned long long */

%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment=SWIG_From_frag(long long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE PyObject* 
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLongLong(value) : PyInt_FromLong(%numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(PyObject *obj, unsigned long long *val)
{
  if (PyLong_Check(obj)) {
    unsigned long long v = PyLong_AsUnsignedLongLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  } else {
    unsigned long v;
    int res = SWIG_AsVal(unsigned long)(obj,&v);
    if (res == SWIG_OK && val) *val = v;
    return res;
  }
  return SWIG_TypeError;
}
}

/* double */

%fragment(SWIG_From_frag(double),"header") {
  %define_as(SWIG_From_dec(double),          PyFloat_FromDouble)
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(PyObject *obj, double *val)
{
  if (PyFloat_Check(obj)) {
    if (val) *val = PyFloat_AsDouble(obj);
    return SWIG_OK;
  } else if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return SWIG_OK;
  } else if (PyLong_Check(obj)) {
    double v = PyLong_AsDouble(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  }
  return SWIG_TypeError;
}
}



