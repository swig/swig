/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */
%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
/* Return string from Python obj. NOTE: obj must remain in scope in order
   to use the returned cptr (but only when alloc is set to SWIG_OLDOBJ) */
SWIGINTERN int
SWIG_AsCharPtrAndSize(PyObject *obj, char **cptr, size_t *psize, int *alloc)
{
  int use_binary = 0;       /* extract the value as raw bytes rather than as UTF-8 text */
  int is_binary = 0;        /* SWIG_BINARYSTR was passed: report the exact byte count */
  if (alloc != NULL) {
    is_binary = SWIG_IsBinaryStr(*alloc);
    use_binary = is_binary;
    *alloc = 0;
  }
%#if PY_VERSION_HEX >= 0x03000000
%#if defined(SWIG_PYTHON_STRICT_BYTE_CHAR)
  use_binary = 1;
%#endif
  if (use_binary ? PyBytes_Check(obj) : PyUnicode_Check(obj))
%#else
  if (PyString_Check(obj))
%#endif
  {
    char *cstr = NULL;
    Py_ssize_t len = 0;
    PyObject *bytes = NULL;
    int ret = SWIG_OK;
    if (alloc)
      *alloc = SWIG_OLDOBJ;
    if (use_binary) {
      if (PyBytes_AsStringAndSize(obj, &cstr, &len) == -1)
        return SWIG_TypeError;
    } else {
      cstr = (char *)SWIG_PyUnicode_AsUTF8AndSize(obj, &len, &bytes);
      if (!cstr)
        return SWIG_TypeError;
      /* The returned string is only duplicated if the char * returned is not owned and memory managed by obj */
      if (bytes && cptr) {
        if (alloc) {
          size_t alen = (size_t)(len + 1);
          char *p = %new_array(alen, char);
          if (p == NULL) {
            SWIG_Py_XDECREF(bytes);
            return SWIG_MemoryError;
          }
          memcpy(p, cstr, alen);
          cstr = p;
          *alloc = SWIG_NEWOBJ;
        } else {
          /* alloc must be set in order to clean up allocated memory */
          SWIG_Py_XDECREF(bytes);
          return SWIG_RuntimeError;
        }
      }
    }
    if (cptr) *cptr = cstr;
    if (psize) *psize = is_binary ? (size_t)len : (size_t)(len + 1);
    SWIG_Py_XDECREF(bytes);
    return ret;
  } else {
%#if defined(SWIG_PYTHON_2_UNICODE)
%#if defined(SWIG_PYTHON_STRICT_BYTE_CHAR)
%#error "Cannot use both SWIG_PYTHON_2_UNICODE and SWIG_PYTHON_STRICT_BYTE_CHAR at once"
%#endif
%#if PY_VERSION_HEX < 0x03000000
    if (PyUnicode_Check(obj)) {
      char *cstr = NULL;
      Py_ssize_t len = 0;
      if (!alloc && cptr) {
        return SWIG_RuntimeError;
      }
      obj = PyUnicode_AsUTF8String(obj);
      if (!obj)
        return SWIG_TypeError;
      if (PyString_AsStringAndSize(obj, &cstr, &len) != -1) {
        if (cptr) {
          char *p = %new_array(len + 1, char);
          if (p == NULL) {
            SWIG_Py_XDECREF(obj);
            return SWIG_MemoryError;
          }
          if (alloc) *alloc = SWIG_NEWOBJ;
          memcpy(p, cstr, len + 1);
          *cptr = p;
        }
        if (psize) *psize = (size_t)(len + 1);

        SWIG_Py_XDECREF(obj);
        return SWIG_OK;
      } else {
        SWIG_Py_XDECREF(obj);
      }
    }
%#endif
%#endif

    swig_type_info* pchar_descriptor = SWIG_pchar_descriptor();
    if (pchar_descriptor) {
      void* vptr = 0;
      if (SWIG_ConvertPtr(obj, &vptr, pchar_descriptor, 0) == SWIG_OK) {
	if (cptr) *cptr = (char *) vptr;
	if (psize) *psize = vptr ? (strlen((char *)vptr) + 1) : 0;
	if (alloc) *alloc = SWIG_OLDOBJ;
	return SWIG_OK;
      }
    }
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
#define SWIG_FromCharPtrAndSize(carray, size) SWIG_FromBinaryCharPtrAndSize(carray, size, 0)
SWIGINTERNINLINE PyObject *
SWIG_FromBinaryCharPtrAndSize(const char* carray, size_t size, int flags)
{
  if (carray) {
    if (size > (size_t)PY_SSIZE_T_MAX) {
      swig_type_info* pchar_descriptor = SWIG_pchar_descriptor();
      return pchar_descriptor ? 
	SWIG_InternalNewPointerObj(%const_cast(carray,char *), pchar_descriptor, 0) : SWIG_Py_Void();
    } else {
%#if PY_VERSION_HEX >= 0x03000000
%#if defined(SWIG_PYTHON_STRICT_BYTE_CHAR)
      return PyBytes_FromStringAndSize(carray, %numeric_cast(size, Py_ssize_t));
%#else
      if (SWIG_IsBinaryStr(flags))
        return PyBytes_FromStringAndSize(carray, %numeric_cast(size, Py_ssize_t));
      return PyUnicode_DecodeUTF8(carray, %numeric_cast(size, Py_ssize_t), "surrogateescape");
%#endif
%#else
      return PyString_FromStringAndSize(carray, %numeric_cast(size, Py_ssize_t));
%#endif
    }
  } else {
    return SWIG_Py_Void();
  }
}
}

