/* Define to 1 if the system has the type `bool'. */
#cmakedefine HAVE_BOOL 1

/* Define to 1 if you have the <inttypes.h> header file. */
#cmakedefine HAVE_INTTYPES_H 1

/* Define to 1 if you have the `dl' library (-ldl). */
#cmakedefine HAVE_LIBDL 1

/* Define to 1 if you have the `dld' library (-ldld). */
#cmakedefine HAVE_LIBDLD 1

/* Define to 1 if you have the <memory.h> header file. */
#cmakedefine HAVE_MEMORY_H 1

/* Define if popen is available */
#cmakedefine HAVE_POPEN 1

/* Define if rxspencer is available */
#cmakedefine HAVE_RXSPENCER 1

/* Define to 1 if you have the <stdint.h> header file. */
#cmakedefine HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#cmakedefine HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#cmakedefine HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#cmakedefine HAVE_STRING_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#cmakedefine HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#cmakedefine HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#cmakedefine HAVE_UNISTD_H 1

/* Define to 1 if your C compiler doesn't accept -c and -o together. */
#cmakedefine NO_MINUS_C_MINUS_O 1

/* Define to 1 if you have the ANSI C header files. */
#cmakedefine STDC_HEADERS 1

/* Name of package */
#define PACKAGE "swig"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "http://www.swig.org"

/* Define to the full name of this package. */
#define PACKAGE_NAME "swig"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "swig @SWIG_VERSION@"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "swig"

/* Define to the version of this package. */
#define PACKAGE_VERSION "@SWIG_VERSION@"

/* Compiler that built SWIG */
#define SWIG_CXX "@SWIG_CXX@"

/* Directory for SWIG system-independent libraries */
#define SWIG_LIB "/usr/local/share/swig/2.0.0"

/* Directory for SWIG system-independent libraries (Unix install on native
   Windows) */
#define SWIG_LIB_WIN_UNIX "C:/cygwin/usr/local/share/swig/2.0.0"

/* Platform that SWIG is built for */
#define SWIG_PLATFORM "i686-pc-cygwin"

/* Version number of package */
#define VERSION "@SWIG_VERSION@"

/* Default language */
#define SWIG_LANG               "-tcl"

/* Deal with Microsoft's attempt at deprecating C standard runtime functions */
#if defined(_MSC_VER)
# define _CRT_SECURE_NO_DEPRECATE
#endif
