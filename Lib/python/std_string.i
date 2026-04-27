%include <typemaps/std_string.swg>

#ifdef SWIG_STD_STRING
%typemap(pytyping) std::string, std::string const & "str"
#else
%typemap(pytyping) std::string, std::string const & "typing.Union[str, typing.Any]"
#endif
