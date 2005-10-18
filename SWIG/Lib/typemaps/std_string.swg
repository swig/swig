//
// String
//





/* defining the String asptr/from methods */

%define %std_string_asptr_frag(String, Char, SWIG_AsCharPtrAndSize, Frag)
%check_swig_object()
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
	if (alloc == SWIG_NEWOBJ) SWIG_delete_array(buf);
	return SWIG_NEWOBJ;
      }
    }
    return 0;
  }
}
}
%enddef

%define %std_string_from_frag(String, SWIG_FromCharPtrAndSize, Frag)
%check_swig_object()
%fragment(SWIG_From_frag(String),"header",fragment=Frag) {
SWIGINTERNINLINE SWIG_Object
SWIG_From_dec(String)(const String& s)
{
  return SWIG_FromCharPtrAndSize(s.data(), s.size());
}
}
%enddef

%define %std_string_asval_frag(String, Frag)
%check_swig_object()
%fragment(SWIG_AsVal_frag(String),"header", fragment=Frag) {
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


#define %std_string_asptr(String, Char, Method) %std_string_asptr_frag(String, Char, Method, #Method)
#define %std_string_asval(String) %std_string_asval_frag(String, SWIG_AsPtr_frag(String))
#define %std_string_from(String, Method)  %std_string_from_frag(String, Method, #Method)
