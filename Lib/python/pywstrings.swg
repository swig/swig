
/* ------------------------------------------------------------
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsWCharPtrAndSize","header") %{
SWIGSTATIC(int)
SWIG_AsWCharPtrAndSize(PyObject *obj, wchar_t **cptr, size_t *psize)
{
  static swig_type_info* pwchar_info = 0;
  wchar_t * vptr = 0;
  if (!pwchar_info) pwchar_info = SWIG_TypeQuery("wchar_t *");
  if (SWIG_ConvertPtr(obj, (void**)&vptr, pwchar_info, 0) != -1) {
    if (cptr) *cptr = vptr;
    if (psize) *psize = vptr ? (wcslen(vptr) + 1) : 0;
    return SWIG_OLDOBJ;
  } else {
    int isunicode = PyUnicode_Check(obj);
    if (isunicode || PyString_Check(obj)) {
      if (cptr) {
	int size = isunicode ? PyUnicode_GetSize(obj) : PyString_Size(obj);
	wchar_t *nptr = swig_new_array(size + 1, wchar_t);
	PyUnicodeObject *uni = (PyUnicodeObject *)PyUnicode_FromObject(obj);
	PyUnicode_AsWideChar(uni, nptr, size);
	nptr[size] = 0;
	*cptr = nptr;
	if (psize) {
	  *psize = (size_t) size + 1;
	}
	Py_DECREF(uni);
      }
      return SWIG_NEWOBJ;
    }
  }
  if (cptr) {
    PyErr_SetString(PyExc_TypeError, "a wchar_t * is expected");
  }
  return 0;
}
%}

%fragment("SWIG_AsWCharPtr","header",
	  fragment="SWIG_AsWCharPtrAndSize") %{
SWIGSTATICINLINE(int)
SWIG_AsWCharPtr(PyObject *obj, wchar_t **val)
{
  wchar_t * cptr = 0;
  int res = 0;
  if ((res = SWIG_AsWCharPtrAndSize(obj, &cptr, (size_t*)(0)))) {
    if (val) *val = cptr;
    return res;
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a wchar_t * is expected");
  }
  return 0;
}
%}

%fragment("SWIG_FromWCharPtr","header") %{
SWIGSTATICINLINE(PyObject *)
SWIG_FromWCharPtr(const wchar_t * cptr)
{ 
  if (cptr) {
    size_t size = wcslen(cptr);
    if (size > INT_MAX) {
      return SWIG_NewPointerObj(swig_const_cast(cptr,wchar_t *), 
				SWIG_TypeQuery("wchar_t *"), 0);
    } else {
      return PyUnicode_FromWideChar(cptr, size);
    }
  }
  Py_INCREF(Py_None);
  return Py_None;
}
%}

%fragment("SWIG_AsNewWCharPtr","header",
	  fragment="SWIG_AsWCharPtrAndSize") %{
SWIGSTATIC(int)
SWIG_AsNewWCharPtr(PyObject *obj, wchar_t **val)
{
  wchar_t * cptr = 0; size_t csize = 0;
  int res = SWIG_AsWCharPtrAndSize(obj, &cptr, &csize);
  if (res) {
    if (val) {
      if (csize) {
	*val = swig_new_array(csize, wchar_t);
	memcpy(*val, cptr, (--csize)*sizeof(wchar_t));
	(*val)[csize] = 0;
      } else if (cptr) {
	*val = swig_new_array(1, wchar_t);
	(*val)[0] = 0;
      } else {
	*val = 0;
      }
    }
    return SWIG_NEWOBJ;
  } 
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a wchar_t * is expected");
  }
  return 0;
}
%}

%fragment("SWIG_AsWCharArray","header",
	  fragment="SWIG_AsWCharPtrAndSize") %{
SWIGSTATIC(int)
SWIG_AsWCharArray(PyObject *obj, wchar_t *val, size_t size)
{ 
  wchar_t * cptr; size_t csize;  
  if (SWIG_AsWCharPtrAndSize(obj, &cptr, &csize)) {
    if ((csize == size + 1) && !(cptr[csize-1])) --csize;
    if (csize <= size) {
      if (val) {
	if (csize) memcpy(val, cptr, csize*sizeof(wchar_t));
	if (csize < size) memset(val+csize, 0, (size-csize)*sizeof(wchar_t));
      }
      return 1;
    }
  }
  if (val) {
    PyErr_Format(PyExc_TypeError, 
		 "a wchar_t array of maximum size %ld is expected", 
		 size);
  }
  return 0;
}
%}

%fragment("SWIG_FromWCharArray","header") %{
SWIGSTATICINLINE(PyObject *)
SWIG_FromWCharArray(const wchar_t * carray, size_t size)
{
  if (size > INT_MAX) {
    SWIG_NewPointerObj(swig_const_cast(carray,wchar_t *), SWIG_TypeQuery("wchar_t *"), 0);
    return Py_None;    
  } else {
    return PyUnicode_FromWideChar(carray, swig_numeric_cast(size,int));
  }
}
%}

/* ------------------------------------------------------------
 *  The plain wchar_t * handling
 * ------------------------------------------------------------ */

%typemap_pystring(wchar_t,
		  SWIG_AsWCharPtr,
		  SWIG_AsWCharPtrAndSize,
		  SWIG_FromWCharPtr,
		  SWIG_AsNewWCharPtr,
		  SWIG_AsWCharArray,
		  SWIG_FromWCharArray);

