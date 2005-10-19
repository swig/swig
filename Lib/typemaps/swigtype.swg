/* -----------------------------------------------------------------------------
 * --- Input arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers and arrays */
%typemap(in, noblock=1) SWIGTYPE *, SWIGTYPE [] {
  if (SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&$1),$descriptor, $disown) != SWIG_OK) { 
    SWIG_arg_fail(SWIG_TypeError, "$type", $argnum); 
  }
}

%typemap(freearg) SWIGTYPE *, SWIGTYPE [] "";

%typemap(in, noblock=1) SWIGTYPE* const&  ($*ltype temp) {
  if (SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&temp), $*descriptor, $disown) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "$*ltype", $argnum); 
  }
  $1 = &temp;
}

/* Reference */
%typemap(in, noblock=1) SWIGTYPE & {  
  if (SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&$1), $descriptor, 0) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "$type", $argnum); 
  }
  if (!$1) { SWIG_arg_nullref("$type", $argnum); }
}

/* By value */
%typemap(in,noblock=1) SWIGTYPE ($&ltype argp) {
  if (SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&argp), $&descriptor, 0) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "$type", $argnum); 
  }  
  if (!argp) { SWIG_arg_nullref("$type", $argnum); }
  $1 = *argp;
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers, references */
%typemap(out,noblock=1) SWIGTYPE *, SWIGTYPE &, SWIGTYPE[] {
  SWIG_set_result(SWIG_NewPointerObj(SWIG_as_voidptr($1), $descriptor, $owner));
}

%typemap(out, noblock=1) SWIGTYPE* const& {
  SWIG_set_result(SWIG_NewPointerObj(SWIG_as_voidptr(*$1), $*descriptor, $owner));
}

/* Return by value */
%typemap(out, noblock=1) SWIGTYPE {
  SWIG_set_result(SWIG_NewPointerObj(SWIG_new_copy($1, $ltype), $&descriptor, SWIG_POINTER_OWN));
}

/* -----------------------------------------------------------------------------
 * --- Variable input --- 
 * ----------------------------------------------------------------------------- */

/* memberin/globalin/varin, for fix arrays. */

%typemap(memberin) SWIGTYPE [ANY] {
  $basetype *inp = SWIG_static_cast($input, $basetype *);
  if (inp) {
    $basetype *dest = SWIG_static_cast($1, $basetype *);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    SWIG_member_nullref("$type","$name");
  }
}

%typemap(globalin) SWIGTYPE [ANY] {
  $basetype *inp = SWIG_static_cast($input, $basetype *);
  if (inp) {
    $basetype *dest = SWIG_static_cast($1, $basetype *);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    SWIG_global_nullref("$type","$name");
  }
}

%typemap(varin,noblock=1) SWIGTYPE [ANY] {
  $basetype *inp = 0;
  if (SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&inp), $descriptor, 0) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  } else if (inp) {
    size_t ii = 0;
    $basetype *dest = SWIG_static_cast($1, $basetype *);
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    SWIG_var_nullref("$type", "$name");
  }
}

/* memberin/globalin/varin, for fix double arrays. */

%typemap(memberin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = SWIG_static_cast($input, $basetype (*)[$dim1]);
  if (inp) {
    $basetype (*dest)[$dim1] = SWIG_static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	SWIG_member_nullref("$type","$name");
      }
    }
  } else {
    SWIG_member_nullref("$type","$name");
  }
}

%typemap(globalin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = SWIG_static_cast($input, $basetype (*)[$dim1]);
  if (inp) {
    $basetype (*dest)[$dim1] = SWIG_static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	SWIG_global_nullref("$type","$name");
      }
    }
  } else {
    SWIG_global_nullref("$type","$name");
  }
}

%typemap(varin,noblock=1) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = 0;
  if (SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&inp), $descriptor, 0) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  } else if (inp) {
    $basetype (*dest)[$dim1] = SWIG_static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	SWIG_var_nullref("$type", "$name");
      }
    }
  } else {
    SWIG_var_nullref("$type", "$name");
  }
}

/* Pointers, references, and variable size arrays */

%typemap(varin,noblock=1) SWIGTYPE * {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, $descriptor, 0) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  }
  $1 = ($ltype) temp;
}

%typemap(varin,noblock=1,warning="462:Unable to set dimensionless array variable") SWIGTYPE []
{
  SWIG_var_fail(SWIG_AttributeError, "$type", "read-only $name");
}

%typemap(varin,noblock=1) SWIGTYPE & {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, $descriptor, 0) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  }
  if (!temp) {
    SWIG_var_nullref("$type", "$name");
  }
  $1 = *(SWIG_reinterpret_cast(temp, $ltype));
}

