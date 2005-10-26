/* -----------------------------------------------------------------------------
 * --- Input arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers and arrays */
%typemap(in, noblock=1) SWIGTYPE * (void *argp), SWIGTYPE [] (void *argp) {
  if (SWIG_ConvertPtr($input, &argp,$descriptor, $disown | %convertptr_flags) != SWIG_OK) { 
    %argument_fail(SWIG_TypeError, "$type", $argnum); 
  }
  $1 = %reinterpret_cast(argp, $ltype);
}

%typemap(freearg) SWIGTYPE *, SWIGTYPE [] "";

%typemap(in, noblock=1) SWIGTYPE* const&  (void *argp, $*ltype temp) {
  if (SWIG_ConvertPtr($input, &argp, $*descriptor, $disown | %convertptr_flags) != SWIG_OK) {
    %argument_fail(SWIG_TypeError, "$*ltype", $argnum); 
  }
  temp = %reinterpret_cast(argp, $*ltype);
  $1 = &temp;
}

/* Reference */
%typemap(in, noblock=1) SWIGTYPE & (void *argp) {  
  if (SWIG_ConvertPtr($input, &argp, $descriptor, %convertptr_flags) != SWIG_OK) {
    %argument_fail(SWIG_TypeError, "$type", $argnum); 
  }
  if (!argp) { %argument_nullref("$type", $argnum); }
  $1 = %reinterpret_cast(argp, $ltype);
}

/* By value */
%typemap(in,noblock=1) SWIGTYPE (void *argp) {
  if (SWIG_ConvertPtr($input, &argp, $&descriptor, %convertptr_flags) != SWIG_OK) {
    %argument_fail(SWIG_TypeError, "$type", $argnum); 
  }  
  if (!argp) { %argument_nullref("$type", $argnum); }
  $1 = *(%reinterpret_cast(argp, $&ltype));
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers, references */
%typemap(out,noblock=1) SWIGTYPE *, SWIGTYPE &, SWIGTYPE[] {
  %set_output(SWIG_NewPointerObj(%as_voidptr($1), $descriptor, $owner | %newpointer_flags));
}

%typemap(out, noblock=1) SWIGTYPE* const& {
  %set_output(SWIG_NewPointerObj(%as_voidptr(*$1), $*descriptor, $owner | %newpointer_flags));
}

/* Return by value */
%typemap(out, noblock=1) SWIGTYPE {
  %set_output(SWIG_NewPointerObj(%new_copy($1, $ltype), $&descriptor, SWIG_POINTER_OWN | %newpointer_flags));
}

/* -----------------------------------------------------------------------------
 * --- Variable input --- 
 * ----------------------------------------------------------------------------- */

/* memberin/globalin/varin, for fix arrays. */

%typemap(memberin) SWIGTYPE [ANY] {
  $basetype *inp = %static_cast($input, $basetype *);
  if (inp) {
    $basetype *dest = %static_cast($1, $basetype *);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    %variable_nullref("$type","$name");
  }
}

%typemap(globalin) SWIGTYPE [ANY] {
  $basetype *inp = %static_cast($input, $basetype *);
  if (inp) {
    $basetype *dest = %static_cast($1, $basetype *);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    %variable_nullref("$type","$name");
  }
}

%typemap(varin,noblock=1) SWIGTYPE [ANY] {
  $basetype *inp = 0;
  if (SWIG_ConvertPtr($input, %as_voidptrptr(&inp), $descriptor, %convertptr_flags) != SWIG_OK) {
    %variable_fail(SWIG_TypeError, "$type", "$name");
  } else if (inp) {
    size_t ii = 0;
    $basetype *dest = %static_cast($1, $basetype *);
    for (; ii < $dim0; ++ii) dest[ii] = inp[ii];
  } else {
    %variable_nullref("$type", "$name");
  }
}

/* memberin/globalin/varin, for fix double arrays. */

%typemap(memberin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = %static_cast($input, $basetype (*)[$dim1]);
  if (inp) {
    $basetype (*dest)[$dim1] = %static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	%variable_nullref("$type","$name");
      }
    }
  } else {
    %variable_nullref("$type","$name");
  }
}

%typemap(globalin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = %static_cast($input, $basetype (*)[$dim1]);
  if (inp) {
    $basetype (*dest)[$dim1] = %static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	%variable_nullref("$type","$name");
      }
    }
  } else {
    %variable_nullref("$type","$name");
  }
}

%typemap(varin,noblock=1) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$dim1] = 0;
  if (SWIG_ConvertPtr($input, %as_voidptrptr(&inp), $descriptor, %convertptr_flags) != SWIG_OK) {
    %variable_fail(SWIG_TypeError, "$type", "$name");
  } else if (inp) {
    $basetype (*dest)[$dim1] = %static_cast($1, $basetype (*)[$dim1]);
    size_t ii = 0;
    for (; ii < $dim0; ++ii) {
      $basetype *ip = inp[ii];
      if (ip) {
	$basetype *dp = dest[ii];
	size_t jj = 0;
	for (; jj < $dim1; ++jj) dp[jj] = ip[jj];
      } else {
	%variable_nullref("$type", "$name");
      }
    }
  } else {
    %variable_nullref("$type", "$name");
  }
}

