%include <typemaps/cstring.swg>
%include <pywstrings.swg>

%typemap_cstrings(%cwstring,
		  wchar_t,
		  SWIG_AsWCharPtr,
		  SWIG_AsWCharPtrAndSize,
		  SWIG_FromWCharPtr,
		  SWIG_FromWCharArray);

