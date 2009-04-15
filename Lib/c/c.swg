/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.swg
 * ----------------------------------------------------------------------------- */ 

// WARNING: passing function pointers from C as parameters of type (or as
// return values) SWIGTYPE (CLASS::*) causes cast of C function to type
// void(*)() and it is user's responsibility to properly handle this 
// function's arguments and return value. See 'cpp_basic' test for details.

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
%typemap(ctype) void, short, int, long, long long, char, float, double "$1_ltype"
%typemap(ctype) unsigned short, unsigned int, unsigned long, unsigned long long, unsigned char "$1_ltype"
%typemap(ctype) void *, short *, int *, long *, long long *, char *, float *, double * "$1_ltype"
%typemap(ctype) void **, short **, int **, long **, long long **, char **, float **, double ** "$1_ltype"
%typemap(ctype) unsigned short *, unsigned int *, unsigned long *, unsigned long long *, unsigned char * "$1_ltype"
%typemap(ctype) unsigned short **, unsigned int **, unsigned long **, unsigned long long **, unsigned char ** "$1_type"
%typemap(ctype) short &, int &, long &, long long &, char &, float &, double &  "$1_ltype"
%typemap(ctype) unsigned short &, unsigned int &, unsigned long &, unsigned long long &, unsigned char & "$1_ltype"
%typemap(ctype) const short, const int, const long, const long long, const char, const float, const double  "$1_ltype"
%typemap(ctype) const short &, const int &, const long &, const long long &, const char &, const float &, const double & "$1_ltype"
%typemap(ctype) const unsigned short, const unsigned int, const unsigned long, const unsigned long long, const unsigned char "$1_type"
%typemap(ctype) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned long long &, const unsigned char & "$1_ltype"
%typemap(ctype) const void *, const short *, const int *, const long *, const long long *, const char *, const float *, const double * "$1_type"
%typemap(ctype) short *&, int *&, long *&, long long *&, char *&, float *&, double *& "$1_ltype"
%typemap(ctype) const short *&, const int *&, const long *&, const long long *&, const char *&, const float *&, const double *& "$1_basetype **"
%typemap(ctype) short [ANY], int [ANY], long [ANY], long long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY], unsigned int [ANY] "/*aaa*/ $1_ltype"
%typemap(ctype) void * [ANY], short * [ANY], int * [ANY], long * [ANY], long long * [ANY], char * [ANY], float * [ANY], double * [ANY] "/*bbb*/ $1_ltype"

// special cases of array passing - does not intended to be used for objects
%typemap(ctype) SWIGTYPE [] "$1_ltype"
%typemap(ctype) SWIGTYPE ((&)[ANY]) "$1_basetype **"

