%include <typemaps/cstring.swg>
%include <pystrings.swg>

%typemap_cstrings(%cstring,
		  char,
		  SWIG_AsCharPtr,
		  SWIG_AsCharPtrAndSize,
		  SWIG_FromCharPtr,
		  SWIG_FromCharPtrAndSize);

