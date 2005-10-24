%include <typemaps/strings.swg>
%typemaps_string(char, Char, SWIG_AsCharPtrAndSize, SWIG_FromCharPtrAndSize, strlen,
		"<limits.h>", CHAR_MIN, CHAR_MAX)
