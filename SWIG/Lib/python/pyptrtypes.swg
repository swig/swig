/*
  Value typemaps (Type, const Type&) for "Ptr" types, such as swig
  wrapped classes, that define the AsPtr/From methods
*/

/* in */

%define PYPTR_IN_TYPEMAP(asptr_meth,pyfrag,...)
  %typemap(in,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr = (__VA_ARGS__ *)0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) SWIG_fail;
    $1 = *ptr;
    if (res == SWIG_NEWOBJ) delete ptr;
  }
  %typemap(in,fragment=pyfrag) const __VA_ARGS__ & (int res = 0)
    "if (!(res = asptr_meth($input, &$1)) || !($1)) SWIG_fail;";

  %typemap(freearg) const __VA_ARGS__ & 
    "if (res$argnum == SWIG_NEWOBJ) delete $1;";
%enddef

/* varin */

%define PYPTR_VARIN_TYPEMAP(asptr_meth,pyfrag,...)
  %typemap(varin,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr = (__VA_ARGS__ *)0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) {
      PyErr_SetString(PyExc_TypeError, "C/C++ variable '$name ($1_ltype)'");
      return 1;
    }
    $1 = *ptr;
    if (res == SWIG_NEWOBJ) delete ptr;
  }
%enddef

/* directorout */

%define PYPTR_DIRECTOROUT_TYPEMAP(asptr_meth,pyfrag,...)
  %typemap(directorargout,fragment=pyfrag) __VA_ARGS__ *DIRECTOROUT ($*1_ltype temp) {
  __VA_ARGS__ *ptr = 0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using asptr_meth");
    temp = *ptr;
    $result = &temp;
    if (res == SWIG_NEWOBJ) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr = 0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using asptr_meth");
    $result = *ptr;
    if (res == SWIG_NEWOBJ) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) const __VA_ARGS__& ($*1_ltype temp) {
    __VA_ARGS__ *ptr = 0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using asptr_meth");
    temp = *ptr;
    $result = &temp;
    if (res == SWIG_NEWOBJ) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) __VA_ARGS__ &DIRECTOROUT = __VA_ARGS__
%enddef

/* typecheck */

%define PYPTR_TYPECHECK_TYPEMAP(check,asptr_meth,pyfrag,...)
%typemap(typecheck,precedence=check,fragment=pyfrag) 
   __VA_ARGS__, const __VA_ARGS__&
   "$1 = asptr_meth($input, (__VA_ARGS__**)(0));";
%enddef

/*
  typemap definition for types with AsPtr/From methods
 */

%define %typemap_asptrfrom(CheckCode, AsPtrMeth, FromMeth, AsPtrFrag, FromFrag, ...)
  %fragment(SWIG_AsVal_frag(__VA_ARGS__),"header",
	    fragment=SWIG_AsPtr_frag(__VA_ARGS__)) %{
  SWIGSTATICINLINE(int)
    SWIG_AsVal(__VA_ARGS__)(PyObject* obj, __VA_ARGS__ *val)
    {
      __VA_ARGS__ *v = (__VA_ARGS__ *)0;
      int res = SWIG_AsPtr(__VA_ARGS__)(obj, &v);
      if (!res || !v) return 0;  
      if (val) {
	*val = *v;
	if (res == SWIG_NEWOBJ) delete v;
      }
      return 1;
    }
  %}
  %fragment(SWIG_As_frag(__VA_ARGS__),"header",
	    fragment=SWIG_AsVal_frag(__VA_ARGS__)) %{
  SWIGSTATICINLINE(__VA_ARGS__)
    SWIG_As(__VA_ARGS__)(PyObject* obj)
    {
      __VA_ARGS__ v;
      SWIG_AsVal(__VA_ARGS__)(obj, &v);
      return v;
    }
  %}
  PYPTR_IN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYPTR_VARIN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYPTR_DIRECTOROUT_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYPTR_TYPECHECK_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsPtrMeth), 
			  SWIG_arg(AsPtrFrag), __VA_ARGS__);
  %typemap_from(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);

  PYPTR_INPUT_TYPEMAP(SWIG_arg(CheckCode),SWIG_arg(AsPtrMeth),
		      SWIG_arg(AsPtrFrag),__VA_ARGS__);
  PYPTR_INOUT_TYPEMAP(__VA_ARGS__);
%enddef

/*
  typemap for simple swig types with only AsPtr/From methods
*/

%define %typemap_asptrfromn(CheckCode, ...)
%typemap_asptrfrom(SWIG_arg(CheckCode),
		   SWIG_arg(SWIG_AsPtr(__VA_ARGS__)), 
		   SWIG_arg(SWIG_From(__VA_ARGS__)), 
		   SWIG_arg(SWIG_AsPtr_frag(__VA_ARGS__)), 
		   SWIG_arg(SWIG_From_frag(__VA_ARGS__)), 
		   __VA_ARGS__);
%enddef
