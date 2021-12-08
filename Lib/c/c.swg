/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.swg
 * ----------------------------------------------------------------------------- */ 

%include <cheader.swg>

%insert("runtime") "clabels.swg"

%insert("runtime") %{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <setjmp.h>

#define SWIG_contract_assert(expr, msg) if(!(expr)) { printf("%s\n", msg); SWIG_exit(0); } else
%}

%fragment("stdbool_inc", "cheader") {#include <stdbool.h>}

%define same_macro_all_primitive_types_but_void(macro_name, TM)
macro_name(TM, short);
macro_name(TM, unsigned short);
macro_name(TM, int);
macro_name(TM, unsigned int);
macro_name(TM, long);
macro_name(TM, unsigned long);
macro_name(TM, long long);
macro_name(TM, unsigned long long);
macro_name(TM, char);
macro_name(TM, signed char);
macro_name(TM, unsigned char);
macro_name(TM, float);
macro_name(TM, double);
macro_name(TM, size_t);
%enddef

// This is used to handle all primitive types as just themselves.
// This macro doesn't cover const references, use either cref_as_value or
// cref_as_ptr below in addition to it.
// Notice that const pointers are mapped to non-const ones as we need to
// declare variables of this type when it's used as a return type, and top
// level const doesn't matter anyhow in the function declarations.
%define same_type(TM, T)
%typemap(TM) T, const T "T"
%typemap(TM) T*, T&, T[ANY], T[] "T *"
%typemap(TM) const T*, const T[ANY], const T[] "const T *"
%typemap(TM) T**, T*&, T*[ANY], T[ANY][ANY] "T **"
%typemap(TM) const T**, const T*&, T *const &, const T*[ANY], const T[ANY][ANY] "const T **"
// constant pointers
%typemap(TM) T * const "T *"
%typemap(TM) T* * const "T* *"
%typemap(TM) const T* * const "const T* *"
%enddef

%define cref_as_value(TM, T)
%typemap(TM) const T& "T"
%enddef

%define cref_as_ptr(TM, T)
%typemap(TM) const T& "T *"
%enddef

%define same_type_all_primitive_types_but_void(TM)
%enddef

//Used by 'in' and 'out' typemaps
%define same_action(TM, T, ACTION, ACTION_CREF)
%typemap(TM) T, const T ACTION
%typemap(TM) const T& ACTION_CREF
%typemap(TM) T*, T&, T[ANY], T[] ACTION
%typemap(TM) const T*, const T[ANY], const T[] ACTION
%typemap(TM) T**, T*&, T*[ANY], T[ANY][ANY] ACTION
%typemap(TM) const T**, const T*&, const T*[ANY], const T[ANY][ANY] ACTION
// constant pointers
%typemap(TM) T * const ACTION
%typemap(TM) T* * const ACTION
%typemap(TM) const T* * const ACTION
%enddef

%define same_action_all_primitive_types(TM, ACTION, ACTION_CREF)
same_action(TM, short, ACTION, ACTION_CREF);
same_action(TM, unsigned short, ACTION, ACTION_CREF);
same_action(TM, int, ACTION, ACTION_CREF);
same_action(TM, unsigned int, ACTION, ACTION_CREF);
same_action(TM, long, ACTION, ACTION_CREF);
same_action(TM, unsigned long, ACTION, ACTION_CREF);
same_action(TM, long long, ACTION, ACTION_CREF);
same_action(TM, unsigned long long, ACTION, ACTION_CREF);
same_action(TM, char, ACTION, ACTION_CREF);
same_action(TM, signed char, ACTION, ACTION_CREF);
same_action(TM, unsigned char, ACTION, ACTION_CREF);
//unsigned only
same_action(TM, float, ACTION, ACTION_CREF);
same_action(TM, double, ACTION, ACTION_CREF);
same_action(TM, size_t, ACTION, ACTION_CREF);
%typemap(TM) void*, void const* ACTION
%enddef

// "ctype" is the type used with C wrapper functions.
// void
%typemap(ctype) void "void"
%typemap(ctype) void*, void& "void *"
%typemap(ctype) const void&, const void* "const void *"
%typemap(ctype) void**, void*& "void **"
%typemap(ctype) const void**, const void*& "const void **"
// constant pointers
%typemap(ctype) void* * const "void* * const"
%typemap(ctype) const void* * const "const void* * const"

same_macro_all_primitive_types_but_void(same_type,ctype);
same_macro_all_primitive_types_but_void(cref_as_value,ctype);

// trivial typemap for arrays of void pointers to avoid applying the object typemaps to them
%typemap(ctype) void*[ANY] "void **"

// objects
%typemap(ctype) SWIGTYPE      "$&resolved_type*"
%typemap(ctype) SWIGTYPE *    "$resolved_type*"
%typemap(ctype) SWIGTYPE * const & "$resolved_type*"
%typemap(ctype) SWIGTYPE &    "$*resolved_type*"
%typemap(ctype) SWIGTYPE [ANY] "$resolved_type*"
%typemap(ctype) SWIGTYPE * [ANY] "$resolved_type**"

// enums
%typemap(ctype) enum SWIGTYPE       "$resolved_type"
%typemap(ctype) enum SWIGTYPE *     "$resolved_type*"
%typemap(ctype) enum SWIGTYPE &     "$*resolved_type*"
%typemap(ctype) enum SWIGTYPE [ANY] "$resolved_type*"

%typemap(ctype, fragment="stdbool_inc") bool, const bool, const bool & "bool"
%typemap(ctype, fragment="stdbool_inc") bool *, const bool *, bool & "bool *"

// Typemaps for assigning wrapper parameters to local variables
same_action_all_primitive_types(in, "$1 = ($1_ltype) $input;", "$1 = &$input;")

%typemap(in) short [ANY], int [ANY], long [ANY], long long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY] "$1 = ($1_basetype *) $input;"
%typemap(in) short * [ANY], int * [ANY], long * [ANY], long long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$1 = ($1_basetype *) $input;"

