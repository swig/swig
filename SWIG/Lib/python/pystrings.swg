
/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%types(char *);
%fragment("SWIG_AsCharPtrAndSize","header") {
/* returns SWIG_OLDOBJ if the input is a raw char*, SWIG_PYSTR if is a PyString */
SWIGINTERN int
SWIG_AsCharPtrAndSize(PyObject *obj, char** cptr, size_t* psize)
{
  static swig_type_info* pchar_info = 0;
  char* vptr = 0;
  if (!pchar_info) pchar_info = SWIG_TypeQuery("char *");
  if (SWIG_ConvertPtr(obj, (void**)&vptr, pchar_info, 0) != -1) {
    if (cptr) *cptr = vptr;
    if (psize) *psize = vptr ? (strlen(vptr) + 1) : 0;
    return SWIG_OLDOBJ;
  } else {
    PyErr_Clear();
    if (PyString_Check(obj)) {
      if (cptr) {
	*cptr = PyString_AS_STRING(obj);
	if (psize) {
	  *psize = PyString_GET_SIZE(obj) + 1;
	}
      }
      return SWIG_PYSTR;
    }
  }
  if (cptr) {
    SWIG_type_error("char *", obj);
  }
  return 0;
}
}

%fragment("SWIG_AsCharPtr","header",
	  fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERNINLINE int
SWIG_AsCharPtr(PyObject *obj, char **val)
{
  if (SWIG_AsCharPtrAndSize(obj, val, (size_t*)(0))) {
    return 1;
  }
  if (val) {
    PyErr_Clear();
    SWIG_type_error("char *", obj);
  }
  return 0;
}
}

%fragment("SWIG_FromCharPtr","header") {
SWIGINTERN PyObject *
SWIG_FromCharPtr(const char* cptr)
{ 
  if (cptr) {
    size_t size = strlen(cptr);
    if (size > INT_MAX) {
      return SWIG_NewPointerObj(SWIG_const_cast(cptr,char*), 
				SWIG_TypeQuery("char *"), 0);
    } else {
      if (size != 0) {
	return PyString_FromStringAndSize(cptr, size);
      } else {
	return PyString_FromString(cptr);
      }
    }
  }
  Py_INCREF(Py_None);
  return Py_None;
}
}

%fragment("SWIG_AsNewCharPtr","header",
	  fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsNewCharPtr(PyObject *obj, char **val)
{
  char* cptr = 0; size_t csize = 0;
  int res = SWIG_AsCharPtrAndSize(obj, &cptr, &csize);
  if (res) {
    if (val) {
      if (csize) {
	*val = SWIG_new_array(csize, char);
	memcpy(*val, cptr, --csize);
	(*val)[csize] = 0;
      } else if (cptr) {
	*val = SWIG_new_array(1, char);
	(*val)[0] = 0;
      } else {
	*val = 0;
      }
    }
    return SWIG_NEWOBJ;
  } 
  if (val) {
    SWIG_type_error("char *", obj);
  }
  return 0;
}
}

%fragment("SWIG_AsCharArray","header",
	  fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsCharArray(PyObject *obj, char *val, size_t size)
{ 
  char* cptr; size_t csize;  
  if (SWIG_AsCharPtrAndSize(obj, &cptr, &csize)) {
    /* in C you can do:        

         char x[5] = "hello"; 

        ie, assing the array using an extra '0' char.
    */
    if ((csize == size + 1) && !(cptr[csize-1])) --csize;
    if (csize <= size) {
      if (val) {
	if (csize) memcpy(val, cptr, csize);
	if (csize < size) memset(val + csize, 0, size - csize);
      }
      return 1;
    }
  }
  if (val) {
    PyErr_Format(PyExc_TypeError,
		 "a char array of maximum size %lu is expected", 
		 (unsigned long) size);
  }
  return 0;
}
}

%fragment("SWIG_FromCharArray","header") {
SWIGINTERNINLINE PyObject *
SWIG_FromCharArray(const char* carray, size_t size)
{
  if (size > INT_MAX) {
    return Py_None;    
  } else {
    return PyString_FromStringAndSize(carray, SWIG_numeric_cast(size,int));
  }
}
}

/* ------------------------------------------------------------
 *  The plain char * handling
 * ------------------------------------------------------------ */

%typemap_pystring(char,
		  SWIG_AsCharPtr,
		  SWIG_AsCharPtrAndSize,
		  SWIG_FromCharPtr,
		  SWIG_AsNewCharPtr,
		  SWIG_AsCharArray,
		  SWIG_FromCharArray)
