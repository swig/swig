/*
  Value typemaps (Type, const Type&) for value types, such as
  fundamental types (int, double), that define the As/AsVal/From
  methods.
*/

/* in */

%define PYVAL_IN_TYPEMAP(as_meth,pyfrag,...)
  %typemap(in,fragment=pyfrag) __VA_ARGS__
    "$1 = ($ltype)as_meth($input); 
     if (SWIG_arg_fail($argnum)) SWIG_fail;";
  %typemap(in,fragment=pyfrag) const __VA_ARGS__ & ($basetype temp)
    "temp = ($basetype) as_meth($input);
     if (SWIG_arg_fail($argnum)) SWIG_fail;
     $1 = &temp;";
%enddef

/* out */

%define PYVAL_OUT_TYPEMAP(from_meth,pyfrag,...)
  %typemap(out,fragment=pyfrag) __VA_ARGS__ 
  "$result = from_meth((__VA_ARGS__)$1);";
  %typemap(out,fragment=pyfrag) const __VA_ARGS__& 
  "$result = from_meth((__VA_ARGS__)*($1));";
%enddef

/* varin */

%define PYVAL_VARIN_TYPEMAP(as_meth,pyfrag,...)
  %typemap(varin,fragment=pyfrag) __VA_ARGS__ {
    $1_type temp = ($1_type) as_meth($input);  
    if (PyErr_Occurred()) {
      SWIG_append_errmsg("C/C++ variable '$name ($1_ltype)'");
      return 1;
    }
    $1 = temp;
  }
%enddef

/* varout */

%define PYVAL_VAROUT_TYPEMAP(from_meth,pyfrag,...)
  %typemap(varout,fragment=pyfrag) __VA_ARGS__, const __VA_ARGS__&  
   "$result = from_meth((__VA_ARGS__)$1);";
%enddef

/* constant installation code */
%define PYVAL_CONSTCODE_TYPEMAP(from_meth,pyfrag,...)
  %typemap(constcode,fragment=pyfrag) __VA_ARGS__ 
     "PyDict_SetItemString(d,\"$symname\", from_meth((__VA_ARGS__)$value));";
%enddef


/* directorin */

%define PYVAL_DIRECTORIN_TYPEMAP(from_meth,pyfrag,...)
  %typemap(directorin,fragment=pyfrag) __VA_ARGS__ *DIRECTORIN 
  "$input = from_meth((__VA_ARGS__)*$1_name);";
  %typemap(directorin,fragment=pyfrag) __VA_ARGS__, const __VA_ARGS__& 
  "$input = from_meth((__VA_ARGS__)$1_name);";
%enddef

/* directorout */

%define PYVAL_DIRECTOROUT_TYPEMAP(as_meth,pyfrag,...)
  %typemap(directorargout,fragment=pyfrag) __VA_ARGS__ *DIRECTOROUT
    "*$result = ($basetype) as_meth($input);
     if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using as_meth\");";
%typemap(directorout,fragment=pyfrag) __VA_ARGS__
    "$result = ($basetype) as_meth($input);
    if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using as_meth\");";
%typemap(directorout,fragment=pyfrag) const __VA_ARGS__&
    "$basetype temp = ($basetype) as_meth($input);
     $result = &temp;
     if (PyErr_Occurred()) throw Swig::DirectorTypeMismatchException(\"Error converting Python object using as_meth\");";
  %typemap(directorout,fragment=pyfrag) __VA_ARGS__ &DIRECTOROUT = __VA_ARGS__
%enddef

/* throws */

%define PYVAL_THROWS_TYPEMAP(from_meth,pyfrag,...)
  %typemap(throws,fragment=pyfrag) __VA_ARGS__ {
    PyErr_SetObject(PyExc_RuntimeError, from_meth((__VA_ARGS__)$1));
    SWIG_fail;
  }
%enddef

/* typecheck */

%define PYVAL_TYPECHECK_TYPEMAP(check,pyobj_check,pyfrag,...)
%typemap(typecheck,precedence=check,fragment=pyfrag) 
  __VA_ARGS__, const __VA_ARGS__&
 "$1 = pyobj_check($input);";
%enddef

/*
  typemap definition for types with As/Check methods
*/
%define %typemap_ascheck(CheckCode, AsMeth, CheckMeth,
			 AsFrag, CheckFrag, ...)
  PYVAL_IN_TYPEMAP(SWIG_arg(AsMeth), SWIG_arg(AsFrag), __VA_ARGS__);
  PYVAL_VARIN_TYPEMAP(SWIG_arg(AsMeth), SWIG_arg(AsFrag), __VA_ARGS__);
  PYVAL_DIRECTOROUT_TYPEMAP(SWIG_arg(AsMeth), SWIG_arg(AsFrag), __VA_ARGS__);
  PYVAL_TYPECHECK_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(CheckMeth), 
			  SWIG_arg(CheckFrag), __VA_ARGS__);

  PYVAL_INPUT_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsMeth), SWIG_arg(CheckMeth),
		      SWIG_arg(AsFrag), SWIG_arg(CheckFrag), __VA_ARGS__);
