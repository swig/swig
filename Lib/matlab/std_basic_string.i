#if !defined(SWIG_STD_STRING)
#define SWIG_STD_BASIC_STRING
#define SWIG_STD_MODERN_STL

%include <matlabcontainer.swg>

#define %swig_basic_string(Type...)  %swig_sequence_methods_val(Type)


%include <typemaps/std_strings.swg>
%std_string_asptr(std::basic_string<char>, char, SWIG_AsCharPtrAndSize, "SWIG_AsCharPtrAndSize")

%fragment(SWIG_From_frag(std::basic_string<char>),"header",
	  fragment="SWIG_FromCharPtrAndSize") {
SWIGINTERNINLINE mxArray*
  SWIG_From(std::basic_string<char>)(const std::string& s)
  {
    return SWIG_FromCharPtrAndSize(s.data(), s.size());
  }
}

%ignore std::basic_string::operator +=;

%include <std/std_basic_string.i>
%typemaps_asptrfromn(%checkcode(STRING), std::basic_string<char>);

#endif
