/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.swg
 * ----------------------------------------------------------------------------- */ 

// WARNING: passing function pointers from C as parameters of type (or as
// return values) SWIGTYPE (CLASS::*) causes cast of C function to type
// void(*)() and it is user's responsibility to properly handle this 
// function's arguments and return value.

%insert("runtime") "clabels.swg"
%insert("proxy_header") "cproxy.swg"

%insert("runtime") %{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <setjmp.h>

#define SWIG_STR(x) #x
#define SWIG_contract_assert(expr, msg) if(!(expr)) { printf("%s\n", msg); SWIG_exit(0); } else
%}

%fragment("fptr_decl", "runtime") {typedef void(*SWIG_CPP_FP)();}
%fragment("fptr_decl_proxy", "proxy_header") {typedef void(*SWIG_CPP_FP)();}
%fragment("stdbool_inc", "proxy_header") {#include <stdbool.h>}

// typemaps for function parameters

%typemap(ctype) void, short, int, long, char, float, double "$1_ltype"
%typemap(ctype) unsigned short, unsigned int, unsigned long, unsigned char "$1_ltype"
%typemap(ctype) void *, short *, int *, long *, char *, float *, double * "$1_ltype"
%typemap(ctype) void **, short **, int **, long **, char **, float **, double ** "$1_ltype"
%typemap(ctype) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$1_ltype"
%typemap(ctype) unsigned short **, unsigned int **, unsigned long **, unsigned char ** "$1_type"
%typemap(ctype) short &, int &, long &, char &, float &, double &  "$1_ltype"
%typemap(ctype) unsigned short &, unsigned int &, unsigned long &, unsigned char & "$1_ltype"
%typemap(ctype) const short &, const int &, const long &, const char &, const float &, const double & "$1_ltype"
%typemap(ctype) const short, const int, const long, const char, const float, const double  "$1_ltype"
%typemap(ctype) const unsigned short, const unsigned int, const unsigned long, const unsigned char "$1_type"
%typemap(ctype) const void *, const short *, const int *, const long *, const char *, const float *, const double * "/*hhhh*/$1_type"
%typemap(ctype) short *&, int *&, long *&, char *&, float *&, double *& "$1_ltype"
%typemap(ctype) const short *&, const int *&, const long *&, const char *&, const float *&, const double *& "$1_basetype **"
%typemap(ctype) short [ANY], int [ANY], long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY], unsigned int [ANY] "/*aaa*/ $1_ltype"
%typemap(ctype) void * [ANY], short * [ANY], int * [ANY], long * [ANY], char * [ANY], float * [ANY], double * [ANY] "/*bbb*/ $1_ltype"

// special cases of array passing - does not work for objects
%typemap(ctype) SWIGTYPE [] "$1_ltype"
%typemap(ctype) SWIGTYPE ((&)[ANY]) "$1_basetype **"

%typemap(ctype) void [ANY][ANY], short [ANY][ANY], int [ANY][ANY], long [ANY][ANY], char [ANY][ANY], float [ANY][ANY], double [ANY][ANY] "$1_ltype"
%typemap(ctype) SWIGTYPE         "SwigObj *"
%typemap(ctype) SWIGTYPE *       "SwigObj *"
%typemap(ctype) SWIGTYPE &       "SwigObj *"
%typemap(ctype) SWIGTYPE [ANY][ANY], SWIGTYPE ** "/* whoa */ $*1_ltype *"
%typemap(ctype) SWIGTYPE *[ANY]  "/*ooooh*/ $*1_ltype"
//%typemap(ctype) SWIGTYPE * [ANY][ANY], SWIGTYPE *** "SwigObj ***"
%typemap(ctype) SWIGTYPE *&      "/* *& */ SwigObj **"
%typemap(ctype) enum SWIGTYPE    "int"
%typemap(ctype, fragment="fptr_decl", fragment="fptr_decl_proxy") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(ctype, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool *, bool * [ANY] "$1_type"
%typemap(ctype, fragment="stdbool_inc") bool & "$1_ltype"
%typemap(ctype, fragment="stdbool_inc") const bool & "$1_ltype const"

%typemap(in) short, int, long, char, float, double "$1 = ($1_ltype) $input;"
%typemap(in) void *, short *, int *, long *, char *, float *, double * "$1 = ($1_ltype) $input;"
%typemap(in) void **, short **, int **, long **, char **, float **, double ** "$1 = ($1_basetype **) $input;"
%typemap(in) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$1 = ($1_ltype) $input;"
%typemap(in) unsigned short **, unsigned int **, unsigned long **, unsigned char ** "$1 = ($1_ltype) $input;"
%typemap(in) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$1 = ($1_ltype) $input;"
%typemap(in) const unsigned short *, const unsigned int *, const unsigned long *, const unsigned char * "$1 = ($1_ltype) $input;"
%typemap(in) unsigned short, unsigned int, unsigned long, unsigned char "$1 = ($1_ltype) $input;"
%typemap(in) short &, int &, long &, char &, float &, double &, bool & "$1 = ($1_ltype) $input;"
%typemap(in) const short &, const int &, const long &, const char &, const float &, const double & "$1 = ($1_ltype) $input;"
%typemap(in) unsigned short &, unsigned int &, unsigned long &, unsigned char &  "$1 = ($1_ltype) $input;"
%typemap(in) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned char & "$1 = ($1_ltype) $input;"

%typemap(in) short *&, int *&, long *&, char *&, float *&, double *& "$1 = ($1_ltype) $input;"
%typemap(in) const short *&, const int *&, const long *&, const char *&, const float *&, const double *& "$1 = ($1_ltype) $input;"
%typemap(in) short [ANY], int [ANY], long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY] "$1 = ($1_basetype *) $input;"
%typemap(in) void * [ANY], short * [ANY], int * [ANY], long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$1 = ($1_basetype *) $input;"