%enddef


/*
  typemap definition for types with AsVal method
*/
%define %typemap_asvaln(CheckCode, ...)
%fragment(SWIG_As_frag(__VA_ARGS__),"header",
	  fragment=SWIG_AsVal_frag(__VA_ARGS__)) %{
SWIGINTERNSHORT __VA_ARGS__
SWIG_As(__VA_ARGS__)(PyObject* obj)
{
  __VA_ARGS__ v;
  if (!SWIG_AsVal(__VA_ARGS__)(obj, &v)) {
    /*
      this is needed to make valgrind/purify happier.  the other
      solution is throw an exception, but since this code should work
      with plain C ....
     */
    memset((void*)&v, 0, sizeof(__VA_ARGS__));
  }
  return v;
}
%}
%fragment(SWIG_Check_frag(__VA_ARGS__),"header",
	  fragment=SWIG_AsVal_frag(__VA_ARGS__)) %{  
SWIGINTERNSHORT int
SWIG_Check(__VA_ARGS__)(PyObject* obj)
{
  return SWIG_AsVal(__VA_ARGS__)(obj, (__VA_ARGS__*)0);
}
%}
%typemap_ascheck(SWIG_arg(CheckCode),
		 SWIG_As(__VA_ARGS__), 
		 SWIG_Check(__VA_ARGS__), 
		 SWIG_arg(SWIG_As_frag(__VA_ARGS__)), 
		 SWIG_arg(SWIG_Check_frag(__VA_ARGS__)), 
		 __VA_ARGS__);
%enddef

/*
  typemap definition for types with from method
*/
%define %typemap_from(FromMeth, FromFrag, ...)
  PYVAL_OUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYVAL_VAROUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYVAL_CONSTCODE_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYVAL_DIRECTORIN_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);
  PYVAL_THROWS_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag),__VA_ARGS__);

  PYVAL_OUTPUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);

%enddef


%define %typemap_ascheckfrom(CheckCode, AsMeth, CheckMeth, FromMeth,
			     AsFrag, CheckFrag, FromFrag, ...)
  %typemap_ascheck(SWIG_arg(CheckCode), SWIG_arg(AsMeth), SWIG_arg(CheckMeth),
		   SWIG_arg(AsFrag), SWIG_arg(CheckFrag), __VA_ARGS__);
  %typemap_from(SWIG_arg(FromMeth), SWIG_arg(FromFrag), __VA_ARGS__);

  PYVAL_INOUT_TYPEMAP(__VA_ARGS__);

%enddef



/*
  typemap definition for types with asval/from method
*/
%define %typemap_asvalfromn(CheckCode, ...)
  %typemap_asvaln(SWIG_arg(CheckCode), __VA_ARGS__);
  %typemap_from(SWIG_arg(SWIG_From(__VA_ARGS__)), 
		SWIG_arg(SWIG_From_frag(__VA_ARGS__)), 
		__VA_ARGS__);

  PYVAL_INOUT_TYPEMAP(__VA_ARGS__);

%enddef


/*
  typemap definition for types with as/check/from method
*/
%define %typemap_ascheckfromn(CheckCode, ...)
 %typemap_ascheckfrom(SWIG_arg(CheckCode),
		      SWIG_As(__VA_ARGS__), 
		      SWIG_From(__VA_ARGS__), 
		      SWIG_Check(__VA_ARGS__), 
		      SWIG_arg(SWIG_As_frag(__VA_ARGS__)), 
		      SWIG_arg(SWIG_From_frag(__VA_ARGS__)), 
		      SWIG_arg(SWIG_Check_frag(__VA_ARGS__)), 
		      __VA_ARGS__);
%enddef
