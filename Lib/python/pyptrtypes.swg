/*
  Value typemaps (Type, const Type&) for "Ptr" types, such as swig
  wrapped classes, that define the AsPtr/From methods
*/

/* in */

%define PYPTR_IN_TYPEMAP(asptr_meth,pyfrag,Type...)
  %typemap(in,fragment=pyfrag) Type {
    Type *ptr = (Type *)0;
    int res = asptr_meth($input, &ptr);
    if (!res) {
      if (!PyErr_Occurred())
	SWIG_type_error("$basetype", $input);
    } else if (!ptr) {
      SWIG_null_ref("$basetype");
    }
    if (SWIG_arg_fail($argnum)) SWIG_fail;
    $1 = *ptr;
    if (res == SWIG_NEWOBJ) delete ptr;
  }
  %typemap(in,fragment=pyfrag) const Type & (int res = 0) {
    Type *ptr = (Type *)0;
    res = asptr_meth($input, &ptr);
    if (!res) {
      if (!PyErr_Occurred())
	SWIG_type_error("$basetype", $input);
    } else if (!ptr) {
      SWIG_null_ref("$basetype");
    }
    if (SWIG_arg_fail($argnum)) SWIG_fail;
    $1 = ptr;
  }

  %typemap(freearg) const Type & 
    "if (res$argnum == SWIG_NEWOBJ) delete $1;";
%enddef

/* varin */

%define PYPTR_VARIN_TYPEMAP(asptr_meth,pyfrag,Type...)
  %typemap(varin,fragment=pyfrag) Type {
    Type *ptr = (Type *)0;
    int res = asptr_meth($input, &ptr);
    if (!res) {
      if (!PyErr_Occurred()) {
	SWIG_type_error("$basetype", $input);
      }
      SWIG_append_errmsg(" C/C++ variable '$name'");
      return 1;
    } else if (!ptr) {
      SWIG_null_ref("$basetype");
      SWIG_append_errmsg(" C/C++ variable '$name'");
      return 1;
    }
    $1 = *ptr;
    if (res == SWIG_NEWOBJ) delete ptr;
  }
%enddef

/* directorout */

%define PYPTR_DIRECTOROUT_TYPEMAP(asptr_meth,pyfrag,Type...)
  %typemap(directorargout,fragment=pyfrag) Type *DIRECTOROUT ($*1_ltype temp) {
    Type *ptr = 0;
    int res = $input ? asptr_meth($input, &ptr) : 0;
    if (!res || !ptr) 
      Swig::DirectorTypeMismatchException::raise("Error converting Python object when using asptr_meth.");
    temp = *ptr;
    $result = &temp;
    if (res == SWIG_NEWOBJ) delete ptr;
  }

  %typemap(directorout,fragment=pyfrag) Type {
    Type *ptr = 0;
    int res = $input ? asptr_meth($input, &ptr) : 0;
    if (!res || !ptr) 
      Swig::DirectorTypeMismatchException::raise("Error converting Python object when using asptr_meth.");
    $result = *ptr;
    if (res == SWIG_NEWOBJ) delete ptr;
  }

  %typemap(directorout,fragment=pyfrag,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const Type& {
    Type *ptr = 0;
    int res = $input ? asptr_meth($input, &ptr) : 0;
    if (!res || !ptr) 
      Swig::DirectorTypeMismatchException::raise("Error converting Python object when using asptr_meth.");
    $result = ptr;
    if (res == SWIG_NEWOBJ) {
      /* Possible thread/reentrant problem here! */
      static $*ltype temp = *ptr;
      $result = &temp;
      delete ptr;
    } else {
      $result = ptr;
    }
  }

  %typemap(directorout,fragment=pyfrag) Type &DIRECTOROUT = Type

%enddef

/* typecheck */

%define PYPTR_TYPECHECK_TYPEMAP(check,asptr_meth,pyfrag,Type...)
%typemap(typecheck,precedence=check,fragment=pyfrag) 
   Type, const Type&
   "$1 = asptr_meth($input, (Type**)(0));";
%enddef

/*
  typemap definition for types with AsPtr/From methods
 */

%define %typemap_asptrfrom(CheckCode, AsPtrMeth, FromMeth, AsPtrFrag, FromFrag, Type...)
  %fragment(SWIG_AsVal_frag(Type),"header",
	    fragment=SWIG_AsPtr_frag(Type)) %{
  SWIGINTERNINLINE int
    SWIG_AsVal(Type)(PyObject* obj, Type *val)
    {
      Type *v = (Type *)0;
      int res = SWIG_AsPtr(Type)(obj, &v);
      if (!res || !v) return 0;  
      if (val) {
	*val = *v;
	if (res == SWIG_NEWOBJ) delete v;
      }
      return 1;
    }
  %}
  %fragment(SWIG_As_frag(Type),"header",
	    fragment=SWIG_AsVal_frag(Type)) %{
  SWIGINTERNINLINE Type
    SWIG_As(Type)(PyObject* obj)
    {
      Type v;
      SWIG_AsVal(Type)(obj, &v);
      return v;
    }
  %}
  PYPTR_IN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), Type);
  PYPTR_VARIN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), Type);
  PYPTR_DIRECTOROUT_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), Type);
  PYPTR_TYPECHECK_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsPtrMeth), 
			  SWIG_arg(AsPtrFrag), Type);
  %typemap_from(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);

  PYPTR_INPUT_TYPEMAP(SWIG_arg(CheckCode),SWIG_arg(AsPtrMeth),
		      SWIG_arg(AsPtrFrag),Type);
  PYVAL_OUTPUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  PYPTR_INOUT_TYPEMAP(Type);
%enddef

/*
  typemap for simple swig types with only AsPtr/From methods
*/

%define %typemap_asptrfromn(CheckCode, Type...)
%typemap_asptrfrom(SWIG_arg(CheckCode),
		   SWIG_arg(SWIG_AsPtr(Type)), 
		   SWIG_arg(SWIG_From(Type)), 
		   SWIG_arg(SWIG_AsPtr_frag(Type)), 
		   SWIG_arg(SWIG_From_frag(Type)), 
		   Type);
%enddef
