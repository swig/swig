/*---------------------------------------------------------------------
 * Value typemaps (Type, const Type&) for value types, such as
 * fundamental types (int, double), that define the As/AsVal/From
 * methods.
 *---------------------------------------------------------------------*/


/* in */

%define PYVAL_IN_TYPEMAP(as_meth,pyfrag,Type...)
  %typemap(in,fragment=pyfrag) Type {
    $1 = SWIG_static_cast(SWIG_arg(as_meth($input)),$type); 
    if (SWIG_arg_fail($argnum)) SWIG_fail;
  }
  %typemap(in,fragment=pyfrag) const Type & ($*ltype temp) {  
     temp = SWIG_static_cast(SWIG_arg(as_meth($input)),$basetype);
     if (SWIG_arg_fail($argnum)) SWIG_fail;
     $1 = &temp;
  }
%enddef

/* out */

%define PYVAL_OUT_TYPEMAP(from_meth,pyfrag,Type...)
  %typemap(out,fragment=pyfrag) Type, const Type 
  { $result = from_meth(SWIG_static_cast($1,Type)); }

  %typemap(out,fragment=pyfrag) const Type& 
  { $result = from_meth(SWIG_static_cast(*$1,Type)); }
%enddef

/* varin */

%define PYVAL_VARIN_TYPEMAP(as_meth,pyfrag,Type...)
  %typemap(varin,fragment=pyfrag) Type {
    $1_type temp = SWIG_static_cast(SWIG_arg(as_meth($input)),$1_type);
    if (PyErr_Occurred()) {
      SWIG_append_errmsg("C/C++ variable '$name ($1_ltype)'");
      return 1;
    }
    $1 = temp;
  }
%enddef

/* varout */

%define PYVAL_VAROUT_TYPEMAP(from_meth,pyfrag,Type...)
  %typemap(varout,fragment=pyfrag) Type, const Type&  
   { $result = from_meth(SWIG_static_cast($1,$basetype)); }
%enddef

/* constant installation code */

%define PYVAL_CONSTCODE_TYPEMAP(from_meth,pyfrag,Type...)
  %typemap(constcode,fragment=pyfrag) Type
  { PyDict_SetItemString(d,"$symname", from_meth(SWIG_static_cast($value,$basetype))); }
%enddef

/* directorin */

%define PYVAL_DIRECTORIN_TYPEMAP(from_meth,pyfrag,Type...)
  %typemap(directorin,fragment=pyfrag) Type *DIRECTORIN 
  { $input = from_meth(SWIG_static_cast(*$1_name,$basetype)); }
  %typemap(directorin,fragment=pyfrag) Type, const Type& 
  { $input = from_meth(SWIG_static_cast($1_name,$basetype)); }
%enddef

/* directorout */

%define PYVAL_DIRECTOROUT_TYPEMAP(as_meth,pyfrag,Type...)
  %typemap(directorargout,fragment=pyfrag) Type *DIRECTOROUT {
    if ($input) *$result = SWIG_static_cast(SWIG_arg(as_meth($input)),$type);
    if (!$input || PyErr_Occurred()) 
      Swig::DirectorTypeMismatchException::raise("Error converting Python object when using as_meth.");
  }
  %typemap(directorout,fragment=pyfrag) Type {
    if ($input) $result = SWIG_static_cast(SWIG_arg(as_meth($input)),$type);
    if (!$input || PyErr_Occurred())
      Swig::DirectorTypeMismatchException::raise("Error converting Python object when using as_meth.");
  }
  %typemap(directorout,fragment=pyfrag,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const Type& {  
    if ($input) {
      static $basetype temp = SWIG_static_cast(SWIG_arg(as_meth($input)),$basetype);
      $result = &temp;
    }
    if (!$input || PyErr_Occurred()) 
      Swig::DirectorTypeMismatchException::raise("Error converting Python object when using as_meth.");
  }
  %typemap(directorout,fragment=pyfrag) Type &DIRECTOROUT = Type
%enddef

/* throws */

%define PYVAL_THROWS_TYPEMAP(from_meth,pyfrag,Type...)
  %typemap(throws,fragment=pyfrag) Type {
    PyErr_SetObject(PyExc_RuntimeError, from_meth(SWIG_static_cast($1,$basetype)));
    SWIG_fail;
  }
%enddef

/* typecheck */

%define PYVAL_TYPECHECK_TYPEMAP(check,pyobj_check,pyfrag,Type...)
%typemap(typecheck,precedence=check,fragment=pyfrag) 
  Type, const Type&
 "$1 = pyobj_check($input);";
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with As/Check methods
 *---------------------------------------------------------------------*/
%define %typemap_ascheck(CheckCode, AsMeth, CheckMeth,
			 AsFrag, CheckFrag, Type...)
  PYVAL_IN_TYPEMAP(SWIG_arg(AsMeth), SWIG_arg(AsFrag), Type);
  PYVAL_VARIN_TYPEMAP(SWIG_arg(AsMeth), SWIG_arg(AsFrag), Type);
  PYVAL_DIRECTOROUT_TYPEMAP(SWIG_arg(AsMeth), SWIG_arg(AsFrag), Type);
  PYVAL_TYPECHECK_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(CheckMeth), 
			  SWIG_arg(CheckFrag), Type);

  PYVAL_INPUT_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsMeth), SWIG_arg(CheckMeth),
		      SWIG_arg(AsFrag), SWIG_arg(CheckFrag), Type);
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with AsVal method
 *---------------------------------------------------------------------*/
