/* ------------------------------------------------------------
 * Void * -  Accepts any kind of pointer
 * ------------------------------------------------------------ */

/* in */

%typemap(in) void * {
  if ((SWIG_ConvertPtr($input,SWIG_reinterpret_cast(&$1,void **),0,SWIG_POINTER_EXCEPTION|$disown))== -1) { 
    SWIG_arg_fail($argnum);SWIG_fail;
  }
}

%typemap(in) void * const& ($*ltype temp) {
  SWIG_ConvertPtr($input,(void **)&temp,0,SWIG_POINTER_EXCEPTION|$disown);
  if (SWIG_arg_fail($argnum)) SWIG_fail;
  $1 = &temp;
}


/* out */

%typemap(out) void "Py_INCREF(Py_None); $result = Py_None;";

/* varin */

%typemap(varin) void * {
  void * temp;
  if ((SWIG_ConvertPtr($input, SWIG_static_cast(&temp,void **), 0,
		       SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN)) == -1) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

/* varout */

%typemap(varout) void "Py_INCREF(Py_None); $result = Py_None;";

/* directorout */

%typemap(directorout) void * {
  if (!$input || (SWIG_ConvertPtr($input,(void **)(&$result),
	 	       0, SWIG_POINTER_EXCEPTION | $disown )) == -1)
    Swig::DirectorTypeMismatchException::raise("Pointer conversion failed.");
}



/* typecheck */

%typecheck(SWIG_TYPECHECK_VOIDPTR) void *
{
  void *ptr;
  if (SWIG_ConvertPtr($input, &ptr, 0, 0) == -1) {
    $1 = 0;
    PyErr_Clear();
  } else {
    $1 = 1;
  }
}
