/* This -*-c-*- file contains SWIG specific configuration data for those modules
   that care */

/* Directory where to find the machine-independent SWIG files */

#define SWIG_LIB   "/swig_root/lib/"

/* Default language */

#define SWIG_LANG  "-tcl"

/* Values returned by swig when invoked with the -ldflags option */

#define SWIG_PERL_RUNTIME "-L@-exec_prefix-@/lib -lswigpl@-release_suffix-@"
#define SWIG_PYTHON_RUNTIME "-L@-exec_prefix-@/lib -lswigpy@-release_suffix-@"
#define SWIG_TCL_RUNTIME "-L@-exec_prefix-@/lib -lswigtcl@-release_suffix-@"
#define SWIG_RUBY_RUNTIME "-L@-exec_prefix-@/lib -lswigrb@-release_suffix-@"
#define SWIG_GUILE_RUNTIME "-L@-exec_prefix-@/lib -lswigguile@-release_suffix-@"
#define SWIG_PIKE_RUNTIME "-L@-exec_prefix-@/lib -lswigpike@-release_suffix-@"
