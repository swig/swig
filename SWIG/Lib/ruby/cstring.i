%include <typemaps/cstring.swg>
%include <rubystrings.swg>

%typemap_cstrings(%cstring,
		  char,
		  SWIG_AsCharPtr,
		  SWIG_AsCharPtrAndSize,
		  SWIG_FromCharPtr,
		  SWIG_FromCharPtrAndSize);

