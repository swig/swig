/*
  Value typemaps (Type, const Type&) for "Ptr" types, such as swig
  wrapped classes, that define the AsPtr/From methods
*/

/* in */

%define PYPTR_IN_TYPEMAP(pyobj_asptr,pyfrag,...)
  %typemap(in,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr = (__VA_ARGS__ *)0;
    int res = pyobj_asptr($input, &ptr);
    if (!res || !ptr) SWIG_fail;
    $1 = *ptr;
    if (res == SWIG_NEWPTR) delete ptr;
  }
  %typemap(in,fragment=pyfrag) const __VA_ARGS__ & (int res = 0) 
    "if (!(res = pyobj_asptr($input, &$1)) || !($1)) SWIG_fail;";

  %typemap(freearg) const __VA_ARGS__ & 
    "if (res$argnum > 1) delete $1;";
%enddef

/* varin */

%define PYPTR_VARIN_TYPEMAP(pyobj_asptr,pyfrag,...)
  %typemap(varin,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr = (__VA_ARGS__ *)0;
    int res = pyobj_asptr($input, &ptr);
    if (!res || !ptr) {
      PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
      return 1;
    }
    $1 = *ptr;
    if (res == SWIG_NEWPTR) delete ptr;
  }
%enddef

/* directorout */

%define PYPTR_DIRECTOROUT_TYPEMAP(pyobj_asptr,pyfrag,...)
  %typemap(directorargout,fragment=pyfrag) __VA_ARGS__ *DIRECTOROUT ($*1_ltype temp) {
  __VA_ARGS__ *ptr = 0;
    int res = pyobj_asptr($input, &ptr);
    if (!res || !ptr) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using pyobj_asptr");
    temp = *ptr;
    $result = &temp;
    if (res == SWIG_NEWPTR) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr = 0;
    int res = pyobj_asptr($input, &ptr);
    if (!res || !ptr) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using pyobj_asptr");
    $result = *ptr;
    if (res == SWIG_NEWPTR) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) const __VA_ARGS__& ($*1_ltype temp) {
    __VA_ARGS__ *ptr = 0;
    int res = pyobj_asptr($input, &ptr);
    if (!res || !ptr) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using pyobj_asptr");
    temp = *ptr;
    $result = &temp;
    if (res == SWIG_NEWPTR) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) __VA_ARGS__ &DIRECTOROUT = __VA_ARGS__
%enddef

/* typecheck */

%define PYPTR_TYPECHECK_TYPEMAP(check,pyobj_asptr,pyfrag,...)
%typemap(typecheck,precedence=check,fragment=pyfrag) 
   __VA_ARGS__, const __VA_ARGS__&
   "$1 = pyobj_asptr($input, (__VA_ARGS__**)(0));";
%enddef

/*
  typemap definition for types with AsPtr/From methods
 */

%define %typemap_asptrfrom(CheckCode, AsPtrMeth, FromMeth, AsPtrFrag, FromFrag, ...)
  PYPTR_IN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYPTR_VARIN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYPTR_DIRECTOROUT_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYPTR_TYPECHECK_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsPtrMeth), 
			  SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYVAL_DIRECTORIN_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYVAL_OUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYVAL_VAROUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYVAL_CONSTCODE_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYVAL_THROWS_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag),__VA_ARGS__);
%enddef

/*
  typemap for simple swig types with only AsPtr/From methods
*/

%define %typemap_asptrfromn(CheckCode, ...)
%fragment(SWIG_AsVal_frag(__VA_ARGS__),"header",
	  fragment=SWIG_AsPtr_frag(__VA_ARGS__)) %{
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(__VA_ARGS__)(PyObject* obj, __VA_ARGS__ *val)
{
  __VA_ARGS__ *v = (__VA_ARGS__ *)0;
  int res = SWIG_AsPtr_meth(__VA_ARGS__)(obj, &v);
  if (!res || !v) return 0;  
  if (val) {
    *val = *v;
    if (res == SWIG_NEWPTR) delete v;
  }
  return 1;
}
%}
%typemap_asptrfrom(SWIG_arg(CheckCode),
		   SWIG_arg(SWIG_AsPtr_meth(__VA_ARGS__)), 
		   SWIG_arg(SWIG_From_meth(__VA_ARGS__)), 
		   SWIG_arg(SWIG_AsPtr_frag(__VA_ARGS__)), 
		   SWIG_arg(SWIG_From_frag(__VA_ARGS__)), 
		   __VA_ARGS__);
%enddef