/* Pointers, references, and variable size arrays */

%typemap(varin,noblock=1) SWIGTYPE * {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, $descriptor, %convertptr_flags) != SWIG_OK) {
    %variable_fail(SWIG_TypeError, "$type", "$name");
  }
  $1 = ($ltype) temp;
}

%typemap(varin,noblock=1,warning="462:Unable to set dimensionless array variable") SWIGTYPE []
{
  %variable_fail(SWIG_AttributeError, "$type", "read-only $name");
}

%typemap(varin,noblock=1) SWIGTYPE & {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, $descriptor, %convertptr_flags) != SWIG_OK) {
    %variable_fail(SWIG_TypeError, "$type", "$name");
  }
  if (!temp) {
    %variable_nullref("$type", "$name");
  }
  $1 = *(%reinterpret_cast(temp, $ltype));
}

%typemap(varin,noblock=1) SWIGTYPE {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, $&descriptor, %convertptr_flags) != SWIG_OK) {
    %variable_fail(SWIG_TypeError, "$type", "$name");
  }
  if (!temp) {
    %variable_nullref("$type", "$name");
  }
  $1 = *(%reinterpret_cast(temp, $&type));
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */

/* Pointers and arrays */
%typemap(varout, noblock=1) SWIGTYPE * {
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr($1), $descriptor, %newpointer_flags));
}

%typemap(varout, noblock=1) SWIGTYPE [] {
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr($1), $descriptor, %newpointer_flags));
}

/* References */
%typemap(varout, noblock=1) SWIGTYPE & {
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(&$1), $descriptor, %newpointer_flags));
}

/* Value */
%typemap(varout, noblock=1) SWIGTYPE {
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(&$1), $&descriptor, %newpointer_flags));
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


/* -----------------------------------------------------------------------------
 * --- Director typemaps --- *  
 * ----------------------------------------------------------------------------- */


#if defined(SWIG_DIRECTOR_TYPEMAPS)

/* directorin */

%typemap(directorin,noblock=1) SWIGTYPE* {
  $input = SWIG_NewPointerObj(%as_voidptr($1_name), $descriptor, %newpointer_flags);
}

%typemap(directorin,noblock=1) SWIGTYPE {
  $input = SWIG_NewPointerObj(%as_voidptr(&$1_name), $&descriptor, %newpointer_flags);
}

%typemap(directorin,noblock=1) SWIGTYPE& {
  $input = SWIG_NewPointerObj(%as_voidptr(&$1_name), $descriptor, %newpointer_flags);
}

/* directorout */

%typemap(directorout,noblock=1) SWIGTYPE (void * argp) {
  if (SWIG_ConvertPtr($input,&argp,$&descriptor, %convertptr_flags) != SWIG_OK) {
    %dirout_fail(SWIG_TypeError,"$type");
  }
  $result = *(%reinterpret_cast(argp, $&ltype));
}
%typemap(directorout,noblock=1) SWIGTYPE *(void *argp), SWIGTYPE [](void *argp) {
  if (SWIG_ConvertPtr($input, &argp, $descriptor, %convertptr_flags) != SWIG_OK) {
    %dirout_fail(SWIG_TypeError,"$type");
  }
  $result = %reinterpret_cast(argp, $ltype);
}
%typemap(directorout,noblock=1) SWIGTYPE &(void *argp) {
  if (SWIG_ConvertPtr($input, &argp, $descriptor, $disown | %convertptr_flags) != SWIG_OK) {
    %dirout_fail(SWIG_TypeError,"$type");
  }
  if (!argp) { %dirout_nullref("$type"); }
  $result = %reinterpret_cast(argp, $ltype);
}
#endif /* SWIG_DIRECTOR_TYPEMAPS */


/* ------------------------------------------------------------
 * --- Constants ---
 * ------------------------------------------------------------ */

%typemap(constcode,noblock=1) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []{ 
  %set_constant("$symname", SWIG_NewPointerObj(%as_voidptr($value),$descriptor,%newpointer_flags));
}

%typemap(constcode,noblock=1) SWIGTYPE {
  %set_constant("$symname", SWIG_NewPointerObj(%as_voidptr(&$value),$&descriptor,%newpointer_flags));
}

/* ------------------------------------------------------------
 * --- Exception handling ---
 * ------------------------------------------------------------ */

%typemap(throws,noblock=1) SWIGTYPE {
  %raise(SWIG_NewPointerObj(%new_copy($1, $ltype),$&descriptor,SWIG_POINTER_OWN), "$type", $&descriptor);
}

%typemap(throws,noblock=1) SWIGTYPE * {
  %raise(SWIG_NewPointerObj(%as_voidptr($1),$descriptor,0), "$type", $descriptor);
}

