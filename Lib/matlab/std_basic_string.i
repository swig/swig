#if !defined(SWIG_STD_STRING) 
#define SWIG_STD_BASIC_STRING
#define SWIG_STD_MODERN_STL

%include <matlabcontainer.swg>

#define %swig_basic_string(Type...)  %swig_sequence_methods_val(Type)


%fragment(SWIG_AsPtr_frag(std::basic_string<char>),"header",
	  fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsPtr(std::basic_string<char>)(mxArray* obj, std::string **val)
{
  if (mxIsChar(obj) {
    if (val)
      {
	char * str = mxArrayToString(obj);
	*val = new std::string(str);
	mxFree(str);
      }
    return SWIG_NEWOBJ;
  }
  if (val)
    SWIG_Error(SWIG_RuntimeError,"a string is expected");
  return 0;
}
}

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


#if !defined(SWIG_STD_WSTRING)
// TODO Python has lots of stuff here
#endif
