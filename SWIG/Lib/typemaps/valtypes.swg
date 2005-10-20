/*---------------------------------------------------------------------
 * Value typemaps (Type, const Type&) for value types, such as
 * fundamental types (int, double), that define the AsVal/From
 * methods.
 *---------------------------------------------------------------------*/

/* in */

%define SWIG_VALUE_IN_TYPEMAP(asval_meth,frag,Type...)
  %typemap(in,noblock=1,fragment=frag) Type (Type val, int ecode = 0) {
    ecode = asval_meth($input, &val);
    if (ecode != SWIG_OK) {
      SWIG_arg_fail(ecode, "$ltype", $argnum);
    } else {
      $1 = SWIG_static_cast(val,$ltype);
    }
  }
  %typemap(in,noblock=1,fragment=frag) const Type & ($*ltype temp, Type val, int ecode = 0) {  
    ecode = asval_meth($input, &val);
    if (ecode != SWIG_OK) {
      SWIG_arg_fail(ecode, "$*ltype", $argnum);
    } else {
      temp = SWIG_static_cast(val, $*ltype);
      $1 = &temp;
    }
  }
%enddef

/* out */

%define SWIG_VALUE_OUT_TYPEMAP(from_meth,frag,Type...)
  %typemap(out,noblock=1,fragment=frag) Type, const Type {
    SWIG_set_result(from_meth(SWIG_static_cast($1,Type))); 
  }
  %typemap(out,noblock=1,fragment=frag) const Type& {
    SWIG_set_result(from_meth(SWIG_static_cast(*$1,Type))); 
  }
%enddef

/* varin */

%define SWIG_VALUE_VARIN_TYPEMAP(asval_meth,frag,Type...)
  %typemap(varin,noblock=1,fragment=frag) Type {
    Type val;
    int res = asval_meth($input, &val);
    if (res != SWIG_OK) {
      SWIG_var_fail(res, "$type", "$name");
    } else {
      $1 = SWIG_static_cast(val,$ltype);
    }
  }
%enddef

/* varout */

%define SWIG_VALUE_VAROUT_TYPEMAP(from_meth,frag,Type...)
  %typemap(varout,noblock=1,fragment=frag) Type, const Type&  {
    $result = from_meth(SWIG_static_cast($1,$basetype));
  }
%enddef

/* constant installation code */

%define SWIG_VALUE_CONSTCODE_TYPEMAP(from_meth,frag,Type...)
  %typemap(constcode,noblock=1,fragment=frag) Type {
    SWIG_set_constant("$symname", from_meth(SWIG_static_cast($value,Type)));
  }
%enddef


#ifdef SWIG_DIRECTOR_TYPEMAPS

/* directorin */

%define SWIG_VALUE_DIRECTORIN_TYPEMAP(from_meth,frag,Type...)
  %typemap(directorin,noblock=1,fragment=frag) Type *DIRECTORIN {
    $input = from_meth(SWIG_static_cast(*$1_name,Type)); 
  }
  %typemap(directorin,noblock=1,fragment=frag) Type, const Type& {
    $input = from_meth(SWIG_static_cast($1_name,Type)); 
  }
%enddef

/* directorout */

%define SWIG_VALUE_DIRECTOROUT_TYPEMAP(asval_meth,frag,Type...)
  %typemap(directorargout,noblock=1,fragment=frag) Type *DIRECTOROUT {
    Type val;
    int res = asval_meth($input, &val);
    if (res != SWIG_OK) {
      SWIG_dout_fail(res, "$type");
    } 
    *$result = SWIG_static_cast(val, $type);
  }
  %typemap(directorout,noblock=1,fragment=frag) Type {
    Type val;
    int res = asval_meth($input, &val);
    if (res != SWIG_OK) {
      SWIG_dout_fail(res, "$type");
    }
    $result = SWIG_static_cast(val,$type);
  }
  %typemap(directorout,noblock=1,fragment=frag,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const Type& {  
    Type val;
    int res = asval_meth($input, &val);
    if (res != SWIG_OK) {
      SWIG_dout_fail(res, "$type");
    } 
    static $basetype temp = SWIG_static_cast(val, $basetype);
    $result = &temp;
  }
  %typemap(directorout,fragment=frag) Type &DIRECTOROUT = Type
%enddef

#else

#define SWIG_VALUE_DIRECTORIN_TYPEMAP(from_meth,frag,Type...)
#define SWIG_VALUE_DIRECTOROUT_TYPEMAP(asval_meth,frag,Type...)

#endif /* SWIG_DIRECTOR_TYPEMAPS */


/* throws */

%define SWIG_VALUE_THROWS_TYPEMAP(from_meth,frag,Type...)
  %typemap(throws,noblock=1,fragment=frag) Type {
    SWIG_raise(from_meth(SWIG_static_cast($1,Type)), "$type", 0);
  }
%enddef

/* typecheck */

%define SWIG_VALUE_TYPECHECK_TYPEMAP(check,asval_meth,frag,Type...)
  %typemap(typecheck,noblock=1,precedence=check,fragment=frag) Type, const Type& {
    $1 = (asval_meth($input, 0) == SWIG_OK);
  }
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with AsVal methods
 *---------------------------------------------------------------------*/
%define %typemap_asval(CheckCode, AsValMeth, AsValFrag, Type...)
  SWIG_VALUE_IN_TYPEMAP(SWIG_arg(AsValMeth), SWIG_arg(AsValFrag), Type);
  SWIG_VALUE_VARIN_TYPEMAP(SWIG_arg(AsValMeth), SWIG_arg(AsValFrag), Type);
  SWIG_VALUE_DIRECTOROUT_TYPEMAP(SWIG_arg(AsValMeth), SWIG_arg(AsValFrag), Type);
  SWIG_VALUE_TYPECHECK_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsValMeth), SWIG_arg(AsValFrag), Type);
  SWIG_VALUE_INPUT_TYPEMAP(SWIG_arg(CheckCode), SWIG_arg(AsValMeth), SWIG_arg(AsValFrag), Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types with from method
 *---------------------------------------------------------------------*/
%define %typemap_from(FromMeth, FromFrag, Type...)
  SWIG_VALUE_OUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  SWIG_VALUE_VAROUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  SWIG_VALUE_CONSTCODE_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  SWIG_VALUE_DIRECTORIN_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  SWIG_VALUE_THROWS_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  SWIG_VALUE_OUTPUT_TYPEMAP(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types with alval/from method
 *---------------------------------------------------------------------*/

%define %typemap_asvalfrom(CheckCode, AsValMeth, FromMeth,
			   AsValFrag, FromFrag, Type...)
  %typemap_asval(SWIG_arg(CheckCode), SWIG_arg(AsValMeth), SWIG_arg(AsValFrag), Type);
  %typemap_from(SWIG_arg(FromMeth), SWIG_arg(FromFrag), Type);
  SWIG_VALUE_INOUT_TYPEMAP(Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types  with for 'normalized' asval/from methods
 *---------------------------------------------------------------------*/
%define %typemap_asvalfromn(CheckCode, Type...)
  %typemap_asvalfrom(SWIG_arg(CheckCode),
		     SWIG_AsVal(Type), 
		     SWIG_From(Type), 
		     SWIG_arg(SWIG_AsVal_frag(Type)),
		     SWIG_arg(SWIG_From_frag(Type)), 
		     Type);
%enddef
