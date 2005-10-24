
/* defining the String asptr/from methods */

%define %std_string_asptr(String, Char, SWIG_AsCharPtrAndSize, Frag)
%fragment(SWIG_AsPtr_frag(String),"header",fragment=Frag) {
SWIGINTERN int
SWIG_AsPtr_dec(String)(SWIG_Object obj, String **val) 
{
  static swig_type_info* string_info = SWIG_TypeQuery(#String " *");
  String *vptr;    
  if (SWIG_ConvertPtr(obj, (void**)&vptr, string_info, 0) != -1) {
    if (val) *val = vptr;
    return SWIG_OLDOBJ;
  } else {
    Char* buf = 0 ; size_t size = 0; int alloc = SWIG_OLDOBJ;
    if (SWIG_AsCharPtrAndSize(obj, &buf, &size, &alloc) == SWIG_OK) {
      if (buf) {
	if (val) *val = new String(buf, size - 1);
	if (alloc == SWIG_NEWOBJ) %delete_array(buf);
	return SWIG_NEWOBJ;
      }
    }
    return 0;
  }
}
}
%enddef

%define %std_string_from(String, SWIG_FromCharPtrAndSize, Frag)
%fragment(SWIG_From_frag(String),"header",fragment=Frag) {
SWIGINTERNINLINE SWIG_Object
SWIG_From_dec(String)(const String& s)
{
  return SWIG_FromCharPtrAndSize(s.data(), s.size());
}
}
%enddef

%define %std_string_asval(String)
%fragment(SWIG_AsVal_frag(String),"header", fragment=SWIG_AsPtr_frag(String)) {
SWIGINTERN int
SWIG_AsVal_dec(String)(SWIG_Object obj, String *val)
{
  String* s;
  int res = SWIG_AsPtr(String)(obj, &s);
  if ((res != 0) && s) {
    if (val) *val = *s;
    if (res == SWIG_NEWOBJ) delete s;
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}
%enddef


%define %typemaps_std_string(String, Char, AsPtrMethod, FromMethod, CheckCode)

%std_string_asptr(String, Char, AsPtrMethod, #AsPtrMethod)
%std_string_asval(String)
%std_string_from(String, FromMethod, #FromMethod)

%typemaps_asptrfromn(%arg(CheckCode), String);

%enddef
