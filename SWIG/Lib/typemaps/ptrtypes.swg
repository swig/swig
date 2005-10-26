/*---------------------------------------------------------------------
 * Value typemaps (Type, const Type&) for "Ptr" types, such as swig
 * wrapped classes, that define the AsPtr/From methods
 *
 * To apply them, just use one of the following macros:
 *
 *    %typemaps_asptr(CheckCode, AsPtrMeth, AsPtrFrag, Type)
 *    %typemaps_asptrfrom(CheckCode, AsPtrMeth, FromMeth, AsPtrFrag, FromFrag, Type)
 *
 * or the simpler and normalize form:
 *
 *    %typemaps_asptrfromn(CheckCode, Type)
 *
 * Also, you can use the individual typemap definitions:
 *
 *    %ptr_in_typemap(asptr_meth,frag,Type)
 *    %ptr_varin_typemap(asptr_meth,frag,Type)
 *    %ptr_typecheck_typemap(check,asptr_meth,frag,Type)
 *    %ptr_directorout_typemap(asptr_meth,frag,Type)
 *
 *---------------------------------------------------------------------*/

%include <typemaps/valtypes.swg>

/* in */

%define %ptr_in_typemap(asptr_meth,frag,Type...)
  %typemap(in,fragment=frag) Type {
    Type *ptr = (Type *)0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) { %argument_fail(SWIG_TypeError, "$type", $argnum); }
    $1 = *ptr;
    if (res == SWIG_NEWOBJ) %delete(ptr);
  }
  %typemap(in,fragment=frag) const Type & (int res = 0) {
    Type *ptr = (Type *)0;
    res = asptr_meth($input, &ptr);
    if (!res) { %argument_fail(SWIG_TypeError,"$type",$argnum); }
    if (!ptr) { %argument_nullref("$type",$argnum); }
    $1 = ptr;
  }
  %typemap(freearg,noblock=1) const Type &  {
    if (res$argnum == SWIG_NEWOBJ) %delete($1);
  }
%enddef

/* varin */

%define %ptr_varin_typemap(asptr_meth,frag,Type...)
  %typemap(varin,fragment=frag) Type {
    Type *ptr = (Type *)0;
    int res = asptr_meth($input, &ptr);
    if (!res || !ptr) { %variable_fail(SWIG_TypeError, "$type", "$name"); }
    $1 = *ptr;
    if (res == SWIG_NEWOBJ) %delete(ptr);
  }
%enddef

#if defined(SWIG_DIRECTOR_TYPEMAPS)
/* directorout */

%define %ptr_directorout_typemap(asptr_meth,frag,Type...)
  %typemap(directorargout,noblock=1,fragment=frag) Type *DIRECTOROUT ($*ltype temp) {
    Type *optr = 0;
    int ores = $input ? asptr_meth($input, &optr) : 0;
    if (!ores || !optr) { 
      %dirout_fail(SWIG_TypeError,"$type");
    }
    temp = *optr;
    $result = &temp;
    if (ores == SWIG_NEWOBJ) %delete(optr);
  }

  %typemap(directorout,noblock=1,fragment=frag) Type {
    Type *optr = 0;
    int ores = asptr_meth($input, &optr);
    if (!ores || !optr) { 
      %dirout_fail(SWIG_TypeError,"$type");
    }
    $result = *optr;
    if (ores == SWIG_NEWOBJ) %delete(optr);
  }

  %typemap(directorout,noblock=1,fragment=frag,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const Type& {
    Type *optr = 0;
    int ores = asptr_meth($input, &optr);
    if (!ores) { 
      %dirout_fail(SWIG_TypeError,"$type");
    } else {
      if (!optr) { 
	%dirout_nullref("$type");
      } 
    }    
    if (ores == SWIG_NEWOBJ) {
      /* Possible thread/reentrant problem here! */
      static $*ltype temp = *optr;
      $result = &temp;
      %delete(optr);
    } else {
      $result = optr;
    }
  }

  %typemap(directorout,fragment=frag) Type &DIRECTOROUT = Type

%enddef

#else

#define %ptr_directorout_typemap(asptr_meth,frag,Type...) 

#endif /* SWIG_DIRECTOR_TYPEMAPS */

/* typecheck */

%define %ptr_typecheck_typemap(check,asptr_meth,frag,Type...)
%typemap(typecheck,precedence=check,fragment=frag) 
   Type, const Type&
   "$1 = asptr_meth($input, (Type**)(0));";
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types with asptr method
 *---------------------------------------------------------------------*/

%define %typemaps_asptr(CheckCode, AsPtrMeth, AsPtrFrag, Type...)
  %fragment(SWIG_AsVal_frag(Type),"header",fragment=SWIG_AsPtr_frag(Type)) {
    SWIGINTERNINLINE int
    SWIG_AsVal(Type)(SWIG_Object obj, Type *val)
    {
      Type *v = (Type *)0;
      int res = SWIG_AsPtr(Type)(obj, &v);
      if (!res || !v) return SWIG_ERROR;
      if (val) {
	*val = *v;
	if (res == SWIG_NEWOBJ) %delete(v);
      }
      return SWIG_OK;
    }
  }
  %ptr_in_typemap(%arg(AsPtrMeth), %arg(AsPtrFrag), Type);
  %ptr_varin_typemap(%arg(AsPtrMeth), %arg(AsPtrFrag), Type);
  %ptr_directorout_typemap(%arg(AsPtrMeth), %arg(AsPtrFrag), Type);
  %ptr_typecheck_typemap(%arg(CheckCode), %arg(AsPtrMeth),%arg(AsPtrFrag), Type);
  %ptr_input_typemap(%arg(CheckCode),%arg(AsPtrMeth),%arg(AsPtrFrag),Type);
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with asptr/from methods
 *---------------------------------------------------------------------*/

%define %typemaps_asptrfrom(CheckCode, AsPtrMeth, FromMeth, AsPtrFrag, FromFrag, Type...)
  %typemaps_asptr(%arg(CheckCode), %arg(AsPtrMeth), %arg(AsPtrFrag), Type)
  %typemaps_from(%arg(FromMeth), %arg(FromFrag), Type);
  %value_output_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %ptr_inout_typemap(Type);
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types  with for 'normalized' asptr/from methods
 *---------------------------------------------------------------------*/

%define %typemaps_asptrfromn(CheckCode, Type...)
%typemaps_asptrfrom(%arg(CheckCode),
		   %arg(SWIG_AsPtr(Type)), 
		   %arg(SWIG_From(Type)), 
		   %arg(SWIG_AsPtr_frag(Type)), 
		   %arg(SWIG_From_frag(Type)), 
		   Type);
%enddef