%typemap(varin,noblock=1) SWIGTYPE {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, $&descriptor, 0) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  }
  if (!temp) {
    SWIG_var_nullref("$type", "$name");
  }
  $1 = *(SWIG_reinterpret_cast(temp, $&type));
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */

/* Pointers and arrays */
%typemap(varout, noblock=1) SWIGTYPE * {
  $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $descriptor, 0);
}

%typemap(varout, noblock=1) SWIGTYPE [] {
  $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), $descriptor, 0);
}

/* References */
%typemap(varout, noblock=1) SWIGTYPE & {
  $result = SWIG_NewPointerObj(SWIG_as_voidptr(&$1), $descriptor, 0);
}

/* Value */
%typemap(varout, noblock=1) SWIGTYPE {
  $result = SWIG_NewPointerObj(SWIG_as_voidptr(&$1), $&descriptor, 0);
}

/* ------------------------------------------------------------
 * --- Typechecking rules ---
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_POINTER,noblock=1) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  void *ptr = 0;
  $1 = (SWIG_ConvertPtr($input, &ptr, $descriptor, 0) == SWIG_OK);
}

%typecheck(SWIG_TYPECHECK_POINTER,noblock=1) SWIGTYPE & {
  void *ptr = 0;
  $1 = (SWIG_ConvertPtr($input, &ptr, $descriptor, 0) == SWIG_OK) && (ptr != 0);
}

%typecheck(SWIG_TYPECHECK_POINTER,noblock=1) SWIGTYPE {
  void *ptr = 0;
  $1 = (SWIG_ConvertPtr($input, &ptr, $&descriptor, 0) == SWIG_OK) && (ptr != 0);
}

/* ------------------------------------------------------------
 * --- CLASS::* typemaps --- 
 * ------------------------------------------------------------ */

%typemap(in,noblock=1) SWIGTYPE (CLASS::*) {  
  if (SWIG_ConvertMember($input, SWIG_as_voidptr(&$1), sizeof($type),$descriptor, 0) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum); 
  }
}

%typemap(out,noblock=1) SWIGTYPE (CLASS::*) {
  SWIG_set_result(SWIG_NewMemberObj(SWIG_as_voidptr(&$1), sizeof($type), $descriptor));
}

%typemap(varin,noblock=1) SWIGTYPE (CLASS::*) {
  if (SWIG_ConvertMember($input,SWIG_as_voidptr(&$1), sizeof($type), $descriptor,0) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name"); 
  }
}

%typemap(varout,noblock=1) SWIGTYPE (CLASS::*) {  
  $result = SWIG_NewMemberObj(SWIG_as_voidptr(&$1), sizeof($type), $descriptor);
}


/* ------------------------------------------------------------
 * --- function ptr typemaps --- 
 * ------------------------------------------------------------ */

/*
  ISO C++ doesn't allow direct casting of a function ptr to a object
  ptr. So, maybe the ptr sizes are not the same, and we need to take
  some providences.
 */
%typemap(in, noblock=1) SWIGTYPE ((*)(ANY)) {
  if (SWIG_ConvertFunctionPtr($input, SWIG_as_voidptrptr(&$1), $descriptor, 0) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum); 
  }
}

%typemap(out, noblock=1) SWIGTYPE ((*)(ANY)) {
  SWIG_set_result(SWIG_NewFunctionPtrObj((void *)($1), $descriptor));
}


/* -----------------------------------------------------------------------------
 * --- Director typemaps --- *  
 * ----------------------------------------------------------------------------- */


#ifdef SWIG_DIRECTOR_TYPEMAPS

/* directorin */

%typemap(directorin,noblock=1) SWIGTYPE* {
  $input = SWIG_NewPointerObj(SWIG_as_voidptr($1_name), $descriptor, 0);
}

%typemap(directorin,noblock=1) SWIGTYPE {
  $input = SWIG_NewPointerObj(SWIG_as_voidptr(&$1_name), $&descriptor, 0);
}

%typemap(directorin,noblock=1) SWIGTYPE& {
  $input = SWIG_NewPointerObj(SWIG_as_voidptr(&$1_name), $descriptor, 0);
}

/* directorout */

%typemap(directorout,noblock=1) SWIGTYPE (void * argp) {
  if (SWIG_ConvertPtr($input,&argp,$&descriptor, 0) != SWIG_OK) {
    SWIG_dout_fail(SWIG_TypeError,"$type");
  }
  $result = *(SWIG_reinterpret_cast(argp, $&ltype));
}
%typemap(directorout,noblock=1) SWIGTYPE *(void *argp), SWIGTYPE [](void *argp) {
  if (SWIG_ConvertPtr($input, &argp, $descriptor, 0) != SWIG_OK) {
    SWIG_dout_fail(SWIG_TypeError,"$type");
  }
  $result = SWIG_reinterpret_cast(argp, $ltype);
}
%typemap(directorout,noblock=1) SWIGTYPE &(void *argp) {
  if (SWIG_ConvertPtr($input, &argp, $descriptor, $disown ) != SWIG_OK) {
    SWIG_dout_fail(SWIG_TypeError,"$type");
  }
  if (!argp) { SWIG_dout_nullref("$type"); }
  $result = SWIG_reinterpret_cast(argp, $ltype);
}
#endif /* SWIG_DIRECTOR_TYPEMAPS */