%define %typemap_asvaln(CheckCode, Type...)
%fragment(SWIG_As_frag(Type),"header",
	  fragment=SWIG_AsVal_frag(Type)) %{
SWIGINTERNINLINE Type
SWIG_As(Type)(PyObject* obj)
{
  Type v;
  if (!SWIG_AsVal(Type)(obj, &v)) {
    /*
      this is needed to make valgrind/purify happier. 
     */
    memset((void*)&v, 0, sizeof(Type));
  }
  return v;
}
%}
%fragment(SWIG_Check_frag(Type),"header",
	  fragment=SWIG_AsVal_frag(Type)) %{  
SWIGINTERNINLINE int
SWIG_Check(Type)(PyObject* obj)
{
  return SWIG_AsVal(Type)(obj, (Type*)0);
}
%}
%typemap_ascheck(SWIG_arg(CheckCode),
		 SWIG_As(Type), 
		 SWIG_Check(Type), 
		 SWIG_arg(SWIG_As_frag(Type)), 
		 SWIG_arg(SWIG_Check_frag(Type)), 
		 Type);
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with from method
 *---------------------------------------------------------------------*/
%define %typemap_from(FromMeth, FromFrag, Type...)
  PYVAL_OUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  PYVAL_VAROUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  PYVAL_CONSTCODE_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  PYVAL_DIRECTORIN_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  PYVAL_THROWS_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  PYVAL_OUTPUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);

%enddef


%define %typemap_ascheckfrom(CheckCode, AsMeth, CheckMeth, FromMeth,
			     AsFrag, CheckFrag, FromFrag, Type...)
  %typemap_ascheck(SWIG_arg(CheckCode), SWIG_arg(AsMeth), SWIG_arg(CheckMeth),
		   SWIG_arg(AsFrag), SWIG_arg(CheckFrag), Type);
  %typemap_from(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);

  PYVAL_INOUT_TYPEMAP(Type);

%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with asval/from method
 *---------------------------------------------------------------------*/
%define %typemap_asvalfromn(CheckCode, Type...)
  %typemap_asvaln(SWIG_arg(CheckCode), Type);
  %typemap_from(SWIG_arg(SWIG_From(Type)), 
		SWIG_arg(SWIG_From_frag(Type)), 
		Type);

  PYVAL_INOUT_TYPEMAP(Type);

%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with as/check/from method
 *---------------------------------------------------------------------*/
%define %typemap_ascheckfromn(CheckCode, Type...)
 %typemap_ascheckfrom(SWIG_arg(CheckCode),
		      SWIG_As(Type), 
		      SWIG_From(Type), 
		      SWIG_Check(Type), 
		      SWIG_arg(SWIG_As_frag(Type)), 
		      SWIG_arg(SWIG_From_frag(Type)), 
		      SWIG_arg(SWIG_Check_frag(Type)), 
		      Type);
%enddef
