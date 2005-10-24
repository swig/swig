%include <typemaps/strings.swg>
%typemaps_string(wchar_t, WChar, SWIG_AsWCharPtrAndSize, SWIG_FromWCharPtrAndSize, wcslen,
		"<wchar.h>", WCHAR_MIN, WCHAR_MAX)

