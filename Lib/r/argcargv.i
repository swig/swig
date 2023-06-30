/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

/* Preserve string vector as is */
%typemap(scoercein) (int ARGC, char **ARGV) ""
/* Verify we pass the proper string vector */
%typemap(scheck) (int ARGC, char **ARGV) %{
  assert(is.null($input) || (is.vector($input) && is.character($input)))
%}
/* Check argument is null or a string vector for dispatcher */
%typemap(rtypecheck) (int ARGC, char **ARGV) %{
  is.null($arg) || (is.vector($arg) && is.character($arg))
%}
%typemap(in) (int ARGC, char **ARGV) {
  $1_ltype i;
  SEXP *pstr;
  if ($input == R_NilValue) {
    /* Empty array */
    $1 = 0;
  } else if (!Rf_isVectorAtomic($input) || TYPEOF($input) != STRSXP) {
    SWIG_exception_fail(SWIG_RuntimeError, "Wrong array type.");
  } else {
    $1 = Rf_length($input);
    pstr = CHARACTER_POINTER($input);
  }
  $2 = ($2_ltype) malloc(($1+1)*sizeof($*2_ltype));
  if ($2 == SWIG_NULLPTR) {
    SWIG_exception_fail(SWIG_MemoryError, "Memory allocation failed.");
  }
  for (i = 0; i < $1; i++) {
    $2[i] = ($*2_ltype)STRING_VALUE(pstr[i]);
  }
  $2[i] = SWIG_NULLPTR;
}
%typemap(freearg,noblock=1) (int ARGC, char **ARGV) {
  free((void *)$2);
}
