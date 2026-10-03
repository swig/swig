/* Map a cell array of character vectors to argc and argv. */
%typemap(in) (int ARGC, char **ARGV) {
  mwSize i, count;
  $1 = 0;
  $2 = 0;
  if (!mxIsCell($input) || mxGetNumberOfElements($input) > INT_MAX) {
    %argument_fail(SWIG_TypeError, "expected a cell array of character vectors", $symname, $argnum);
  }
  count = mxGetNumberOfElements($input);
  $2 = (char **)mxCalloc(count + 1, sizeof(char *));
  for (i = 0; i < count; ++i) {
    mxArray *item = mxGetCell($input, i);
    if (!item || !mxIsChar(item) || (mxGetNumberOfElements(item) && mxGetM(item) != 1)) {
      %argument_fail(SWIG_TypeError, "expected a character vector", $symname, $argnum);
    }
    $2[i] = mxArrayToString(item);
    if (!$2[i]) {
      %argument_fail(SWIG_MemoryError, "cannot allocate argument string", $symname, $argnum);
    }
    ++$1;
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  mwSize i;
  $1 = mxIsCell($input);
  if ($1) {
    for (i = 0; i < mxGetNumberOfElements($input); ++i) {
      mxArray *item = mxGetCell($input, i);
      if (!item || !mxIsChar(item) || (mxGetNumberOfElements(item) && mxGetM(item) != 1)) {
        $1 = 0;
        break;
      }
    }
  }
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2) {
    int i;
    for (i = 0; i < $1; ++i) mxFree($2[i]);
    mxFree($2);
  }
}
