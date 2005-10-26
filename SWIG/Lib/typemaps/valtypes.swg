/*---------------------------------------------------------------------
 * Value typemaps (Type, const Type&) for value types, such as
 * fundamental types (int, double), that define the AsVal/From
 * methods.
 *
 * To apply them, just use one of the following macros:
 *
 *   %typemaps_from(FromMeth, FromFrag, Type)
 *   %typemaps_asval(CheckCode, AsValMeth, AsValFrag, Type)
 *   %typemaps_asvalfrom(CheckCode, AsValMeth, FromMeth, AsValFrag, FromFrag, Type)
 *
 * or the simpler and normalize form:
 *
 *   %typemaps_asvalfromn(CheckCode, Type)
 *
 * Also, you can use the individual typemap definitions:
 *
 *    %value_in_typemap(asval_meth,frag,Type)
 *    %value_varin_typemap(asval_meth,frag,Type)
 *    %value_typecheck_typemap(checkcode,asval_meth,frag,Type)
 *    %value_directorout_typemap(asval_meth,frag,Type)
 *
 *    %value_out_typemap(from_meth,frag,Type)
 *    %value_varout_typemap(from_meth,frag,Type)
 *    %value_constcode_typemap(from_meth,frag,Type)
 *    %value_directorin_typemap(from_meth,frag,Type)
 *    %value_throws_typemap(from_meth,frag,Type)
 *
 *---------------------------------------------------------------------*/

/* in */

%define %value_in_typemap(asval_meth,frag,Type...)
  %typemap(in,noblock=1,fragment=frag) Type (Type val, int ecode = 0) {
    ecode = asval_meth($input, &val);
    if (ecode != SWIG_OK) {
      %argument_fail(ecode, "$ltype", $argnum);
    } 
    $1 = %static_cast(val,$ltype);
  }
  %typemap(in,noblock=1,fragment=frag) const Type & ($*ltype temp, Type val, int ecode = 0) {  
    ecode = asval_meth($input, &val);
    if (ecode != SWIG_OK) {
      %argument_fail(ecode, "$*ltype", $argnum);
    } 
    temp = %static_cast(val, $*ltype);
    $1 = &temp;
  }
%enddef

/* out */

%define %value_out_typemap(from_meth,frag,Type...)
  %typemap(out,noblock=1,fragment=frag) Type, const Type {
    %set_output(from_meth(%static_cast($1,Type))); 
  }
  %typemap(out,noblock=1,fragment=frag) const Type& {
    %set_output(from_meth(%static_cast(*$1,Type))); 
  }
%enddef

/* varin */

%define %value_varin_typemap(asval_meth,frag,Type...)
  %typemap(varin,noblock=1,fragment=frag) Type {
    Type val;
    int res = asval_meth($input, &val);
    if (res != SWIG_OK) {
      %variable_fail(res, "$type", "$name");
    }
    $1 = %static_cast(val,$ltype);
  }
%enddef

/* varout */

%define %value_varout_typemap(from_meth,frag,Type...)
  %typemap(varout,noblock=1,fragment=frag) Type, const Type&  {
    %set_varoutput(from_meth(%static_cast($1,Type)));
  }
%enddef

/* constant installation code */

%define %value_constcode_typemap(from_meth,frag,Type...)
  %typemap(constcode,noblock=1,fragment=frag) Type {
    %set_constant("$symname", from_meth(%static_cast($value,Type)));
  }
%enddef


#if defined(SWIG_DIRECTOR_TYPEMAPS)

/* directorin */

%define %value_directorin_typemap(from_meth,frag,Type...)
  %typemap(directorin,noblock=1,fragment=frag) Type *DIRECTORIN {
    $input = from_meth(%static_cast(*$1_name,Type)); 
  }
  %typemap(directorin,noblock=1,fragment=frag) Type, const Type& {
    $input = from_meth(%static_cast($1_name,Type)); 
  }
%enddef

/* directorout */

%define %value_directorout_typemap(asval_meth,frag,Type...)
  %typemap(directorargout,noblock=1,fragment=frag) Type *DIRECTOROUT {
    Type val;
    int res = asval_meth($input, &val);
    if (res != SWIG_OK) {
      %dirout_fail(res, "$type");
    } 
    *$result = %static_cast(val, $type);
  }
  %typemap(directorout,noblock=1,fragment=frag) Type {
    Type val;
    int res = asval_meth($input, &val);
    if (res != SWIG_OK) {
      %dirout_fail(res, "$type");
    }
    $result = %static_cast(val,$type);
  }
  %typemap(directorout,noblock=1,fragment=frag,warning=SWIG_WARN_TYPEMAP_THREAD_UNSAFE) const Type& {  
    Type val;
    int res = asval_meth($input, &val);
    if (res != SWIG_OK) {
      %dirout_fail(res, "$type");
    } 
    static $basetype temp = %static_cast(val, $basetype);
    $result = &temp;
  }
  %typemap(directorout,fragment=frag) Type &DIRECTOROUT = Type
%enddef

#else

#define %value_directorin_typemap(from_meth,frag,Type...)
#define %value_directorout_typemap(asval_meth,frag,Type...)

#endif /* SWIG_DIRECTOR_TYPEMAPS */


/* throws */

%define %value_throws_typemap(from_meth,frag,Type...)
  %typemap(throws,noblock=1,fragment=frag) Type {
    %raise(from_meth(%static_cast($1,Type)), "$type", 0);
  }
%enddef

/* typecheck */

%define %value_typecheck_typemap(check,asval_meth,frag,Type...)
  %typemap(typecheck,noblock=1,precedence=check,fragment=frag) Type, const Type& {
    $1 = (asval_meth($input, 0) == SWIG_OK);
  }
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with AsVal methods
 *---------------------------------------------------------------------*/
%define %typemaps_asval(CheckCode, AsValMeth, AsValFrag, Type...)
  %value_in_typemap(%arg(AsValMeth), %arg(AsValFrag), Type);
  %value_varin_typemap(%arg(AsValMeth), %arg(AsValFrag), Type);
  %value_directorout_typemap(%arg(AsValMeth), %arg(AsValFrag), Type);
  %value_typecheck_typemap(%arg(CheckCode), %arg(AsValMeth), %arg(AsValFrag), Type);
  %value_input_typemap(%arg(CheckCode), %arg(AsValMeth), %arg(AsValFrag), Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types with from method
 *---------------------------------------------------------------------*/
%define %typemaps_from(FromMeth, FromFrag, Type...)
  %value_out_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_varout_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_constcode_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_directorin_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_throws_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_output_typemap(%arg(FromMeth), %arg(FromFrag), Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types with alval/from method
 *---------------------------------------------------------------------*/

%define %typemaps_asvalfrom(CheckCode, AsValMeth, FromMeth,
			   AsValFrag, FromFrag, Type...)
  %typemaps_asval(%arg(CheckCode), %arg(AsValMeth), %arg(AsValFrag), Type);
  %typemaps_from(%arg(FromMeth), %arg(FromFrag), Type);
  %value_inout_typemap(Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types  with for 'normalized' asval/from methods
 *---------------------------------------------------------------------*/
%define %typemaps_asvalfromn(CheckCode, Type...)
  %typemaps_asvalfrom(%arg(CheckCode),
		     SWIG_AsVal(Type), 
		     SWIG_From(Type), 
		     %arg(SWIG_AsVal_frag(Type)),
		     %arg(SWIG_From_frag(Type)), 
		     Type);
%enddef
