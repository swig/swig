/*
  Value typemaps (Type, const Type&) for "Ptr" types, such as swig
  wrapped classes, that define the AsPtr/From methods
*/

/* in */

%define PYPTR_IN_TYPEMAP(pyobj_asptr,pyfrag,...)
  %typemap(in,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr;
    int res = pyobj_asptr($input, &ptr);
    if (!res) SWIG_fail;
    $1 = *ptr;
    if (res > 1) delete ptr;
  }
  %typemap(in,fragment=pyfrag) const __VA_ARGS__ & (int res = 0) 
    "if (!(res = pyobj_asptr($input, &$1))) SWIG_fail;";

  %typemap(freearg) const __VA_ARGS__ & 
    "if (res$argnum > 1) delete $1;";
%enddef

/* out */

%define PYPTR_OUT_TYPEMAP(pyobj_from,pyfrag,...)
  %typemap(out,fragment=pyfrag) __VA_ARGS__ 
  "$result = pyobj_from($1);";
  %typemap(out,fragment=pyfrag) const __VA_ARGS__& 
  "$result = pyobj_from(*($1));";
%enddef

/* varin */

%define PYPTR_VARIN_TYPEMAP(pyobj_asptr,pyfrag,...)
  %typemap(varin,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr;
    int res = pyobj_asptr($input, &ptr);
    if (!res) {
      PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
      return 1;
    }
    if (!res) SWIG_fail;
    $1 = *ptr;
    if (res > 1) delete ptr;
  }
%enddef

/* varout */

%define PYPTR_VAROUT_TYPEMAP(pyobj_from,pyfrag,...)
  %typemap(varout,fragment=pyfrag) __VA_ARGS__, const __VA_ARGS__&  
   "$result = pyobj_from($1);";
%enddef

/* Primitive types */
%define PYPTR_CONSTCODE_TYPEMAP(pyobj_from,pyfrag,...)
  %typemap(constcode,fragment=pyfrag) __VA_ARGS__ 
     "PyDict_SetItemString(d,\"$symname\", pyobj_from($value));";
%enddef


/* directorin */

%define PYPTR_DIRECTORIN_TYPEMAP(pyobj_from,pyfrag,...)
  %typemap(directorin,fragment=pyfrag) __VA_ARGS__
  "$input = pyobj_from($1_name);";
%enddef

/* directorout */

%define PYPTR_DIRECTOROUT_TYPEMAP(pyobj_asptr,pyfrag,...)
  %typemap(directorargout,fragment=pyfrag) __VA_ARGS__ *DIRECTOROUT ($*1_ltype temp) {
    __VA_ARGS__ *ptr;
    int res = pyobj_asptr($input, &ptr);
    if (!res) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using pyobj_asptr");
    temp = *ptr;
    $result = &temp;
    if (res > 1) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) __VA_ARGS__ {
    __VA_ARGS__ *ptr;
    int res = pyobj_asptr($input, &ptr);
    if (!res) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using pyobj_asptr");
    $result = *ptr;
    if (res > 1) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) const __VA_ARGS__& ($*1_ltype temp) {
    __VA_ARGS__ *ptr;
    int res = pyobj_asptr($input, &ptr);
    if (!res) 
      throw Swig::DirectorTypeMismatchException("Error converting Python object using pyobj_asptr");
    temp = *ptr;
    $result = &temp;
    if (res > 1) delete ptr;
  }
  %typemap(directorout,fragment=pyfrag) __VA_ARGS__ &DIRECTOROUT = __VA_ARGS__
%enddef

/* throws */

%define PYPTR_THROWS_TYPEMAP(pyobj_from,pyfrag,...)
  %typemap(throws,fragment=pyfrag) __VA_ARGS__ {
  PyErr_SetObject(PyExc_RuntimeError, pyobj_from($1));
    SWIG_fail;
  }
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
  PYPTR_OUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYPTR_VARIN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYPTR_VAROUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYPTR_CONSTCODE_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYPTR_DIRECTORIN_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYPTR_DIRECTOROUT_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), __VA_ARGS__);
  PYPTR_THROWS_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag),__VA_ARGS__);
  PYPTR_TYPECHECK_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsPtrMeth), 
		       SWIG_arg(AsPtrFrag), __VA_ARGS__);
%enddef

/*
  typemap for simple swig types with only AsPtr/From conversor methods
*/

%define %typemap_asptrfromn(CheckCode, ...)
%typemap_asptrfrom(SWIG_arg(CheckCode),
		   SWIG_AsPtr_meth(__VA_ARGS__), 
		   SWIG_From_meth(__VA_ARGS__), 
		   SWIG_arg(SWIG_AsPtr_frag(__VA_ARGS__)), 
		   SWIG_arg(SWIG_From_frag(__VA_ARGS__)), 
		   __VA_ARGS__);
%enddef
