%ensure_fragment(SWIG_AsWCharPtrAndSize)
%ensure_fragment(SWIG_FromWCharPtrAndSize)


%types(wchar_t *);

%fragment("SWIG_pwchar_descriptor","header") {
SWIGINTERN swig_type_info*
SWIG_pwchar_descriptor()
{
  static swig_type_info *info = 0;
  if (!info) {
    info = SWIG_TypeQuery("_p_wchar_t");
  }
  return info;
}
}

%fragment("SWIG_wcsnlen","header",fragment="SWIG_FromWCharPtrAndSize") {
SWIGINTERN size_t
SWIG_wcsnlen(const wchar_t* s, size_t maxlen)
{
  const wchar_t *p;
  for (p = s; maxlen-- && *p; p++)
    ;
  return (size_t)(p - s);
}
}

%fragment("SWIG_NewCopyWCharArray","header") {
SWIGINTERNINLINE wchar_t *SWIG_NewCopyWCharArray(const wchar_t *cptr, size_t size)
{
  wchar_t *ret = NULL;
  if (size > 0 && cptr != NULL) {
    ret = %new_array(size,wchar_t);
    if (ret != NULL) {
      memcpy(ret, cptr, size * sizeof(wchar_t));
    }
  }
  return ret;
}
}

%include <typemaps/strings.swg>
%typemaps_string(%checkcode(UNISTRING), %checkcode(UNICHAR),
		 SWIGWARN_TYPEMAP_WCHARLEAK_MSG,
		 wchar_t, WChar, SWIG_AsWCharPtrAndSize, SWIG_FromWCharPtrAndSize,
		 wcslen, SWIG_wcsnlen,
		 SWIG_NewCopyWCharArray,
		"<wchar.h>", WCHAR_MIN, WCHAR_MAX)

