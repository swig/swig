/* ------------------------------------------------------------
 * Void * -  Accepts any kind of pointer
 * ------------------------------------------------------------ */

/* in */

%typemap(in,noblock=1) void * {
  if (SWIG_ConvertPtr($input,%as_voidptrptr(&$1), 0, $disown) != SWIG_OK) { 
    %argument_fail(SWIG_TypeError, "$type", $argnum); 
  }
}
%typemap(freearg) void * "";

%typemap(in,noblock=1) void * const& ($*ltype temp) {
  if (SWIG_ConvertPtr($input, %as_voidptrptr(&temp), 0, $disown) != SWIG_OK) { 
    %argument_fail(SWIG_TypeError, "Stype", $argnum); 
  }
  $1 =  &temp;
}
%typemap(freearg) void * const& "";


/* out */

#if defined(VOID_Object)
%typemap(out,noblock=1) void { $result = VOID_Object; }
#else
%typemap(out,noblock=1) void {}
#endif

/* varin */

%typemap(varin,noblock=1) void * {
  void *temp = 0;
  if (SWIG_ConvertPtr($input, &temp, 0, SWIG_POINTER_DISOWN) != SWIG_OK) {
    %variable_fail(SWIG_TypeError, "$type", "$name");
  }
  $1 = ($1_ltype) temp;
}

/* typecheck */

%typecheck(SWIG_TYPECHECK_VOIDPTR, noblock=1) void *
{
  void *ptr = 0;
  $1 = (SWIG_ConvertPtr($input, &ptr, 0, 0) == SWIG_OK);
}

#if defined(SWIG_DIRECTOR_TYPEMAPS)

/* directorin */

%typemap(directorin,noblock=1) void *, void const*, void *const, void const *const, 
  void const *&, void *const &, void const *const & {
  $input = SWIG_NewPointerObj(%as_voidptr($1_name), $descriptor, %newpointer_flags);
}

/* directorout */

%typemap(directorout,noblock=1) void * (void *argp) {
  if (SWIG_ConvertPtr($input, &argp, 0, 0) != SWIG_OK) {
    %dirout_fail(SWIG_TypeError,"$type");
  }
  $result = %reinterpret_cast(argp, $ltype);
}

%typemap(directorout,noblock=1) void * const& ($*ltype temp) {
  if (SWIG_ConvertPtr($input, %as_voidptrptr(&temp), 0, $disown) != SWIG_OK) { 
    %dirout_fail(SWIG_TypeError,"$type");
  }
  $result =  &temp;
}



#endif /* SWIG_DIRECTOR_TYPEMAPS */

