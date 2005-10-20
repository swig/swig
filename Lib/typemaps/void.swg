/* ------------------------------------------------------------
 * Void * -  Accepts any kind of pointer
 * ------------------------------------------------------------ */

/* in */

%typemap(in,noblock=1) void * {
  if (SWIG_ConvertPtr($input,SWIG_as_voidptrptr(&$1), 0, $disown) != SWIG_OK) { 
    SWIG_arg_fail(SWIG_TypeError, "$type", $argnum); 
  }
}

%typemap(freearg) void * "";

%typemap(in,noblock=1) void * const& ($*ltype temp) {
  if (SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&temp), 0, $disown) != SWIG_OK) { 
    SWIG_arg_fail(SWIG_TypeError, "Stype", $argnum); 
  }
  $1 =  &temp;
}


/* out */

%typemap(out,noblock=1) void {
  SWIG_set_result(SWIG_VoidObject());
}

/* varin */

%typemap(varin,noblock=1) void * {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, 0, SWIG_POINTER_DISOWN) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  }
  $1 = ($1_ltype) temp;
}

/* typecheck */

%typecheck(SWIG_TYPECHECK_VOIDPTR, noblock=1) void *
{
  void *ptr = 0;
  $1 = (SWIG_ConvertPtr($input, &ptr, 0, 0) == SWIG_OK);
}

#ifdef SWIG_DIRECTOR_TYPEMAPS

/* directorout */

%typemap(directorout,noblock=1) void * (void *argp) {
  if (SWIG_ConvertPtr($input, &argp, 0, 0) != SWIG_OK) {
    SWIG_dout_fail(SWIG_TypeError,"$type");
  }
  $result = SWIG_reinterpret_cast(argp, $ltype);
}


#endif /* SWIG_DIRECTOR_TYPEMAPS */

