/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%typemap(in) (int ARGC, char **ARGV) {
  if ($input.is_scalar_type()) {
    $1 = 0; $2 = NULL;
    %argument_fail(SWIG_TypeError, "'int ARGC, char **ARGV' is not a list", $symname, $argnum);
  }
  octave_value_list list = $input.list_value();
  int i, len = list.length();
  $1 = ($1_ltype) len;
  $2 = (char **) malloc((len+1)*sizeof(char *));
  for (i = 0; i < len; i++) {
    if (!list(i).is_string()) {
      $1 = 0;
      %argument_fail(SWIG_TypeError, "'int ARGC, char **ARGV' use a non-string", $symname, $argnum);
    }
    const std::string & s = list(i).string_value();
    size_t slen = s.size() + 1;
    char * p = (char*)malloc(slen);
    $2[i] = p;
    memcpy(p, s.c_str(), slen);
  }
  $2[i] = NULL;
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  $1 = 0;
  const octave_value& ov = $input;
  if (!ov.is_scalar_type()) {
    octave_value_list list = ov.list_value();
    int i, len = list.length();
    $1 = 1;
    for (i = 0; i < len; i++) {
      if (!list(i).is_string()) {
        $1 = 0;
        break;
      }
    }
  }
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2 != NULL) {
    $1_ltype i;
    for (i = 0; i < $1; i++) {
      free((void *)$2[i]);
    }
    free((void *)$2);
  }
}
