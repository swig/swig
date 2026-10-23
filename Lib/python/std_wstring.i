%include <pywstrings.swg>
%include <typemaps/std_wstring.swg>

#ifdef SWIG_STD_WSTRING
%typemap(pytyping) std::wstring, std::wstring const & "str"
#else
%typemap(pytyping) std::wstring, std::wstring const & "typing.Union[str, typing.Any]"
#endif
