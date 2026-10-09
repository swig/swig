/* -----------------------------------------------------------------------------
 * swigcommon.swg
 *
 * Typemaps common to all target languages. A target language includes this file after its runtime and error support
 * code, but before its own typemaps, which can then override or copy these typemaps. Before including it, the target
 * language defines:
 *   SWIG_exception_fail(code, msg)    - raises the target language error for the SWIG error code with the message
 *                                       and leaves the wrapper function.
 *   %fragment("SWIG_exception_fail")  - any support code that SWIG_exception_fail needs.
 * A typemap here that raises an error uses fragment="SWIG_exception_fail" and canthrow=1 (for C# and D). Its code is
 * in a noblock=1 { } body, as SWIG_exception_fail is a SWIG preprocessor macro in some target languages.
 * ----------------------------------------------------------------------------- */

%insert("runtime") "swigerrors.swg"

#ifdef __cplusplus
/* Define std namespace */
namespace std {
  /* Warn about std::initializer_list usage. The constructor/method where used should probably be ignored. See docs. */
  template<typename T> class initializer_list {};
  %typemap(in, warning=SWIGWARN_TYPEMAP_INITIALIZER_LIST_MSG) initializer_list<T> ""
  %typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) initializer_list<T> ""
}
#endif

/* -----------------------------------------------------------------------------
 * Default char * and C array typemaps
 * ----------------------------------------------------------------------------- */

/* Set up the typemap for handling new return strings */

#ifdef __cplusplus
%typemap(newfree) char * "delete [] $1;"
#else
%typemap(newfree) char * "free($1);"
#endif

/* Default typemap for handling char * members */

#ifdef __cplusplus
%typemap(memberin,fragment="<string.h>") char * {
  delete [] $1;
  if ($input) {
     $1 = ($1_type) (new char[strlen((const char *)$input)+1]);
     strcpy((char *)$1, (const char *)$input);
  } else {
     $1 = 0;
  }
}
%typemap(memberin,warning=SWIGWARN_TYPEMAP_CHARLEAK_MSG,fragment="<string.h>") const char * {
  if ($input) {
     $1 = ($1_type) (new char[strlen((const char *)$input)+1]);
     strcpy((char *)$1, (const char *)$input);
  } else {
     $1 = 0;
  }
}
%typemap(globalin,fragment="<string.h>") char * {
  delete [] $1;
  if ($input) {
     $1 = ($1_type) (new char[strlen((const char *)$input)+1]);
     strcpy((char *)$1, (const char *)$input);
  } else {
     $1 = 0;
  }
}
%typemap(globalin,warning=SWIGWARN_TYPEMAP_CHARLEAK_MSG,fragment="<string.h>") const char * {
  if ($input) {
     $1 = ($1_type) (new char[strlen((const char *)$input)+1]);
     strcpy((char *)$1, (const char *)$input);
  } else {
     $1 = 0;
  }
}
#else
%typemap(memberin,fragment="<string.h>") char * {
  free($1);
  if ($input) {
     $1 = ($1_type) malloc(strlen((const char *)$input)+1);
     strcpy((char *)$1, (const char *)$input);
  } else {
     $1 = 0;
  }
}
%typemap(memberin,warning=SWIGWARN_TYPEMAP_CHARLEAK_MSG,fragment="<string.h>") const char * {
  if ($input) {
     $1 = ($1_type) malloc(strlen((const char *)$input)+1);
     strcpy((char *)$1, (const char *)$input);
  } else {
     $1 = 0;
  }
}
%typemap(globalin,fragment="<string.h>") char * {
  free($1);
  if ($input) {
     $1 = ($1_type) malloc(strlen((const char *)$input)+1);
     strcpy((char *)$1, (const char *)$input);
  } else {
     $1 = 0;
  }
}
%typemap(globalin,warning=SWIGWARN_TYPEMAP_CHARLEAK_MSG,fragment="<string.h>") const char * {
  if ($input) {
     $1 = ($1_type) malloc(strlen((const char *)$input)+1);
     strcpy((char *)$1, (const char *)$input);
  } else {
     $1 = 0;
  }
}

#endif

/* Character array handling */

%typemap(memberin, canthrow=1, noblock=1, fragment="SWIG_exception_fail", fragment="SWIG_AssignCharArray") char [ANY] {
  if (!$input) {
    SWIG_exception_fail(SWIG_NullReferenceError, "invalid null reference in variable '$name' of type '$1_type'");
  } else {
    SWIG_AssignCharArray((char *)$1, $1_dim0, (const char *)$input);
  }
}

%typemap(globalin, canthrow=1, noblock=1, fragment="SWIG_exception_fail", fragment="SWIG_AssignCharArray") char [ANY] {
  if (!$input) {
    SWIG_exception_fail(SWIG_NullReferenceError, "invalid null reference in variable '$name' of type '$1_type'");
  } else {
    SWIG_AssignCharArray((char *)$1, $1_dim0, (const char *)$input);
  }
}

/* No char [] memberin/globalin typemaps, so such a variable is read only, as there is no size to bound the copy */

/* memberin/globalin typemaps for arrays, which copy all $1_size elements, so also those of an array of arrays */
%typemap(memberin, canthrow=1, noblock=1, fragment="SWIG_exception_fail") SWIGTYPE [ANY], SWIGTYPE [ANY][ANY] {
  if (!$input) {
    SWIG_exception_fail(SWIG_NullReferenceError, "invalid null reference in variable '$name' of type '$1_type'");
  } else {
    size_t ii;
    for (ii = 0; ii < (size_t)$1_size; ii++) {
      (($1_basetype *)$1)[ii] = (($1_basetype *)$input)[ii];
    }
  }
}

%typemap(globalin, canthrow=1, noblock=1, fragment="SWIG_exception_fail") SWIGTYPE [ANY], SWIGTYPE [ANY][ANY] {
  if (!$input) {
    SWIG_exception_fail(SWIG_NullReferenceError, "invalid null reference in variable '$name' of type '$1_type'");
  } else {
    size_t ii;
    for (ii = 0; ii < (size_t)$1_size; ii++) {
      (($1_basetype *)$1)[ii] = (($1_basetype *)$input)[ii];
    }
  }
}

/* No check for NULL for a reference to an array, as the in typemap for a reference rejects it. A target language
 * whose in typemap does not, copies the typemaps above for a reference to an array instead. */
%typemap(memberin) SWIGTYPE (&)[ANY], SWIGTYPE (&&)[ANY] {
  size_t ii;
  for (ii = 0; ii < (size_t)$1_size; ii++) {
    (($1_basetype *)$1)[ii] = (($1_basetype *)$input)[ii];
  }
}

%typemap(globalin) SWIGTYPE (&)[ANY], SWIGTYPE (&&)[ANY] {
  size_t ii;
  for (ii = 0; ii < (size_t)$1_size; ii++) {
    (($1_basetype *)$1)[ii] = (($1_basetype *)$input)[ii];
  }
}
