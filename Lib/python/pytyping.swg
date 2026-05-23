%typemap(pytyping) SWIGTYPE "typing.Any"

%typemap(pytyping) bool "bool"

%typemap(pytyping) signed char, unsigned char, short, unsigned short, int, unsigned int, long, unsigned long, long long, unsigned long long "int"
%typemap(pytyping) size_t "int"

%typemap(pytyping) float, double, long double "float"

%typemap(pytyping) char, wchar_t, char *, wchar_t * "str"

%typemap(pytyping) void "None"
