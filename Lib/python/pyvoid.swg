/* ------------------------------------------------------------
 * Void * -  Accepts any kind of pointer
 * ------------------------------------------------------------ */

/* in */

%typemap(in) void * 
  "if ((SWIG_ConvertPtr($input,&$1,0,SWIG_POINTER_EXCEPTION | $disown)) == -1) SWIG_fail;";


/* out */

%typemap(out) void "Py_INCREF(Py_None); $result = Py_None;";

/* varin */

%typemap(varin) void * {
  void * temp;
  if ((SWIG_ConvertPtr($input, &temp, 0,
		       SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN)) == -1) {
    PyErr_SetString(PyExc_TypeError, "C variable '$name ($1_ltype)'");
    return 1;
  }
  $1 = ($1_ltype) temp;
}

/* varout */

%typemap(varout) void "Py_INCREF(Py_None); $result = Py_None;";

/* directorout */

%typemap(directorout) void * 
  "if ((SWIG_ConvertPtr($input,(void **)(&$result),
	 	       0, SWIG_POINTER_EXCEPTION | $disown )) == -1)
     throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";


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
