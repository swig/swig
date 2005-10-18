/*
  Value typemaps (Type, const Type&) for "Ptr" types, such as swig
  wrapped classes, that define the AsPtr/From methods
*/

/* in */

%define SWIG_PTR_IN_TYPEMAP(asptr_meth,frag,Type...)
  %typemap(in,fragment=frag) Type {
    Type *ptr = (Type *)0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) { SWIG_arg_fail(SWIG_TypeError, "$type", $argnum); }
    $1 = *ptr;
    if (res == SWIG_NEWOBJ) SWIG_delete(ptr);
  }
  %typemap(in,fragment=frag) const Type & (int res = 0) {
    Type *ptr = (Type *)0;
    res = asptr_meth($input, &ptr);
    if (!res) { SWIG_arg_fail(SWIG_TypeError,"$type",$argnum); }
    if (!ptr) { SWIG_arg_nullref("$type",$argnum); }
    $1 = ptr;
  }
  %typemap(freearg,noblock=1) const Type &  {
    if (res$argnum == SWIG_NEWOBJ) SWIG_delete($1);
  }
%enddef

/* varin */

%define SWIG_PTR_VARIN_TYPEMAP(asptr_meth,frag,Type...)
  %typemap(varin,fragment=frag) Type {
    Type *ptr = (Type *)0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) { SWIG_var_fail(SWIG_TypeError, "$type", "$name"); }
    $1 = *ptr;
    if (res == SWIG_NEWOBJ) SWIG_delete(ptr);
  }
%enddef

#ifdef SWIG_DIRECTOR_TYPEMAPS
/* directorout */

%define SWIG_PTR_DIRECTOROUT_TYPEMAP(asptr_meth,frag,Type...)
  %typemap(directorargout,fragment=frag) Type *DIRECTOROUT ($*1_ltype temp) {
    Type *ptr = 0;
    int res = $input ? asptr_meth($input, &ptr) : 0;
    if (!res || !ptr) { 
      SWIG_dout_fail(SWIG_TypeError,"$type");
    } else {
      temp = *ptr;
      $result = &temp;
      if (res == SWIG_NEWOBJ) SWIG_delete(ptr);
    }
  }

  %typemap(directorout,fragment=frag) Type {
    Type *ptr = 0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) { 
      SWIG_dout_fail(SWIG_TypeError,"$type");
    } else {
      $result = *ptr;
      if (res == SWIG_NEWOBJ) SWIG_delete(ptr);
    }
  }

  %typemap(directorout,fragment=frag,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const Type& {
    Type *ptr = 0;
    int res = asptr_meth($input, &ptr);
    if (!res) { 
      SWIG_dout_fail(SWIG_TypeError,"$type");
    } else {
      if (!ptr) { 
	SWIG_dout_nullref("$type");
      } else {
	if (res == SWIG_NEWOBJ) {
	  /* Possible thread/reentrant problem here! */
	  static $*ltype temp = *ptr;
	  $result = &temp;
	  SWIG_delete(ptr);
	} else {
	  $result = ptr;
	}
      }
    }
  }

  %typemap(directorout,fragment=frag) Type &DIRECTOROUT = Type

%enddef

#else

#define SWIG_PTR_DIRECTOROUT_TYPEMAP(asptr_meth,frag,Type...) 

#endif /* SWIG_DIRECTOR_TYPEMAPS */

/* typecheck */

%define SWIG_PTR_TYPECHECK_TYPEMAP(check,asptr_meth,frag,Type...)
%typemap(typecheck,precedence=check,fragment=frag) 
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
    SWIG_AsVal(Type)(SWIG_Object obj, Type *val)
    {
      Type *v = (Type *)0;
      int res = SWIG_AsPtr(Type)(obj, &v);
      if (!res || !v) return 0;  
      if (val) {
	*val = *v;
	if (res == SWIG_NEWOBJ) SWIG_delete(v);
      }
      return 1;
    }
  %}
  %fragment(SWIG_As_frag(Type),"header",
	    fragment=SWIG_AsVal_frag(Type)) %{
  SWIGINTERNINLINE Type
    SWIG_As(Type)(SWIG_Object obj)
    {
      Type v;
      SWIG_AsVal(Type)(obj, &v);
      return v;
    }
  %}
  SWIG_PTR_IN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), Type);
  SWIG_PTR_VARIN_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), Type);
  SWIG_PTR_DIRECTOROUT_TYPEMAP(SWIG_arg(AsPtrMeth), SWIG_arg(AsPtrFrag), Type);
  SWIG_PTR_TYPECHECK_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsPtrMeth), 
			  SWIG_arg(AsPtrFrag), Type);
  %typemap_from(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);

  SWIG_PTR_INPUT_TYPEMAP(SWIG_arg(CheckCode),SWIG_arg(AsPtrMeth),
		      SWIG_arg(AsPtrFrag),Type);
  SWIG_VALUE_OUTPUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  SWIG_PTR_INOUT_TYPEMAP(Type);
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
