/* ------------------------------------------------------------
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsWCharPtrAndSize","header",fragment="<wchar.h>") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(PyObject *obj, wchar_t **cptr, size_t *psize, int *alloc)
{
  static swig_type_info* pwchar_info = 0;
  wchar_t * vptr = 0;
  if (!pwchar_info) pwchar_info = SWIG_TypeQuery("wchar_t *");
  if (SWIG_ConvertPtr(obj, (void**)&vptr, pwchar_info, 0) == SWIG_OK) {
    if (cptr) *cptr = vptr;
    if (psize) *psize = vptr ? (wcslen(vptr) + 1) : 0;
    return SWIG_OK;
  } else {
    PyObject *tmp = 0;
    int isunicode = PyUnicode_Check(obj);
    if (!isunicode && PyString_Check(obj)) {
      if (cptr) {
	obj = tmp = PyUnicode_FromObject(obj);
      }
      isunicode = 1;
    }
    if (isunicode) {
      int len = PyUnicode_GetSize(obj);
      if (cptr) {
	*cptr = SWIG_new_array(len + 1, wchar_t);
	PyUnicode_AsWideChar((PyUnicodeObject *)obj, *cptr, len);
	(*cptr)[len] = 0;
      }
      if (psize) *psize = (size_t) len + 1;
      if (alloc) *alloc = cptr ? SWIG_NEWOBJ : 0;
      if (tmp) Py_DECREF(tmp);
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromWCharPtrAndSize","header",fragment="<wchar.h>") {
SWIGINTERNINLINE PyObject *
SWIG_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      return SWIG_NewPointerObj(SWIG_const_cast(carray,wchar_t *), 
				SWIG_TypeQuery("wchar_t *"), 0);
    } else {
      return PyUnicode_FromWideChar(carray, SWIG_numeric_cast(size,int));
    }
  } else {
    Py_INCREF(Py_None);
    return Py_None;
  }
}
}

/* ------------------------------------------------------------
 *  The plain wchar_t * handling
 * ------------------------------------------------------------ */

%include <typemaps/strings.swg>
%typemap_string(wchar_t, WChar, SWIG_AsWCharPtrAndSize, SWIG_FromWCharPtrAndSize, wcslen);

