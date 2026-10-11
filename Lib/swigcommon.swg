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

/* No check for NULL, which the in typemaps reject for a char array */
%typemap(memberin,fragment="SWIG_AssignCharArray") char [ANY] %{
  SWIG_AssignCharArray((char *)$1, $1_dim0, (const char *)$input);
%}

%typemap(globalin,fragment="SWIG_AssignCharArray") char [ANY] %{
  SWIG_AssignCharArray((char *)$1, $1_dim0, (const char *)$input);
%}

/* No char [] memberin/globalin typemaps, so such a variable is read only, as there is no size to bound the copy */

/* memberin/globalin typemap for arrays. */

%typemap(memberin) SWIGTYPE [ANY] {
  size_t ii;
  $1_basetype *b = ($1_basetype *) $1;
  for (ii = 0; ii < (size_t)$1_size; ii++) b[ii] = *(($1_basetype *) $input + ii);
}

%typemap(globalin) SWIGTYPE [ANY] {
  size_t ii;
  $1_basetype *b = ($1_basetype *) $1;
  for (ii = 0; ii < (size_t)$1_size; ii++) b[ii] = *(($1_basetype *) $input + ii);
}

%typemap(memberin) SWIGTYPE (&)[ANY] = SWIGTYPE [ANY];
%typemap(globalin) SWIGTYPE (&)[ANY] = SWIGTYPE [ANY];
%typemap(memberin) SWIGTYPE (&&)[ANY] = SWIGTYPE [ANY];
%typemap(globalin) SWIGTYPE (&&)[ANY] = SWIGTYPE [ANY];

/* memberin/globalin typemap for double arrays. */

%typemap(memberin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$1_dim1] = ($basetype (*)[$1_dim1])($input);
  $basetype (*dest)[$1_dim1] = ($basetype (*)[$1_dim1])($1);
  size_t ii = 0;
  for (; ii < $1_dim0; ++ii) {
    $basetype *ip = inp[ii];
    $basetype *dp = dest[ii];
    size_t jj = 0;
    for (; jj < $1_dim1; ++jj) dp[jj] = ip[jj];
  }
}

%typemap(globalin) SWIGTYPE [ANY][ANY] {
  $basetype (*inp)[$1_dim1] = ($basetype (*)[$1_dim1])($input);
  $basetype (*dest)[$1_dim1] = ($basetype (*)[$1_dim1])($1);
  size_t ii = 0;
  for (; ii < $1_dim0; ++ii) {
    $basetype *ip = inp[ii];
    $basetype *dp = dest[ii];
    size_t jj = 0;
    for (; jj < $1_dim1; ++jj) dp[jj] = ip[jj];
  }
}
