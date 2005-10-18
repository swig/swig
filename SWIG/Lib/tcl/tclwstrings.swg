/* ------------------------------------------------------------
 *  utility methods for wchar strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsCharPtrAndSize","header") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(Tcl_Obj *obj, wchar_t** cptr, size_t* psize, int *alloc)
{ 
  int len = 0;
  wchar_t *cstr = Tcl_GetUnicodeFromObj(obj, &len);
  if (cstr) {
    if (cptr)  *cptr = cstr;
    if (psize) *psize = len + 1;
    if (alloc) *alloc = SWIG_OLDOBJ;
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromWCharPtrAndSize","header",
	  fragment="<limits.h>") {
SWIGINTERNINLINE Tcl_Obj *
SWIG_FromWCharPtrAndSize(const wchar_t* carray, size_t size)
{
  return (size < INT_MAX) ? Tcl_NewUnicodeObj(carray, SWIG_numeric_cast(size,int)) : NULL;
}
}


/* ------------------------------------------------------------
 *  The plain char * handling
 * ------------------------------------------------------------ */

%include <typemaps/strings.swg>
%typemap_string(wchar_t, WChar, SWIG_AsWCharPtrAndSize, SWIG_FromWCharPtrAndSize, wcslen)
