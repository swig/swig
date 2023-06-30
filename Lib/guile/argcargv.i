/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%typemap(in) (int ARGC, char **ARGV) {
  $1_ltype i, len;
  SWIG_contract_assert($input != (SCM)0 &&
                       !scm_is_null($input) &&
                       scm_is_array($input),
                       "you must pass array of strings");
  len = scm_c_array_length($input);
  $1 = len;
  $2 = ($2_ltype) malloc((len+1)*sizeof($*2_ltype));
  if ($2 == NULL) {
    scm_misc_error(FUNC_NAME, "fail allocating memory for array", SCM_EOL);
  }
  for (i = 0; i < len; i++) {
    SCM args = scm_list_1(scm_from_long(i));
    SCM str = scm_array_ref($input, args);
    SWIG_contract_assert(scm_is_string(str), "elements in array must be strings");
    $2[i] = ($*2_ltype)SWIG_scm2str(str);
  }
  $2[i] = NULL;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  if ($input != (SCM)0 && !scm_is_null($input) && scm_is_array($input)) {
    size_t len = scm_c_array_length($input);
    size_t i;
    for(i = 0; i < len; i++) {
      SCM args = scm_list_1(scm_from_long(i));
      SCM str = scm_array_ref($input, args);
      if (!scm_is_string(str)) {
        break;
      }
    }
    /* All elements are strings! */
    $1 = (i == len);
  }
}

%typemap(freearg) (int ARGC, char **ARGV) {
  free((void *)$2);
}
