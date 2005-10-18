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
	  if (*alloc == SWIG_NEWOBJ) {
	    *cptr = SWIG_new_copy_array(cstr, len + 1, char);
	  } else {
	    *cptr = cstr;
	    *alloc = SWIG_OLDOBJ;
	  }
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
      return SWIG_NewPointerObj(SWIG_const_cast(carray,char *), 
				SWIG_TypeQuery("char *"), 0);
    } else {
      return PyString_FromStringAndSize(carray, SWIG_numeric_cast(size,int));
    }
  } else {
    Py_INCREF(Py_None);
    return Py_None;
  }
}
}

/* ------------------------------------------------------------
 *  The plain char * handling
 * ------------------------------------------------------------ */

%include <typemaps/strings.swg>
%typemap_string(char, Char, SWIG_AsCharPtrAndSize, SWIG_FromCharPtrAndSize, strlen)
