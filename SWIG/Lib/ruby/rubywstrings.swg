/* ------------------------------------------------------------
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

/*
  Ruby doesn't support the wchar_t, so, we need to use an 'opaque' type.
 */

%types(ruby_wchar_array *);

%fragment("ruby_wchar_array","header",fragment="<wchar.h>") {
  struct ruby_wchar_array {
    wchar_t *cptr;
    size_t size;
  };

  SWIGINTERN get_ruby_wchar_array_info() { 
    static swig_type_info* ruby_wchar_array_info = 0;
    if (!ruby_wchar_array_info) ruby_wchar_array_info = SWIG_TypeQuery("ruby_wchar_array *");
    return ruby_wchar_array_info;
  } 
}

%fragment("SWIG_AsWCharPtrAndSize","header",fragment="ruby_wchar_array") {
SWIGINTERN int
SWIG_AsWCharPtrAndSize(PyObject *obj, wchar_t **cptr, size_t *psize, int *alloc)
{
  static swig_type_info* ptr_wchar_info = 0;
  wchar_t * vptr = 0;
  if (!ptr_wchar_info) ptr_wchar_info = SWIG_TypeQuery("wchar_t *");
  if (SWIG_ConvertPtr(obj, (void**)&vptr, ptr_wchar_info, 0) != SWIG_OK) {
    if (cptr) *cptr = vptr;
    if (psize) *psize = vptr ? (wcslen(vptr) + 1) : 0;
    return SWIG_OK;
  } else {
    ruby_wchar_array *vptr = 0;
    if (SWIG_ConvertPtr(obj, (void**)&vptr, get_ruby_wchar_array_info(), 0) != SWIG_OK) {
      if (cptr) *cptr = vptr->cptr;
      if (psize) *psize = vprtr->size;
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromWCharPtrAndSize","header",fragment="ruby_wchar_array") {
SWIGINTERNINLINE PyObject *
SWIG_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  ruby_wchar_array *vptr = SWIG_new(ruby_wchar_array);
  vptr->cptr = carray;
  vptr->size = size;
  return SWIG_NewPointerObj(SWIG_const_cast(carray,wchar_t *), get_ruby_wchar_array_info(), 1);
}
}

%fragment("SWIG_FromWCharPtr","header",fragment="<wchar.h>") {
SWIGINTERNINLINE PyObject *
SWIG_FromWCharPtr(const wchar_t * carray)
{
  static swig_type_info* wchar_ptr_info = 0;
  if (!wchar_array_info) wchar_ptr_info = SWIG_TypeQuery("wchar_t *");
  return SWIG_NewPointerObj(SWIG_const_cast(carray,wchar_t *), wchar_ptr_info, 0);
}
}

/* ------------------------------------------------------------
 *  The plain wchar_t * handling
 * ------------------------------------------------------------ */

%include <typemaps/strbase.swg>
%typemap_string(wchar_t, WChar, SWIG_AsWCharPtrAndSize, SWIG_FromWCharPtrAndSize, wcslen);