%typemap(in, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool * "$1 = ($1_ltype) $input;"
%typemap(in, fragment="stdbool_inc") bool & "$1 = ($1_basetype *) $input;"
%typemap(in, fragment="stdbool_inc") const bool &, const bool * "$1 = ($1_basetype *) $input;"

%typemap(in) enum SWIGTYPE "$1 = ($1_type) $input;"

%typemap(in) SWIGTYPE [] "$1 = ($1_ltype) $input;"
%typemap(in) SWIGTYPE ((&)[ANY]) "$1 = ($1_ltype) $input;"

%typemap(in) SWIGTYPE (CLASS::*) {
  if ($input) 
    $1 = *($&1_ltype) &$input;
}

%typemap(in) SWIGTYPE {
  $1 = *($1_ltype *) ($input->obj);
}

%typemap(in) SWIGTYPE * {
  if ($input)
    $1 = ($1_ltype) $input->obj;
}

%typemap(in) SWIGTYPE ** {
  if ($input)
    $1 = ($1_ltype) $input;
}

%typemap(in) SWIGTYPE *[ANY] {
  if ($input) {
    $1 = ($1_ltype) malloc($1_dim0 * sizeof($1_basetype));
    size_t i = 0;
    for ( ; i < $1_dim0; ++i)
      if ($input[i])
        $1[i] = ($*1_ltype) $input[i]->obj;
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
          $1[i][j] = * ($*1_ltype) $input[i][j]->obj;
        else
          $1[i][j] = * ($*1_ltype) 0;
      }
    }
  }
  else
    $1 = ($1_ltype) 0;
}

/*
 * unsupported yet
%typemap(freearg) SWIGTYPE * [ANY], SWIGTYPE * [ANY][ANY], SWIGTYPE **, SWIGTYPE *** {
  if ($input)
    free($input);
}
*/

%typemap(in) SWIGTYPE & {
  if ($input)
    $1 = ($1_ltype) $input->obj;
  else
    $1 = ($1_ltype) 0;
}

%typemap(in) SWIGTYPE *& {
  if ($input)
    $1 = ($1_ltype) &(*$input)->obj;
  else
    $1 = ($1_ltype) 0;
}

// typemaps for return values

%typemap(couttype) void, short, int, long, char, float, double "$1_ltype"
%typemap(couttype) unsigned short, unsigned int, unsigned long, unsigned char, signed char "$1_ltype"
%typemap(couttype) void *, short *, int *, long *, char *, float *, double*, unsigned char *, signed char * "$1_ltype"
%typemap(couttype) const short, const int, const long, const char, const float, const double "$1_ltype"
%typemap(couttype) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$1_ltype"
%typemap(couttype) short &, int &, long &, char &, float &, double & "$1_ltype"
%typemap(couttype) const short &, const int &, const long &, const char &, const float &, const double & "$1_basetype const *"
%typemap(couttype) short *&, int *&, long *&, char *&, float *&, double *& "$1_ltype"
%typemap(couttype) const short *&, const int *&, const long *&, const char *&, const float *&, const double *& "$1_ltype"
%typemap(couttype) short [ANY], int [ANY], long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY], signed char [ANY], unsigned int [ANY] "$1_ltype"
%typemap(couttype) short * [ANY], int * [ANY], long * [ANY], char * [ANY], float * [ANY], double * [ANY] "/*builtin * [ANY]*/ $1_ltype"
%typemap(couttype) short **, int **, long **, char **, float **, double ** "$1_ltype"
%typemap(couttype) SWIGTYPE      "SwigObj *"
%typemap(couttype) SWIGTYPE *    "/*aaaaaa*/SwigObj *"
%typemap(couttype) SWIGTYPE &   "SwigObj *"
%typemap(couttype) SWIGTYPE *&    "SwigObj **"
%typemap(couttype) SWIGTYPE [ANY] "/*SWIGTYPE [ANY]*/ SwigObj **"
%typemap(couttype) SWIGTYPE * [ANY], SWIGTYPE ** "/*SWIGTYPE *[ANY]/** */ SwigObj **"
//%typemap(couttype) SWIGTYPE * [ANY][ANY], SWIGTYPE *** "SwigObj ***"
%typemap(couttype) enum SWIGTYPE "int"
%typemap(couttype, fragment="fptr_decl") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(couttype, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$1_ltype"
%typemap(couttype, fragment="stdbool_inc") bool & "$1_basetype*"
%typemap(couttype, fragment="stdbool_inc") const bool & "$1_basetype const *"

%typemap(out) short, int, long, char, float, double "$result = $1;"
%typemap(out) void*, short*, int*, long*, char*, float*, double* "$result = $1;"
%typemap(out) const short, const int, const long, const char, const float, const double "$result = ($1_ltype) $1;"
%typemap(out) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$result = ($1_ltype) $1;"
%typemap(out) unsigned short, unsigned int, unsigned long, unsigned char, signed char "$result = $1;"
%typemap(out) unsigned short *, unsigned int *, unsigned long *, unsigned char *, signed char * "$result = $1;"
%typemap(out) short &, int &, long &, char &, float &, double & "$result = $1;"
%typemap(out) unsigned short &, unsigned int &, unsigned long &, unsigned char &, signed char & "$result = $1;"
%typemap(out) const short &, const int &, const long &, const char &, const float &, const double & "$result = $1;"
%typemap(out) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned char &, const signed char & "$result = $1;"
%typemap(out) short *&, int *&, long *&, char *&, float *&, double *& "$result = $1;"
%typemap(out) const short *&, const int *&, const long *&, const char *&, const float *&, const double *& "$result = $1;"
%typemap(out) short [ANY], int [ANY], long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY], signed char [ANY], unsigned int [ANY] "$result = $1;"
%typemap(out) short * [ANY], int * [ANY], long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$result = $1;"
%typemap(out) short **, int **, long **, char **, float **, double ** "$result = $1;"
%typemap(out) void ""