%typemap(in, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool * "$1 = ($1_ltype) $input;"
%typemap(in, fragment="stdbool_inc") bool & "$1 = ($1_basetype *) $input;"
%typemap(in, fragment="stdbool_inc") const bool &, const bool * "$1 = ($1_basetype *) $input;"

%typemap(in) enum SWIGTYPE "$1 = ($1_ltype) $input;"
%typemap(in) enum SWIGTYPE &,enum SWIGTYPE * "$1 = ($1_ltype) $input;"

%typemap(in) SWIGTYPE [] "$1 = ($1_ltype) $input;"
%typemap(in) SWIGTYPE ((&)[ANY]) "$1 = ($1_ltype) $input;"

%typemap(in) SWIGTYPE (CLASS::*) {
  if ($input) 
    $1 = *($&1_ltype) &$input;
}

%typemap(in) SWIGTYPE "$1 = *($1_ltype *)$input;"

%typemap(in) SWIGTYPE * "$1 = ($1_ltype) $input;"

%typemap(in) SWIGTYPE *[ANY] {
  if ($input) {
    $1 = ($1_ltype) malloc($1_dim0 * sizeof($1_basetype));
    size_t i = 0;
    for ( ; i < $1_dim0; ++i)
      if ($input[i])
        $1[i] = ($*1_ltype) $input[i];
      else
        $1[i] = ($*1_ltype) 0;
  }
  else
    $1 = ($1_ltype) 0;
}

%typemap(in) SWIGTYPE [ANY][ANY] {
  if ($input) {
    $1 = ($1_ltype) malloc($1_dim0 * $1_dim1 * sizeof($1_basetype));
    size_t i = 0, j = 0;
    for ( ; i < $1_dim0; ++i) {
      for ( ; j < $1_dim1; ++j) {
        if ($input[i][j])
          $1[i][j] = * ($*1_ltype) $input[i][j];
        else
          $1[i][j] = * ($*1_ltype) 0;
      }
    }
  }
  else
    $1 = ($1_ltype) 0;
}

%typemap(freearg) SWIGTYPE * [ANY], SWIGTYPE * [ANY][ANY] {
  if ($input)
    free($input);
}

%typemap(in) SWIGTYPE & %{
    $1 = ($1_ltype) $input;
%}

// Typemaps for assigning result values to a special return variable
same_action_all_primitive_types(out, "$result = $1;", "$result = *$1;")

%typemap(out) void ""

%typemap(out, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$result = ($1_ltype) $1;"
%typemap(out, fragment="stdbool_inc") bool &, const bool & "$result = $1;"

%typemap(out) enum SWIGTYPE "$result = (int) $1;"
%typemap(out) enum SWIGTYPE &, enum SWIGTYPE * "$result = $1;"

%typemap(out) SWIGTYPE (CLASS::*) {
  *($&1_ltype) &$result = $1; 
}

%typemap(out) SWIGTYPE "$result = (SwigObj*)new $1_ltype($1);"

%typemap(out) SWIGTYPE *, SWIGTYPE & "$result = (SwigObj*) $1;"

%typemap(out) SWIGTYPE * [ANY], SWIGTYPE [ANY][ANY] {
  static SwigObj **_temp = 0;
  if ($1) {
    size_t i = 0;
    if (_temp) {
        for ( ; i < $1_dim0; ++i)
          delete ($1_ltype *)_temp[i];
        free(_temp);
    }
    _temp = (SwigObj**) malloc($1_dim0 * sizeof(SwigObj*));
    for (i = 0 ; i < $1_dim0; ++i) {
      if ($1[i]) {
        _temp[i] = $1[i];
      }
      else
        _temp[i] = (SwigObj*) 0;
    }
    $result = ($1_ltype) _temp;
  }
  else
    $result = ($1_ltype) 0;
}

/* Typecheck typemaps - The purpose of these is merely to issue a warning for overloaded C++ functions
 * that cannot be overloaded in the wrappers as more than one C++ type maps to a single C type */

%typecheck(SWIG_TYPECHECK_BOOL)
    bool,
    const bool &
    ""

%typecheck(SWIG_TYPECHECK_CHAR)
    char,
    const char &
    ""

%typecheck(SWIG_TYPECHECK_INT8)
    signed char,
    const signed char &
    ""

%typecheck(SWIG_TYPECHECK_UINT8)
    unsigned char,
    const unsigned char &
    ""

%typecheck(SWIG_TYPECHECK_INT16)
    short,
    const short &
    ""

%typecheck(SWIG_TYPECHECK_UINT16)
    unsigned short,
    const unsigned short &
    ""

%typecheck(SWIG_TYPECHECK_INT32)
    int,
    long,
    const int &,
    const long &
    ""

%typecheck(SWIG_TYPECHECK_UINT32)
    unsigned int,
    unsigned long,
    const unsigned int &,
    const unsigned long &
    ""

%typecheck(SWIG_TYPECHECK_INT64)
    long long,
    const long long &
    ""

%typecheck(SWIG_TYPECHECK_UINT64)
    unsigned long long,
    const unsigned long long &
    ""

%typecheck(SWIG_TYPECHECK_FLOAT)
    float,
    const float &
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE)
    double,
    const double &
    ""

%typecheck(SWIG_TYPECHECK_STRING)
    char *,
    char *&,
    char[ANY],
    char[]
    ""

%typecheck(SWIG_TYPECHECK_POINTER)
    SWIGTYPE,
    SWIGTYPE *,
    SWIGTYPE &,
    SWIGTYPE &&,
    SWIGTYPE *const&,
    SWIGTYPE [],
    SWIGTYPE (CLASS::*)
    ""

#ifdef SWIG_CPPMODE

%insert("runtime") %{
typedef struct SwigObj SwigObj;
%}

%insert("cheader") %{
typedef struct SwigObj SwigObj;
%}

#endif // SWIG_CPPMODE

#ifdef SWIG_C_EXCEPT
%include "cexcept.swg"
#else // !SWIG_C_EXCEPT
// Still define the macro used in some standard typemaps, but we can't
// implement it in C, so just allow the user predefining their own version.
%insert("runtime") %{
#ifndef SWIG_exception
#define SWIG_exception(code, msg)
#endif
%}
#endif // SWIG_C_EXCEPT/!SWIG_C_EXCEPT

%insert("runtime") %{
#ifdef __cplusplus
extern "C" {
#endif
SWIGEXPORTC int SWIG_exit(int code) { exit(code); }
#ifdef __cplusplus
}
#endif
%}