%typemap(throws,noblock=1) SWIGTYPE [ANY] {
  %raise(SWIG_NewPointerObj(%as_voidptr($1),$descriptor,0), "$type", $descriptor);
}

%typemap(throws,noblock=1) SWIGTYPE & {
  %raise(SWIG_NewPointerObj(%as_voidptr(&$1),$descriptor,0), "$type", $descriptor);
}

/* ------------------------------------------------------------
 * --- CLASS::* typemaps --- 
 * ------------------------------------------------------------ */

%typemap(in,noblock=1) SWIGTYPE (CLASS::*) {  
  if (SWIG_ConvertMember($input, %as_voidptr(&$1), sizeof($type),$descriptor) != SWIG_OK) {
    %argument_fail(SWIG_TypeError,"$type",$argnum); 
  }
}

%typemap(out,noblock=1) SWIGTYPE (CLASS::*) {
  %set_output(SWIG_NewMemberObj(%as_voidptr(&$1), sizeof($type), $descriptor));
}

%typemap(varin,noblock=1) SWIGTYPE (CLASS::*) {
  if (SWIG_ConvertMember($input,%as_voidptr(&$1), sizeof($type), $descriptor) != SWIG_OK) {
    %variable_fail(SWIG_TypeError, "$type", "$name"); 
  }
}

%typemap(varout,noblock=1) SWIGTYPE (CLASS::*) {  
  %set_varoutput(SWIG_NewMemberObj(%as_voidptr(&$1), sizeof($type), $descriptor));
}

%typemap(constcode,noblock=1) SWIGTYPE (CLASS::*) {
  %set_constant("$symname", SWIG_NewMemberObj(%as_voidptr(&$value), sizeof($type), $descriptor));
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
  if (SWIG_ConvertFunctionPtr($input, %as_voidptrptr(&$1), $descriptor) != SWIG_OK) {
    %argument_fail(SWIG_TypeError,"$type",$argnum); 
  }
}

%typemap(out, noblock=1) SWIGTYPE ((*)(ANY)) {
  %set_output(SWIG_NewFunctionPtrObj((void *)($1), $descriptor));
}


%typemap(constcode, noblock=1) SWIGTYPE ((*)(ANY)){
  %set_constant("$symname", SWIG_NewFunctionPtrObj((void *)$value, $descriptor));
}

/* ------------------------------------------------------------
 * --- Special typemaps ---
 * ------------------------------------------------------------ */

/* VARARGS_SENTINEL typemap. Used by the %varargs directive. */

%typemap(in,numinputs=0) SWIGTYPE *VARARGS_SENTINEL, SWIGTYPE VARARGS_SENTINEL "";


/* DISOWN typemap */

%typemap(in, noblock=1) SWIGTYPE *DISOWN {
  if (SWIG_ConvertPtr($input, %as_voidptrptr(&$1), $descriptor, SWIG_POINTER_DISOWN | %convertptr_flags) != SWIG_OK) {
    %argument_fail(SWIG_TypeError,"$type", $argnum);
  }
}

%typemap(varin,noblock=1) SWIGTYPE *DISOWN {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, $descriptor, SWIG_POINTER_DISOWN | %convertptr_flags) != SWIG_OK) {
    %variable_fail(SWIG_TypeError, "$type", "$name");
  }
  $1 = ($ltype) temp;
}

/* DYNAMIC typemap */

%typemap(out,noblock=1) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
  %set_output(SWIG_NewPointerObj(%as_voidptr($1), SWIG_TypeDynamicCast($descriptor, %as_voidptrptr(&$1)), $owner | %newpointer_flags));
}

/* INSTANCE typemap */

%typemap(out,noblock=1) SWIGTYPE INSTANCE {
  %set_output(SWIG_NewInstanceObj(%new_copy($1, $1_ltype), $&1_descriptor, SWIG_POINTER_OWN | %newinstance_flags));
}

%typemap(out,noblock=1) SWIGTYPE *INSTANCE, SWIGTYPE &INSTANCE, SWIGTYPE INSTANCE[] {
  %set_output(SWIG_NewInstanceObj(%as_voidptr($1), $1_descriptor, $owner | %newinstance_flags));
}

%typemap(varout,noblock=1) SWIGTYPE *INSTANCE, SWIGTYPE INSTANCE[] {
  %set_varoutput(SWIG_NewInstanceObj(%as_voidptr($1), $1_descriptor, %newinstance_flags));
}

%typemap(varout,noblock=1) SWIGTYPE &INSTANCE {
  %set_varoutput(SWIG_NewInstanceObj(%as_voidptr(&$1), $1_descriptor, %newinstance_flags));
}

%typemap(varout,noblock=1) SWIGTYPE INSTANCE {
  %set_varoutput(SWIG_NewInstanceObj(%as_voidptr(&$1), $&1_descriptor, %newinstance_flags));
}
