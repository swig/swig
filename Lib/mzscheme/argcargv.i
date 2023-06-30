/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%typemap(in) (int ARGC, char **ARGV) {
  $1_ltype i, len;
  Scheme_Object **elems;
  SWIG_contract_assert($input != (Scheme_Object *)NULL &&
                       $input != scheme_null &&
                       SCHEME_TYPE($input) == scheme_vector_type, "null array");
  len = SCHEME_VEC_SIZE($input);
  $1 = len;
  $2 = ($2_ltype) SWIG_MzScheme_Malloc((size_t)(len+1)*sizeof($*2_ltype), FUNC_NAME);
  elems = SCHEME_VEC_ELS($input);
  for (i = 0; i < len; i++) {
    SWIG_contract_assert(SCHEME_TYPE(elems[i]) == scheme_char_string_type,
                         "elements in array must be strings");
    $2[i] = ($*2_ltype)SCHEME_STR_VAL(elems[i]);
  }
  $2[i] = NULL;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  if ($input != (Scheme_Object *)NULL && $input != scheme_null &&
      SCHEME_TYPE($input) == scheme_vector_type) {
    size_t len = SCHEME_VEC_SIZE($input);
    size_t i;
    Scheme_Object **elems = SCHEME_VEC_ELS($input);
    for (i = 0; i < len; i++) {
      if (SCHEME_TYPE(elems[i]) != scheme_char_string_type) {
        break;
      }
    }
    /* All elements are strings! */
    $1 = (i == len);
  }
}

%typemap(freearg) (int ARGC, char **ARGV) {
  SWIG_free((void *)$2);
}