%typemap(out, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$result = ($1_ltype) $1;"
%typemap(out, fragment="stdbool_inc") bool &, const bool & "$result = $1;"

%typemap(out) enum SWIGTYPE "$result = ($1_ltype) $1;"

%typemap(out) SWIGTYPE (CLASS::*) {
  *($&1_ltype) &$result = $1; 
}

%typemap(out) SWIGTYPE *&, SWIGTYPE ** {
  $result = &SWIG_temporary;
  (*result)->obj = (void*) $1;
}

%typemap(out) SWIGTYPE {
  $result = SWIG_temporary;
  $result->obj = (void*) &$1;
}

%typemap(out) SWIGTYPE *, SWIGTYPE & {
  $result = SWIG_temporary;
  $result->obj = (void*) $1;
}

%typemap(out) SWIGTYPE * [ANY], SWIGTYPE [ANY][ANY] {
  static SwigObj **_temp = 0;
  if ($1) {
    size_t i = 0;
    if (_temp) {
        for ( ; i < $1_dim0; ++i)
          SWIG_destroy_object(_temp[i]);
        free(_temp);
    }
    _temp = (SwigObj**) malloc($1_dim0 * sizeof(SwigObj*));
    for (i = 0 ; i < $1_dim0; ++i) {
      if ($1[i]) {
        _temp[i] = SWIG_create_object(SWIG_STR($1_ltype));
        _temp[i]->obj = (void*) $1[i];
      }
      else
        _temp[i] = (SwigObj*) 0;
    }
    $result = _temp;
  }
  else
    $result = (SwigObj**) 0;
}

/*
 * 2+ dim arrays - not supported yet
%typemap(out) SWIGTYPE * [ANY][ANY], SWIGTYPE *** {
  if ($1) {
    $result = (SwigObj***) malloc($1_dim0 * $1_dim1 * sizeof(SwigObj*));
    size_t i = 0, j = 0;
    for ( ; i < $1_dim0; ++i) {
      for ( ; j < $1_dim1; ++j) {
        if ($1[i][j]) {
          $result[i][j] = SWIG_create_object(SWIG_STR($1_ltype));
          $result[i][j]->obj = (void*) $1[i][j];
        }
        else
          $result[i][j] = (SwigObj*) 0;
      }
    }
  }
  else
    $result = (SwigObj***) 0;
}*/


#ifdef SWIG_C_EXCEPT
%insert("runtime") %{
typedef struct {
  void *obj;
  const char **typenames;
} SwigObj;
%}
%include "cexcept.swg"
#ifdef SWIG_CPPMODE
%insert("runtime") %{
SwigObj *SWIG_temporary = (SwigObj *) malloc(sizeof(SwigObj));
%}
#endif
#else
%insert("runtime") %{
typedef struct {
  void *obj;
} SwigObj;

#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORTC int SWIG_exit(int code) {
  exit(code);
}

#ifdef __cplusplus
}
#endif
%}

#ifdef SWIG_CPPMODE
%insert("runtime") %{
SwigObj *SWIG_temporary = (SwigObj *) malloc(sizeof(SwigObj));
%}
#endif

%insert("proxy_header") %{
typedef struct {
  void *obj;
  const char **typenames;
} SwigObj;
%}

#endif

