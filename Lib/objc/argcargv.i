/* -----------------------------------------------------------------------------
 * argcargv.i
 *
 * Objective-C argc/argv multi-argument typemaps using NSArray of NSString.
 * ----------------------------------------------------------------------------- */

%typemap(imtype) (int ARGC, char **ARGV) "NSArray *"
%typemap(objctype) (int ARGC, char **ARGV) "NSArray *"
%typemap(objcin) (int ARGC, char **ARGV) "$objcinput"

%typemap(in) (int ARGC, char **ARGV) (char **argv = 0, size_t argc = 0) {
  if ($input) {
    argc = (size_t)[$input count];
    argv = (char **)calloc(argc + 1, sizeof(char *));
    for (size_t i = 0; i < argc; ++i) {
      NSString *item = (NSString *)[$input objectAtIndex:(NSUInteger)i];
      if (item) {
        NSUInteger length = [item length];
        argv[i] = (char *)calloc(length + 1, sizeof(char));
        memset(argv[i], 0, length + 1);
        for (NSUInteger j = 0; j < length; ++j)
          argv[i][j] = (char)[item characterAtIndex:j];
      } else {
        argv[i] = 0;
      }
    }
  }
  $1 = ($1_ltype)argc;
  $2 = ($2_ltype)argv;
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if (argv$argnum) {
    for (size_t i = 0; i < argc$argnum; ++i) {
      if (argv$argnum[i])
        free(argv$argnum[i]);
    }
    free(argv$argnum);
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  $1 = 1;
}
