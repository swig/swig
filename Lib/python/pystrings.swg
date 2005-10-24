/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsCharPtrAndSize","header") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(PyObject *obj, char** cptr, size_t* psize, int *alloc)
{
  static swig_type_info* pchar_info = 0;
  char* vptr = 0;
  if (!pchar_info) pchar_info = SWIG_TypeQuery("char *");
  if (SWIG_ConvertPtr(obj, (void**)&vptr, pchar_info, 0) == SWIG_OK) {
    if (cptr) *cptr = vptr;
    if (psize) *psize = vptr ? (strlen(vptr) + 1) : 0;
    if (alloc) *alloc = SWIG_OLDOBJ;
    return SWIG_OK;
  } else {
    if (PyString_Check(obj)) {
      char *cstr; int len;
      PyString_AsStringAndSize(obj, &cstr, &len);
      if (cptr)  {
	if (alloc) {
	  /* 
	     In python the user should not be able to modify the inner
	     string representation, so, by default we return a copy of
	     the buffer, as in the wstring case.

	     But, if you use the -DSWIG_PYTHON_UNSAFE_CSTR at
	     compilation time, you will get, at your own risk, the
	     inner string pointer instead, when possible.
	  */ 
#ifndef SWIG_PYTHON_UNSAFE_CSTR
	  if (*alloc != SWIG_OLDOBJ) 
#else
	  if (*alloc == SWIG_NEWOBJ) 
#endif
	    {
	      *cptr = %new_copy_array(cstr, len + 1, char);
	      *alloc = SWIG_NEWOBJ;
	    }
	  else {
	    *cptr = cstr;
	    *alloc = SWIG_OLDOBJ;
	  }
	} else {
	  *cptr = cstr;
	}
      }
      if (psize) *psize = len + 1;
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromCharPtrAndSize","header") {
SWIGINTERNINLINE PyObject *
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      return SWIG_NewPointerObj(%const_cast(carray,char *), 
				SWIG_TypeQuery("char *"), 0);
    } else {
      return PyString_FromStringAndSize(carray, %numeric_cast(size,int));
    }
  } else {
    Py_INCREF(Py_None);
    return Py_None;
  }
}
}