%typemap(ctype) void [ANY][ANY], short [ANY][ANY], int [ANY][ANY], long [ANY][ANY], char [ANY][ANY], float [ANY][ANY], double [ANY][ANY] "$1_ltype"
%typemap(ctype) SWIGTYPE         "SwigObj *"
%typemap(ctype) SWIGTYPE *       "SwigObj *"
%typemap(ctype) SWIGTYPE &       "SwigObj *"
%typemap(ctype) SWIGTYPE [ANY][ANY], SWIGTYPE ** "/* whoa */ SwigObj ***"
%typemap(ctype) SWIGTYPE *[ANY]  "/*ooooh*/ SwigObj **"
%typemap(ctype) SWIGTYPE *&      "/* *& */ SwigObj **"
%typemap(ctype) enum SWIGTYPE    "int"
%typemap(ctype) enum SWIGTYPE &  "int *"
%typemap(ctype, fragment="fptr_decl", fragment="fptr_decl_proxy") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(ctype, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool *, bool * [ANY] "$1_type"
%typemap(ctype, fragment="stdbool_inc") bool & "$1_ltype"
%typemap(ctype, fragment="stdbool_inc") const bool & "$1_ltype const"

%typemap(in) short, int, long, long long, char, float, double "$1 = ($1_ltype) $input;"
%typemap(in) void *, short *, int *, long *, long long *, char *, float *, double * "$1 = ($1_ltype) $input;"
%typemap(in) void **, short **, int **, long **, long long **, char **, float **, double ** "$1 = ($1_basetype **) $input;"
%typemap(in) unsigned short *, unsigned int *, unsigned long *, unsigned long long *, unsigned char * "$1 = ($1_ltype) $input;"
%typemap(in) unsigned short **, unsigned int **, unsigned long **, unsigned long long **, unsigned char ** "$1 = ($1_ltype) $input;"
%typemap(in) const void *, const short *, const int *, const long *, const long long *, const char *, const float *, const double * "$1 = ($1_ltype) $input;"
%typemap(in) const unsigned short *, const unsigned int *, const unsigned long *, const unsigned long long *, const unsigned char * "$1 = ($1_ltype) $input;"
%typemap(in) unsigned short, unsigned int, unsigned long, unsigned long long, unsigned char "$1 = ($1_ltype) $input;"
%typemap(in) short &, int &, long &, long long &, char &, float &, double &, bool & "$1 = ($1_ltype) $input;"
%typemap(in) const short &, const int &, const long &, const long long &, const char &, const float &, const double & "$1 = ($1_ltype) $input;"
%typemap(in) unsigned short &, unsigned int &, unsigned long &, unsigned long long &, unsigned char &  "$1 = ($1_ltype) $input;"
%typemap(in) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned long long &, const unsigned char & "$1 = ($1_ltype) $input;"

%typemap(in) short *&, int *&, long *&, long long *&, char *&, float *&, double *& "$1 = ($1_ltype) $input;"
%typemap(in) const short *&, const int *&, const long *&, const long *&, const char *&, const float *&, const double *& "$1 = ($1_ltype) $input;"
%typemap(in) short [ANY], int [ANY], long [ANY], long long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY] "$1 = ($1_basetype *) $input;"
%typemap(in) void * [ANY], short * [ANY], int * [ANY], long * [ANY], long long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$1 = ($1_basetype *) $input;"

