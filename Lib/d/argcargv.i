/* ------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------ */

%typemap(ctype) (int ARGC, char **ARGV) "c_dstring_array"
%typemap(imtype) (int ARGC, char **ARGV) "string[]"
%typemap(dtype) (int ARGC, char **ARGV) "string[]"

%typemap(in, canthrow=1) (int ARGC, char **ARGV) {
  if ($input.array == SWIG_NULLPTR || $input.len <= 0) {
    $1 = 0;
    $2 = ($2_ltype) malloc(sizeof($*2_ltype));
    $2[0] = SWIG_NULLPTR;
  } else {
    $1_ltype i;
    $1 = $input.len;
    $2 = ($2_ltype) malloc(($1+1)*sizeof($*2_ltype));
    if ($2 == SWIG_NULLPTR) {
      SWIG_DSetPendingException(SWIG_DException, "memory allocation failed");
      return $null;
    }
    for (i = 0; i < $1; i++) {
      $2[i] = $input.array[i].str;
    }
    $2[i] = SWIG_NULLPTR;
  }
}

%typemap(freearg) (int ARGC, char **ARGV) {
  free((void *)$2);
}
