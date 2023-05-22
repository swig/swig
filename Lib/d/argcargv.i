/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%typemap(ctype) (int ARGC, char **ARGV) "SWIG_c_dstring_array"
%typemap(imtype) (int ARGC, char **ARGV) "string[]"
%typemap(dtype) (int ARGC, char **ARGV) "string[]"

%typemap(in, canthrow=1) (int ARGC, char **ARGV) {
  $1_ltype i, len;
  len = $input.len;
  $2 = ($2_ltype) malloc((len+1)*sizeof($*2_ltype));
  if ($2 == SWIG_NULLPTR) {
    SWIG_DSetPendingException(SWIG_DException, "memory allocation failed");
    return $null;
  }
  $1 = len;
  for (i = 0; i < len; i++) {
    $2[i] = $input.array[i].str;
  }
  $2[i] = SWIG_NULLPTR;
}

%typemap(freearg) (int ARGC, char **ARGV) {
  free((void *)$2);
}
