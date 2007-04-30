/* ------------------------------------------------------------
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(VALUE obj, wchar_t **cptr, size_t *psize, int *alloc)
{
  VALUE tmp = 0;
  bool ok = false;
  if ( TYPE(obj) == T_STRING ) {
    if (cptr) {
//       obj = tmp = PyUnicode_FromObject(obj);
      rb_notimplement();
      ok = true;
    }
  }
  if (ok) {
//     int len = PyUnicode_GetSize(obj);
    rb_notimplement();
    if (cptr) {
      *cptr = %new_array(len + 1, wchar_t);
//       PyUnicode_AsWideChar((PyUnicodeObject *)obj, *cptr, len);
      rb_notimplement();
      (*cptr)[len] = 0;
    }
    if (psize) *psize = (size_t) len + 1;
    if (alloc) *alloc = cptr ? SWIG_NEWOBJ : 0;
    return SWIG_OK;
  } else {
    swig_type_info* pwchar_descriptor = SWIG_pwchar_descriptor();
    if (pwchar_descriptor) {
      void * vptr = 0;
      if (SWIG_ConvertPtr(obj, &vptr, pwchar_descriptor, 0) == SWIG_OK) {
	if (cptr) *cptr = (wchar_t *)vptr;
	if (psize) *psize = vptr ? (wcslen((wchar_t *)vptr) + 1) : 0;
	return SWIG_OK;
      }
    }
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromWCharPtrAndSize","header",fragment="<wchar.h>",fragment="SWIG_pwchar_descriptor") {
SWIGINTERNINLINE VALUE 
SWIG_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      swig_type_info* pwchar_descriptor = SWIG_pwchar_descriptor();
      return pwchar_descriptor ? 
	SWIG_NewPointerObj(%const_cast(carray,wchar_t *), pwchar_descriptor, 0) : Qnil;
    } else {
      rb_notimplement();
      // return PyUnicode_FromWideChar(carray, %numeric_cast(size,int));
    }
  } else {
    return Qnil;
  }
}
}