/* ------------------------------------------------------------
 * --- Constants ---
 * ------------------------------------------------------------ */

%typemap(constcode,noblock=1) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []{ 
  SWIG_set_constant("$symname", SWIG_NewPointerObj(SWIG_as_voidptr($value),$descriptor,0));
}

%typemap(constcode,noblock=1) SWIGTYPE (CLASS::*) {
  SWIG_set_constant("$symname", SWIG_NewPackedObj(SWIG_as_voidptr(&$value), sizeof($type), $descriptor, 0));
}

%typemap(constcode,noblock=1) SWIGTYPE {
  SWIG_set_constant("$symname", SWIG_NewPointerObj(SWIG_as_voidptr(&$value),$&descriptor,0));
}

%typemap(constcode,noblock=1) SWIGTYPE ((*)(ANY)){
  if (sizeof($type) == sizeof(void *)) {
    SWIG_set_constant("$symname", SWIG_NewPointerObj((void *)$value, $descriptor, 0));
  } else {
    SWIG_set_constant("$symname", SWIG_NewPackedObj((void *)$value, sizeof($type), $descriptor, 0));
  }
}


/* ------------------------------------------------------------
 * --- Exception handling ---
 * ------------------------------------------------------------ */

%typemap(throws,noblock=1) SWIGTYPE {
  SWIG_exception_obj($&descriptor, "$type", SWIG_NewPointerObj(SWIG_new_copy($1, $ltype),$&descriptor,SWIG_POINTER_OWN));
}

%typemap(throws,noblock=1) SWIGTYPE * {
  SWIG_exception_obj($descriptor, "$type", SWIG_NewPointerObj(SWIG_as_voidptr($1),$descriptor,0));
}

%typemap(throws,noblock=1) SWIGTYPE [ANY] {
  SWIG_exception_obj($descriptor, "$type", SWIG_NewPointerObj(SWIG_as_voidptr($1),$descriptor,0));
}

%typemap(throws,noblock=1) SWIGTYPE & {
  SWIG_exception_obj($descriptor, "$type", SWIG_NewPointerObj(SWIG_as_voidptr(&$1),$descriptor,0));
}

/* ------------------------------------------------------------
 * --- Special typemaps ---
 * ------------------------------------------------------------ */

/* VARARGS_SENTINEL typemap. Used by the %varargs directive. */

%typemap(in,numinputs=0) SWIGTYPE *VARARGS_SENTINEL, SWIGTYPE VARARGS_SENTINEL "";


/* DISOWN typemap */

%typemap(in, noblock=1) SWIGTYPE *DISOWN {
  if (SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&$1), $descriptor, SWIG_POINTER_DISOWN) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError,"$type", $argnum);
  }
}

%typemap(varin,noblock=1) SWIGTYPE *DISOWN {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, $descriptor, SWIG_POINTER_DISOWN) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  }
  $1 = ($ltype) temp;
}

/* DYNAMIC typemap */

%typemap(out,noblock=1) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
  SWIG_set_result(SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIG_TypeDynamicCast($descriptor, SWIG_as_voidptrptr(&$1)), $owner));
}

/* INSTANCE typemap */

%typemap(out,noblock=1) SWIGTYPE INSTANCE {
  SWIG_set_result(SWIG_NewInstanceObj(SWIG_new_copy($1, $1_ltype), $&1_descriptor,SWIG_POINTER_OWN));
}

%typemap(out,noblock=1) SWIGTYPE *INSTANCE, SWIGTYPE &INSTANCE, SWIGTYPE INSTANCE[] {
  SWIG_set_result(SWIG_NewInstanceObj(SWIG_as_voidptr($1), $1_descriptor, $owner));
}

%typemap(varout,noblock=1) SWIGTYPE *INSTANCE, SWIGTYPE INSTANCE[] {
  $result = SWIG_NewInstanceObj(SWIG_as_voidptr($1), $1_descriptor, 0);
}

%typemap(varout,noblock=1) SWIGTYPE &INSTANCE {
  $result = SWIG_NewInstanceObj(SWIG_as_voidptr(&$1), $1_descriptor, 0);
}

%typemap(varout,noblock=1) SWIGTYPE INSTANCE {
  $result = SWIG_NewInstanceObj(SWIG_as_voidptr(&$1), $&1_descriptor, 0);
}
