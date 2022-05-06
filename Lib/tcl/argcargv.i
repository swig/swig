/* ------------------------------------------------------------
 * --- Argc & Argv ---
 * ------------------------------------------------------------ */

%typemap(default) (int ARGC, char **ARGV) {
  $1 = 0; $2 = NULL;
}

%typemap(in) (int ARGC, char **ARGV) {
  int i, nitems;
  Tcl_Obj **listobjv;
  if (Tcl_ListObjGetElements(interp, $input, &nitems, &listobjv) == TCL_ERROR) {
     SWIG_exception_fail(SWIG_ValueError, "in method '$symname', Expecting list of argv");
     goto fail;
  }
  $1 = ($1_ltype) nitems;
  $2 = (char **) malloc((nitems+1)*sizeof(char *));
  for (i = 0; i < nitems; i++) {
    $2[i] = Tcl_GetStringFromObj(listobjv[i], NULL);
  }
  $2[i] = NULL;
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2 != NULL) {
    free((void *)$2);
  }
}
