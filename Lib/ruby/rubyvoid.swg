/* ------------------------------------------------------------
 * Void * -  Accepts any kind of pointer
 * ------------------------------------------------------------ */

/* in */

%typemap(in) void *
        "SWIG_ConvertPtr($input, (void **) &$1, 0, SWIG_POINTER_EXCEPTION|$disown);";

/* out */

%typemap(out) void "$result = Qnil;";

/* varin */

%typemap(varin) void *
        "SWIG_ConvertPtr($input, (void **) &$1, 0, 1);";

/* varout */

%typemap(varout) void "$result = Qnil;";

/* directorout */

%typemap(directorout) void * "if ((SWIG_ConvertPtr($input,(void **) &$result, 0, SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";

/* typecheck */

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  $1 = (NIL_P($input) || (TYPE($input) == T_DATA && SWIG_ConvertPtr($input, &ptr, 0, 0) != -1)) ? 1 : 0;
}

