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
  return p - s;
}
}

%include <typemaps/strings.swg>
%typemaps_string(%checkcode(UNISTRING), %checkcode(UNICHAR),
		 SWIGWARN_TYPEMAP_WCHARLEAK_MSG,
		 wchar_t, WChar, SWIG_AsWCharPtrAndSize, SWIG_FromWCharPtrAndSize,
		 wcslen, SWIG_wcsnlen,
		"<wchar.h>", WCHAR_MIN, WCHAR_MAX)