%typemap(in, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool * "$1 = ($1_ltype) $input;"
%typemap(in, fragment="stdbool_inc") bool & "$1 = ($1_basetype *) $input;"
%typemap(in, fragment="stdbool_inc") const bool &, const bool * "$1 = ($1_basetype *) $input;"

%typemap(in) enum SWIGTYPE "$1 = ($1_ltype) $input;"
%typemap(in) enum SWIGTYPE & "$1 = ($1_ltype) $input;"

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

%typemap(freearg) SWIGTYPE * [ANY], SWIGTYPE * [ANY][ANY], SWIGTYPE **, SWIGTYPE *** {
  if ($input)
    free($input);
}

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

// void
%typemap(couttype) void "void"
%typemap(couttype) void*, const void* "void *"

// short
%typemap(couttype) short, const short "short"
%typemap(couttype) short*, short&, short[ANY], short[] "short *"
%typemap(couttype) const short&, const short*, const short[ANY], const short[] "const short *"
%typemap(couttype) unsigned short "unsigned short"
%typemap(couttype) const unsigned short "const unsigned short"
%typemap(couttype) unsigned short*, unsigned short&, unsigned short*, unsigned short[ANY], unsigned short[] "unsigned short *"
%typemap(couttype) const unsigned short*, const unsigned short&, const unsigned short[ANY], const unsigned short[] "const unsigned short *"
%typemap(couttype) short**, short*&, short*[ANY], short[ANY][ANY] "short **"
%typemap(couttype) const short**, const short*&, const short*[ANY], const short[ANY][ANY] "const short **"
%typemap(couttype) unsigned short**, unsigned short*&, unsigned short*[ANY], unsigned short[ANY][ANY] "unsigned short **"
%typemap(couttype) const unsigned short**,const unsigned short*&, const unsigned short[ANY][ANY] "const unsigned short **"

// int
%typemap(couttype) int, const int "int"
%typemap(couttype) int*, int&, int[ANY], int[] "int *"
%typemap(couttype) const int&, const int*, const int[ANY], const int[] "const int *"
%typemap(couttype) unsigned int "unsigned int"
%typemap(couttype) const unsigned int "unsigned int"
%typemap(couttype) unsigned int*, unsigned int&, unsigned int*, unsigned int[ANY], unsigned int[] "unsigned int *"
%typemap(couttype) const unsigned int*, const unsigned int&, const unsigned int[ANY], const unsigned int[] "const unsigned int *"
%typemap(couttype) int**, int*&, int*[ANY], int[ANY][ANY] "int **"
%typemap(couttype) const int**, const int*&, const int*[ANY], const int[ANY][ANY] "const int **"
%typemap(couttype) unsigned int**, unsigned int*&, unsigned int*[ANY], unsigned int[ANY][ANY] "unsigned int **"
%typemap(couttype) const unsigned int**,const unsigned int*&, const unsigned int[ANY][ANY] "const unsigned int **"

// long
%typemap(couttype) long, const long "long"
%typemap(couttype) long*, long&, long[ANY], long[] "long *"
%typemap(couttype) const long&, const long*, const long[ANY], const long[] "const long *"
%typemap(couttype) unsigned long "unsigned long"
%typemap(couttype) const unsigned long "const unsigned long"
%typemap(couttype) unsigned long*, unsigned long&, unsigned long*, unsigned long[ANY], unsigned long[] "unsigned long *"
%typemap(couttype) const unsigned long*, const unsigned long&, const unsigned long[ANY], const unsigned long[] "const unsigned long *"
%typemap(couttype) long**, long*&, long*[ANY], long[ANY][ANY] "long **"
%typemap(couttype) const long**, const long*&, const long*[ANY], const long[ANY][ANY] "const long **"
%typemap(couttype) unsigned long**, unsigned long*&, unsigned long*[ANY], unsigned long[ANY][ANY] "unsigned long **"
%typemap(couttype) const unsigned long**,const unsigned long*&, const unsigned long[ANY][ANY] "const unsigned long **"

// long long
%typemap(couttype) long long, const long long "long long"
%typemap(couttype) long long*, long long&, long long[ANY], long long[] "long long *"
%typemap(couttype) const long long&, const long long*, const long long[ANY], const long long[] "const long long *"
%typemap(couttype) unsigned long long "unsigned long long"
%typemap(couttype) const unsigned long long "const unsigned long long"
%typemap(couttype) unsigned long long*, unsigned long long&, unsigned long long*, unsigned long long[ANY], unsigned long long[] "unsigned long long *"
%typemap(couttype) const unsigned long long*, const unsigned long long&, const unsigned long long[ANY], const unsigned long long[] "const unsigned long long *"
%typemap(couttype) long long**, long long*&, long long*[ANY], long long[ANY][ANY] "long long **"
%typemap(couttype) const long long**, const long long*&, const long long*[ANY], const long long[ANY][ANY] "const long long **"
%typemap(couttype) unsigned long long**, unsigned long long*&, unsigned long long*[ANY], unsigned long long[ANY][ANY] "unsigned long long **"
%typemap(couttype) const unsigned long long**,const unsigned long long*&, const unsigned long long[ANY][ANY] "const unsigned long long **"

// char: signed/unsigned
%typemap(couttype) char, const char "char"
%typemap(couttype) char*, char&, char[ANY], char[] "$1_ltype"
%typemap(couttype) const char&, const char*, const char[ANY], const char[] "const char *"
%typemap(couttype) char**, char*&, char*[ANY], char[ANY][ANY] "char **"
%typemap(couttype) const char**, const char*&, const char*[ANY], const char[ANY][ANY] "char **"
%typemap(couttype) signed char**, signed char*&, signed char*[ANY], signed char[ANY][ANY] "signed char **"
%typemap(couttype) const signed char**, const signed char*&, const signed char[ANY][ANY] "const signed char **"
%typemap(couttype) signed char "signed char"
%typemap(couttype) const signed char "const signed char"
%typemap(couttype) signed char*, signed char&, signed char*, signed char[ANY], signed char[] "signed char *"
%typemap(couttype) const signed char*, const signed char&, const signed char[ANY], const signed char[] "const $1_ltype"
%typemap(couttype) unsigned char**, unsigned char*&, unsigned char*[ANY], unsigned char[ANY][ANY] "unsigned char **"
%typemap(couttype) const unsigned char**, const unsigned char*&, const unsigned char[ANY][ANY] "const unsigned char **"
%typemap(couttype) unsigned char "unsigned char"
%typemap(couttype) const unsigned char "const unsigned char"
%typemap(couttype) unsigned char*, unsigned char&, unsigned char*, unsigned char[ANY], unsigned char[] "unsigned char *"
%typemap(couttype) const unsigned char*, const unsigned char&, const unsigned char[ANY], const unsigned char[] "const unsigned char *"

// float
%typemap(couttype) float, const float "float"
%typemap(couttype) float*, float&, float[ANY], float[] "float *"
%typemap(couttype) const float&, const float*, const float[ANY], const float[] "const float *"
%typemap(couttype) float**, float*&, const float*&, float*[ANY], float[ANY][ANY] "float **"
%typemap(couttype) const float**, const float*[ANY], const float[ANY][ANY] "const float **"

// double
%typemap(couttype) double, const double "double"
%typemap(couttype) double*, double&, double[ANY], double[] "double *"
%typemap(couttype) const double&, const double*, const double[ANY], const double[] "const double *"
%typemap(couttype) double**, double*&, const double*&, double*[ANY], double[ANY][ANY] "double **"
%typemap(couttype) const double**, const double*[ANY], const double[ANY][ANY] "const double **"

// objects
%typemap(couttype) SWIGTYPE      "SwigObj *"
%typemap(couttype) SWIGTYPE *    "/*aaaaaa*/SwigObj *"
%typemap(couttype) SWIGTYPE &   "SwigObj *"
%typemap(couttype) SWIGTYPE *&    "SwigObj **"
%typemap(couttype) SWIGTYPE [ANY] "/*SWIGTYPE [ANY]*/ SwigObj **"
%typemap(couttype) SWIGTYPE * [ANY] "/*SWIGTYPE *[ANY] */ SwigObj **"
%typemap(couttype) SWIGTYPE ** "/*SWIGTYPE ** */ SwigObj **"
%typemap(couttype) enum SWIGTYPE "int"
%typemap(couttype) enum SWIGTYPE &, enum SWIGTYPE * "int *"
%typemap(couttype, fragment="fptr_decl") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(couttype, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$1_ltype"
%typemap(couttype, fragment="stdbool_inc") bool & "$1_basetype*"
%typemap(couttype, fragment="stdbool_inc") const bool & "$1_basetype const *"

%typemap(out) short, int, long, long long, char, float, double "$result = $1;"
%typemap(out) void*, short*, int*, long*, long long *, char*, float*, double* "$result = $1;"
%typemap(out) const short, const int, const long, const long long, const char, const float, const double "$result = ($1_ltype) $1;"
%typemap(out) const void *, const short *, const int *, const long *, const long long *, const char *, const float *, const double * "$result = ($1_ltype) $1;"
%typemap(out) unsigned short, unsigned int, unsigned long, unsigned long long, unsigned char, signed char "$result = $1;"
%typemap(out) unsigned short *, unsigned int *, unsigned long *, unsigned long long *, unsigned char *, signed char * "$result = $1;"
%typemap(out) short &, int &, long &, long long &, char &, float &, double & "$result = $1;"
%typemap(out) unsigned short &, unsigned int &, unsigned long &, unsigned long long &, unsigned char &, signed char & "$result = $1;"
%typemap(out) const short &, const int &, const long &, const long long &, const char &, const float &, const double & "$result = $1;"
%typemap(out) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned long long &, const unsigned char &, const signed char & "$result = $1;"
%typemap(out) short *&, int *&, long *&, long long *&, char *&, float *&, double *& "$result = $1;"
%typemap(out) const short *&, const int *&, const long *&, const long long *&, const char *&, const float *&, const double *& "$result = $1;"
%typemap(out) short [ANY], int [ANY], long [ANY], long long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY], signed char [ANY], unsigned int [ANY] "$result = $1;"
%typemap(out) short * [ANY], int * [ANY], long * [ANY], long long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$result = $1;"
%typemap(out) short **, int **, long **, long long **, char **, float **, double ** "$result = $1;"
%typemap(out) void ""

%typemap(out, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$result = ($1_ltype) $1;"
%typemap(out, fragment="stdbool_inc") bool &, const bool & "$result = $1;"

%typemap(out) enum SWIGTYPE "$result = (int) $1;"
%typemap(out) enum SWIGTYPE &, enum SWIGTYPE * "$result = (int *) &$1;"

%typemap(out) SWIGTYPE (CLASS::*) {
  *($&1_ltype) &$result = $1; 
}

%typemap(out) SWIGTYPE *&, SWIGTYPE ** {
  static SwigObj* _ptr = (SwigObj*) SWIG_create_object(SWIG_STR($1_basetype));
  $result = &_ptr;
  (*result)->obj = (void*) $1;
}

%typemap(out) SWIGTYPE {
  $result = (SwigObj*) SWIG_create_object(SWIG_STR($1_basetype));
  $result->obj = (void*) &$1;
}

%typemap(out) SWIGTYPE *, SWIGTYPE & {
  $result = (SwigObj*) SWIG_create_object(SWIG_STR($1_basetype));
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

// typemaps for 'cppresult'
// this needs refactoring -- see 'couttype' typemaps

%typemap(cppouttype) void, short, int, long, long long, char, float, double "$1_ltype"
%typemap(cppouttype) unsigned short, unsigned int, unsigned long, unsigned long long, unsigned char, signed char "$1_ltype"
%typemap(cppouttype) void *, short *, int *, long *, long long *, char *, float *, double*, unsigned char *, unsigned int *, unsigned long *, unsigned char *, signed char * "$1_ltype"
%typemap(cppouttype) const short, const int, const long, const long long, const char, const float, const double "$1_ltype"
%typemap(cppouttype) const void *, const short *, const int *, const long *, const long long *, const char *, const float *, const double * "$1_ltype"
%typemap(cppouttype) short &, int &, long &, long long &, char &, float &, double &, unsigned short &, unsigned int &, unsigned long &, unsigned long long &, unsigned char &, signed char & "$1_ltype"
%typemap(cppouttype) const short &, const int &, const long &, const long long &, const char &, const float &, const double & "$1_ltype"
%typemap(cppouttype) short *&, int *&, long *&, long long *&, char *&, float *&, double *& "$1_ltype"
%typemap(cppouttype) const short *&, const int *&, const long *&, const long long *&, const char *&, const float *&, const double *& "$1_ltype"
%typemap(cppouttype) short [ANY], int [ANY], long [ANY], long long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY], signed char [ANY], unsigned int [ANY] "$1_ltype"

%typemap(cppouttype) const char* "const char *"
%typemap(cppouttype) const unsigned char* "const unsigned char *"
%typemap(cppouttype) const signed char* "const signed char *"
%typemap(cppouttype) short * [ANY], int * [ANY], long * [ANY], long long * [ANY], char * [ANY], float * [ANY], double * [ANY] "/*builtin * [ANY]*/ $1_ltype"

%typemap(cppouttype) short **, int **, long **, long long **, char **, float **, double ** "$1_ltype"
%typemap(cppouttype, retobj="1") SWIGTYPE      "$1_ltype *"
%typemap(cppouttype) SWIGTYPE *    "$1_ltype"
%typemap(cppouttype) const SWIGTYPE * "const $1_ltype"
%typemap(cppouttype) SWIGTYPE &    "$1_ltype"
%typemap(cppouttype) SWIGTYPE *&   "$1_ltype"
%typemap(cppouttype) SWIGTYPE [ANY] "$1_ltype"
%typemap(cppouttype) SWIGTYPE * [ANY] "/*SWIGTYPE *[ANY] */ $1_ltype"
%typemap(cppouttype) SWIGTYPE ** "/*SWIGTYPE ** */ $1_basetype **"
%typemap(cppouttype, retobj="1") enum SWIGTYPE "int"
%typemap(cppouttype) enum SWIGTYPE * "int *"
%typemap(cppouttype) enum SWIGTYPE & "int *"
%typemap(cppouttype, fragment="fptr_decl") SWIGTYPE (CLASS::*) "$1_ltype"

%typemap(cppouttype, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$1_ltype"
%typemap(cppouttype, fragment="stdbool_inc") bool & "$1_basetype*"
%typemap(cppouttype, fragment="stdbool_inc") const bool & "$1_basetype const *"

// templates typemaps - in progress...
/*
%typemap(ctype) SWIGTYPE<T>, const SWIGTYPE<T> &, const SWIGTYPE<T> * "SwigObj *"
%typemap(in) SWIGTYPE<T>, const SWIGTYPE<T> &, const SWIGTYPE<T> * { $1 = ($1_ltype) $input; }

%typemap(out) SWIGTYPE<T>, const SWIGTYPE<T> &, const SWIGTYPE<T> * "$result = ($1_ltype) $1;"

%typemap(cppouttype) SWIGTYPE<T>, const SWIGTYPE<T> &, const SWIGTYPE<T> * "$1_ltype"
*/

//%define size_t unsigned long %enddef

%apply unsigned long { size_t };
%apply const unsigned long & { const size_t & };

#ifdef SWIG_CPPMODE

  #ifdef SWIG_C_EXCEPT
  
%insert("runtime") %{
typedef struct {
  void *obj;
  const char **typenames;
} SwigObj;
%}

%insert("proxy_header") %{
typedef struct {
  void *obj;
  const char **typenames;
} SwigObj;
%}

%include "cexcept.swg"
    
  #else
    
%insert("runtime") %{
typedef struct {
  void *obj;
} SwigObj;

#ifdef __cplusplus
extern "C" {
#endif
SWIGEXPORTC int SWIG_exit(int code) { exit(code); }
#ifdef __cplusplus
}
#endif
%}

%insert("proxy_header") %{
typedef struct {
  void *obj;
} SwigObj;
%}
  
  #endif
  
%insert(runtime) %{    
  SwigObj *SWIG_temporary = (SwigObj *) malloc(sizeof(SwigObj));
%}

%insert("proxy_header") %{
#include <stdarg.h>

#define SWIG_MAKE_DELETE(Name,Obj) void Name(Obj *op1, ...) {\
  Obj *obj;\
  va_list vl;\
  va_start(vl, op1);\
  do {\
    obj = va_arg(vl, Obj *);\
    delete_##Obj(obj);\
  } while (obj);\
  va_end(vl);\
}
%}

#else

%insert("runtime") %{
#ifdef __cplusplus
extern "C" {
#endif
SWIGEXPORTC int SWIG_exit(int code) { exit(code); }
#ifdef __cplusplus
}
#endif
%}

#endif
