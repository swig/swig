/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%typemap(in) (int ARGC, char **ARGV) {
  Tcl_Size i, nitems;
  Tcl_Obj **listobjv;
  if (Tcl_ListObjGetElements(interp, $input, &nitems, &listobjv) == TCL_ERROR) {
     SWIG_exception_fail(SWIG_ValueError, "in method '$symname', Expecting list of argv");
     goto fail;
  }
  $1 = ($1_ltype) nitems;
  $2 = (char **) malloc((nitems+1)*sizeof(char *));
  for (i = 0; i < nitems; i++) {
    $2[i] = Tcl_GetString(listobjv[i]);
  }
  $2[i] = NULL;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  Tcl_Size len;
  $1 = Tcl_ListObjLength(interp, $input, &len) == TCL_OK;
}

%typemap(freearg) (int ARGC, char **ARGV) {
  free((void *)$2);
}
