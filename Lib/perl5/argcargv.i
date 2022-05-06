/* ------------------------------------------------------------
 * --- Argc & Argv ---
 * ------------------------------------------------------------ */

%typemap(default) (int ARGC, char **ARGV) {
  $1 = 0; $2 = NULL;
}

%typemap(in) (int ARGC, char **ARGV) {
  int i;
  I32 len;
  AV *av = (AV *)SvRV($input);
  if (SvTYPE(av) != SVt_PVAV) {
    SWIG_croak("in method '$symname', Expecting reference to argv array");
    goto fail;
  }
  len = av_len(av) + 1;
  $1 = ($1_ltype) len;
  $2 = (char **) malloc((len+1)*sizeof(char *));
  for (i = 0; i < len; i++) {
    SV **tv = av_fetch(av, i, 0);
    $2[i] = SvPV_nolen(*tv);
  }
  $2[i] = NULL;
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2 != NULL) {
    free((void *)$2);
  }
}
