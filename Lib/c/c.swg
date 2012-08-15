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

// typemaps for proxy function parameters

// void
%typemap(proxy) void "void"
%typemap(proxy) void*, void&, void[ANY], void[] "void *"
%typemap(proxy) const void&, const void*, const void[ANY], const void[] "const void *"
%typemap(proxy) void**, void*&, void*[ANY], void[ANY][ANY] "void **"
%typemap(proxy) const void**, const void*&, const void*[ANY], const void[ANY][ANY] "const void **"
// constant pointers
%typemap(proxy) void* * const "void* * const"
%typemap(proxy) const void* * const "const void* * const"

// short
%typemap(proxy) short, const short "short"
%typemap(proxy) short*, short&, short[ANY], short[] "short *"
%typemap(proxy) const short&, const short*, const short[ANY], const short[] "const short *"
%typemap(proxy) unsigned short "unsigned short"
%typemap(proxy) const unsigned short "const unsigned short"
%typemap(proxy) unsigned short*, unsigned short&, unsigned short*, unsigned short[ANY], unsigned short[] "unsigned short *"
%typemap(proxy) const unsigned short*, const unsigned short&, const unsigned short[ANY], const unsigned short[] "const unsigned short *"
%typemap(proxy) short**, short*&, short*[ANY], short[ANY][ANY] "short **"
%typemap(proxy) const short**, const short*&, const short*[ANY], const short[ANY][ANY] "const short **"
%typemap(proxy) unsigned short**, unsigned short*&, unsigned short*[ANY], unsigned short[ANY][ANY] "unsigned short **"
%typemap(proxy) const unsigned short**,const unsigned short*&, const unsigned short[ANY][ANY] "const unsigned short **"
// constant pointers
%typemap(proxy) short * const "short * const"
%typemap(proxy) short* * const "short* * const"
%typemap(proxy) const short* * const "const short* * const"
%typemap(proxy) unsigned short * const "unsigned short * const"
%typemap(proxy) unsigned short* * const "unsigned short* * const"
%typemap(proxy) const unsigned short* * const "const unsigned short* * const"

// int
%typemap(proxy) int, const int "int"
%typemap(proxy) int*, int&, int[ANY], int[] "int *"
%typemap(proxy) const int&, const int*, const int[ANY], const int[] "const int *"
%typemap(proxy) unsigned int "unsigned int"
%typemap(proxy) const unsigned int "unsigned int"
%typemap(proxy) unsigned int*, unsigned int&, unsigned int*, unsigned int[ANY], unsigned int[] "unsigned int *"
%typemap(proxy) const unsigned int*, const unsigned int&, const unsigned int[ANY], const unsigned int[] "const unsigned int *"
%typemap(proxy) int**, int*&, int*[ANY], int[ANY][ANY] "int **"
%typemap(proxy) const int**, const int*&, const int*[ANY], const int[ANY][ANY] "const int **"
%typemap(proxy) unsigned int**, unsigned int*&, unsigned int*[ANY], unsigned int[ANY][ANY] "unsigned int **"
%typemap(proxy) const unsigned int**,const unsigned int*&, const unsigned int[ANY][ANY] "const unsigned int **"
// constant pointers
%typemap(proxy) int * const "int * const"
%typemap(proxy) int* * const "int* * const"
%typemap(proxy) const int* * const "const int* * const"
%typemap(proxy) unsigned int * const "unsigned int * const"
%typemap(proxy) unsigned int* * const "unsigned int* * const"
%typemap(proxy) const unsigned int* * const "const unsigned int* * const"

// long
%typemap(proxy) long, const long "long"
%typemap(proxy) long*, long&, long[ANY], long[] "long *"
%typemap(proxy) const long&, const long*, const long[ANY], const long[] "const long *"
%typemap(proxy) unsigned long "unsigned long"
%typemap(proxy) const unsigned long "const unsigned long"
%typemap(proxy) unsigned long*, unsigned long&, unsigned long*, unsigned long[ANY], unsigned long[] "unsigned long *"
%typemap(proxy) const unsigned long*, const unsigned long&, const unsigned long[ANY], const unsigned long[] "const unsigned long *"
%typemap(proxy) long**, long*&, long*[ANY], long[ANY][ANY] "long **"
%typemap(proxy) const long**, const long*&, const long*[ANY], const long[ANY][ANY] "const long **"
%typemap(proxy) unsigned long**, unsigned long*&, unsigned long*[ANY], unsigned long[ANY][ANY] "unsigned long **"
%typemap(proxy) const unsigned long**,const unsigned long*&, const unsigned long[ANY][ANY] "const unsigned long **"
// constant pointers
%typemap(proxy) long * const "long * const"
%typemap(proxy) long* * const "long* * const"
%typemap(proxy) const long* * const "const long* * const"
%typemap(proxy) unsigned long * const "unsigned long * const"
%typemap(proxy) unsigned long* * const "unsigned long* * const"
%typemap(proxy) const unsigned long* * const "const unsigned long* * const"

// long long
%typemap(proxy) long long, const long long "long long"
%typemap(proxy) long long*, long long&, long long[ANY], long long[] "long long *"
%typemap(proxy) const long long&, const long long*, const long long[ANY], const long long[] "const long long *"
%typemap(proxy) unsigned long long "unsigned long long"
%typemap(proxy) const unsigned long long "const unsigned long long"
%typemap(proxy) unsigned long long*, unsigned long long&, unsigned long long*, unsigned long long[ANY], unsigned long long[] "unsigned long long *"
%typemap(proxy) const unsigned long long*, const unsigned long long&, const unsigned long long[ANY], const unsigned long long[] "const unsigned long long *"
%typemap(proxy) long long**, long long*&, long long*[ANY], long long[ANY][ANY] "long long **"
%typemap(proxy) const long long**, const long long*&, const long long*[ANY], const long long[ANY][ANY] "const long long **"
%typemap(proxy) unsigned long long**, unsigned long long*&, unsigned long long*[ANY], unsigned long long[ANY][ANY] "unsigned long long **"
%typemap(proxy) const unsigned long long**,const unsigned long long*&, const unsigned long long[ANY][ANY] "const unsigned long long **"
// constant pointers
%typemap(proxy) long long * const "long long * const"
%typemap(proxy) long long* * const "long long* * const"
%typemap(proxy) const long long* * const "const long long* * const"
%typemap(proxy) unsigned long long * const "unsigned long long * const"
%typemap(proxy) unsigned long long* * const "unsigned long long* * const"
%typemap(proxy) const unsigned long long* * const "const unsigned long long* * const"

// char: signed/unsigned
%typemap(proxy) char, const char "char"
%typemap(proxy) char*, char&, char[ANY], char[] "$1_ltype"
%typemap(proxy) const char&, const char*, const char[ANY], const char[] "const char *"
%typemap(proxy) char**, char*&, char*[ANY], char[ANY][ANY] "char **"
%typemap(proxy) const char**, const char*&, const char*[ANY], const char[ANY][ANY] "char **"
%typemap(proxy) signed char**, signed char*&, signed char*[ANY], signed char[ANY][ANY] "signed char **"
%typemap(proxy) const signed char**, const signed char*&, const signed char[ANY][ANY] "const signed char **"
%typemap(proxy) signed char "signed char"
%typemap(proxy) const signed char "const signed char"
%typemap(proxy) signed char*, signed char&, signed char*, signed char[ANY], signed char[] "signed char *"
%typemap(proxy) const signed char*, const signed char&, const signed char[ANY], const signed char[] "const $1_ltype"
%typemap(proxy) unsigned char**, unsigned char*&, unsigned char*[ANY], unsigned char[ANY][ANY] "unsigned char **"
%typemap(proxy) const unsigned char**, const unsigned char*&, const unsigned char[ANY][ANY] "const unsigned char **"
%typemap(proxy) unsigned char "unsigned char"
%typemap(proxy) const unsigned char "const unsigned char"
%typemap(proxy) unsigned char*, unsigned char&, unsigned char*, unsigned char[ANY], unsigned char[] "unsigned char *"
%typemap(proxy) const unsigned char*, const unsigned char&, const unsigned char[ANY], const unsigned char[] "const unsigned char *"
// constant pointers
%typemap(proxy) char * const "char * const"
%typemap(proxy) char* * const "char* * const"
%typemap(proxy) const char* * const "const char* * const"
%typemap(proxy) unsigned char * const "unsigned char * const"
%typemap(proxy) unsigned char* * const "unsigned char* * const"
%typemap(proxy) const unsigned char* * const "const unsigned char* * const"

// float
%typemap(proxy) float, const float "float"
%typemap(proxy) float*, float&, float[ANY], float[] "float *"
%typemap(proxy) const float&, const float*, const float[ANY], const float[] "const float *"
%typemap(proxy) float**, float*&, const float*&, float*[ANY], float[ANY][ANY] "float **"
%typemap(proxy) const float**, const float*[ANY], const float[ANY][ANY] "const float **"
// constant pointers
%typemap(proxy) float * const "float * const"
%typemap(proxy) float* * const "float* * const"
%typemap(proxy) const float* * const "const float* * const"
%typemap(proxy) unsigned float * const "unsigned float * const"
%typemap(proxy) unsigned float* * const "unsigned float* * const"
%typemap(proxy) const unsigned float* * const "const unsigned float* * const"

// double
%typemap(proxy) double, const double "double"
%typemap(proxy) double*, double&, double[ANY], double[] "double *"
%typemap(proxy) const double&, const double*, const double[ANY], const double[] "const double *"
%typemap(proxy) double**, double*&, const double*&, double*[ANY], double[ANY][ANY] "double **"
%typemap(proxy) const double**, const double*[ANY], const double[ANY][ANY] "const double **"
// constant pointers
%typemap(proxy) double * const "double * const"
%typemap(proxy) double* * const "double* * const"
%typemap(proxy) const double* * const "const double* * const"
%typemap(proxy) unsigned double * const "unsigned double * const"
%typemap(proxy) unsigned double* * const "unsigned double* * const"
%typemap(proxy) const unsigned double* * const "const unsigned double* * const"

// size_t
%typemap(proxy) size_t, const size_t "size_t"
%typemap(proxy) size_t*, size_t&, size_t[ANY], size_t[] "size_t *"
%typemap(proxy) const size_t&, const size_t*, const size_t[ANY], const size_t[] "const size_t *"
%typemap(proxy) size_t**, size_t*&, size_t*[ANY], size_t[ANY][ANY] "size_t **"
%typemap(proxy) const size_t**, const size_t*&, const size_t*[ANY], const size_t[ANY][ANY] "const size_t **"
// constant pointers
%typemap(proxy) size_t * const "size_t * const"
%typemap(proxy) size_t* * const "size_t* * const"
%typemap(proxy) const size_t* * const "const size_t* * const"

// objects
%typemap(proxy) SWIGTYPE      "$&resolved_type*"
%typemap(proxy) SWIGTYPE *    "$resolved_type*"
%typemap(proxy) SWIGTYPE &    "$*resolved_type*"
%typemap(proxy) SWIGTYPE *&    "$resolved_type**"
%typemap(proxy) SWIGTYPE [ANY] "/*SWIGTYPE [ANY]*/ $1_ltype **"
%typemap(proxy) SWIGTYPE * [ANY] "/*SWIGTYPE *[ANY] */ $1_ltype **"
%typemap(proxy) SWIGTYPE ** "/*SWIGTYPE ** */ $1_ltype **"
%typemap(proxy) enum SWIGTYPE "int"
%typemap(proxy) enum SWIGTYPE &, enum SWIGTYPE * "int *"
%typemap(proxy, fragment="fptr_decl") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(proxy, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$1_ltype"
%typemap(proxy, fragment="stdbool_inc") bool & "$1_basetype*"
%typemap(proxy, fragment="stdbool_inc") const bool & "$1_basetype const *"

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
// constant pointers
%typemap(ctype) short* * const, int* * const, long* * const, long long* * const, char* * const, float* * const, double* * const "$1_ltype"
%typemap(ctype) const short* * const, const int* * const, const long* * const, const long long* * const, const char* * const, const float* * const, const double* * const "$1_ltype"

// size_t
%typemap(ctype) size_t, const size_t "size_t"
%typemap(ctype) size_t*, size_t&, size_t[ANY], size_t[] "size_t *"
%typemap(ctype) const size_t&, const size_t*, const size_t[ANY], const size_t[] "const size_t *"
%typemap(ctype) size_t**, size_t*&, size_t*[ANY], size_t[ANY][ANY] "size_t **"
%typemap(ctype) const size_t**, const size_t*&, const size_t*[ANY], const size_t[ANY][ANY] "const size_t **"
// constant pointers
%typemap(ctype) size_t * const "size_t * const"
%typemap(ctype) size_t* * const "size_t* * const"
%typemap(ctype) const size_t* * const "const size_t* * const"

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
%typemap(ctype) enum SWIGTYPE &, enum SWIGTYPE *  "int *"
%typemap(ctype, fragment="fptr_decl", fragment="fptr_decl_proxy") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(ctype, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool *, bool * [ANY] "$1_type"
%typemap(ctype, fragment="stdbool_inc") bool & "$1_ltype"
%typemap(ctype, fragment="stdbool_inc") const bool & "$1_ltype const"

// typemaps for function parameters
%typemap(wrap_call) void, short, int, long, long long, char, float, double ""
%typemap(wrap_call) unsigned short, unsigned int, unsigned long, unsigned long long, unsigned char ""
%typemap(wrap_call) void *, short *, int *, long *, long long *, char *, float *, double * ""
%typemap(wrap_call) void **, short **, int **, long **, long long **, char **, float **, double ** ""
%typemap(wrap_call) unsigned short *, unsigned int *, unsigned long *, unsigned long long *, unsigned char * ""
%typemap(wrap_call) unsigned short **, unsigned int **, unsigned long **, unsigned long long **, unsigned char ** ""
%typemap(wrap_call) short &, int &, long &, long long &, char &, float &, double &  ""
%typemap(wrap_call) unsigned short &, unsigned int &, unsigned long &, unsigned long long &, unsigned char & ""
%typemap(wrap_call) const short, const int, const long, const long long, const char, const float, const double  ""
%typemap(wrap_call) const short &, const int &, const long &, const long long &, const char &, const float &, const double & ""
%typemap(wrap_call) const unsigned short, const unsigned int, const unsigned long, const unsigned long long, const unsigned char ""
%typemap(wrap_call) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned long long &, const unsigned char & ""
%typemap(wrap_call) const void *, const short *, const int *, const long *, const long long *, const char *, const float *, const double * ""
%typemap(wrap_call) short *&, int *&, long *&, long long *&, char *&, float *&, double *& ""
%typemap(wrap_call) const short *&, const int *&, const long *&, const long long *&, const char *&, const float *&, const double *& " **"
%typemap(wrap_call) short [ANY], int [ANY], long [ANY], long long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY], unsigned int [ANY] "/*aaa*/ "
%typemap(wrap_call) void * [ANY], short * [ANY], int * [ANY], long * [ANY], long long * [ANY], char * [ANY], float * [ANY], double * [ANY] "/*bbb*/ "

// size_t
%typemap(wrap_call) size_t, const size_t ""
%typemap(wrap_call) size_t*, size_t&, size_t[ANY], size_t[] ""
%typemap(wrap_call) const size_t&, const size_t*, const size_t[ANY], const size_t[] ""
%typemap(wrap_call) size_t**, size_t*&, size_t*[ANY], size_t[ANY][ANY] ""
%typemap(wrap_call) const size_t**, const size_t*&, const size_t*[ANY], const size_t[ANY][ANY] ""

// special cases of array passing - does not intended to be used for objects
%typemap(wrap_call) SWIGTYPE [] ""
%typemap(wrap_call) SWIGTYPE ((&)[ANY]) " **"

%typemap(wrap_call) void [ANY][ANY], short [ANY][ANY], int [ANY][ANY], long [ANY][ANY], char [ANY][ANY], float [ANY][ANY], double [ANY][ANY] ""
%typemap(wrap_call) SWIGTYPE         "(SwigObj *)"
%typemap(wrap_call) SWIGTYPE *       "(SwigObj *)"
%typemap(wrap_call) SWIGTYPE &       "(SwigObj *)"
%typemap(wrap_call) SWIGTYPE [ANY][ANY], SWIGTYPE ** "/* whoa */ (SwigObj ***)"
%typemap(wrap_call) SWIGTYPE *[ANY]  "/*ooooh*/ (SwigObj **)"
%typemap(wrap_call) SWIGTYPE *&      "/* *& */ (SwigObj **)"
%typemap(wrap_call) enum SWIGTYPE    ""
%typemap(wrap_call) enum SWIGTYPE &, enum SWIGTYPE *  ""
%typemap(wrap_call, fragment="fptr_decl", fragment="fptr_decl_proxy") SWIGTYPE (CLASS::*) "(SWIG_CPP_FP)"

%typemap(wrap_call, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool *, bool * [ANY] "$1_type"
%typemap(wrap_call, fragment="stdbool_inc") bool & ""
%typemap(wrap_call, fragment="stdbool_inc") const bool & " const"

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

// constant pointers
%typemap(in) short* * const, int* * const, long* * const, long long* * const, char* * const, float* * const, double* * const "$1 = ($1_ltype) $input;"
%typemap(in) const short* * const, const int* * const, const long* * const, const long long* * const, const char* * const, const float* * const, const double* * const "$1 = ($1_ltype) $input;"

// size_t
%typemap(in) size_t, const size_t "$1 = (size_t) $input;"
%typemap(in) size_t*, size_t&, size_t[ANY], size_t[] "$1 = (size_t *) $input;"
%typemap(in) const size_t&, const size_t*, const size_t[ANY], const size_t[] "$1 = (const size_t *) &$input;"
%typemap(in) size_t**, size_t*&, size_t*[ANY], size_t[ANY][ANY] "$1 = (size_t **) $input;"
%typemap(in) const size_t**, const size_t*&, const size_t*[ANY], const size_t[ANY][ANY] "$1 = (const size_t **) $input;"
// constant pointers
%typemap(in) size_t * const "$1 = (size_t) $input;"
%typemap(in) size_t* * const "$1 = (size_t *) $input;"
%typemap(in) const size_t* * const "$1 = (const size_t **) $input;"

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
// constant pointers
%typemap(couttype) void * const "void * const"
%typemap(couttype) void* * const * const "void* *"
%typemap(couttype) const void* * const "const void* *"

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
// constant pointers
%typemap(couttype) short * const "short *"
%typemap(couttype) short* * const "short* *"
%typemap(couttype) const short* * const "const short* *"
%typemap(couttype) unsigned short * const "unsigned short *"
%typemap(couttype) unsigned short* * const "unsigned short* *"
%typemap(couttype) const unsigned short* * const "const unsigned short* *"

// int
%typemap(couttype) int, const int "int"
%typemap(couttype) int*, int&, int[ANY], int[] "int *"
%typemap(couttype) const int&, const int*, const int[ANY], const int[] "const int *"
%typemap(couttype) unsigned int "unsigned int"
%typemap(couttype) const unsigned int "unsigned int"
%typemap(couttype) unsigned int*, unsigned int&, unsigned int*, unsigned int[ANY], unsigned int[] "unsigned int *"
%typemap(couttype) const unsigned int*, const unsigned int&, const unsigned int[ANY], const unsigned int[] "const unsigned int *"
%typemap(couttype) int**, int*&, int*[ANY], int[ANY][ANY] "int **"
%typemap(couttype) const int**, const int*&, int *const &, const int*[ANY], const int[ANY][ANY] "const int **"
%typemap(couttype) unsigned int**, unsigned int*&, unsigned int*[ANY], unsigned int[ANY][ANY] "unsigned int **"
%typemap(couttype) const unsigned int**,const unsigned int*&, const unsigned int[ANY][ANY] "const unsigned int **"
// constant pointers
%typemap(couttype) int * const "int *"
%typemap(couttype) int* * const "int* *"
%typemap(couttype) const int* * const "const int* *"
%typemap(couttype) unsigned int * const "unsigned int *"
%typemap(couttype) unsigned int* * const "unsigned int* *"
%typemap(couttype) const unsigned int* * const "const unsigned int* *"

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
// constant pointers
%typemap(couttype) long * const "long *"
%typemap(couttype) long* * const "long* *"
%typemap(couttype) const long* * const "const long* *"
%typemap(couttype) unsigned long * const "unsigned long *"
%typemap(couttype) unsigned long* * const "unsigned long* *"
%typemap(couttype) const unsigned long* * const "const unsigned long* *"

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
// constant pointers
%typemap(couttype) long long * const "long long *"
%typemap(couttype) long long* * const "long long* *"
%typemap(couttype) const long long* * const "const long long* *"
%typemap(couttype) unsigned long long * const "unsigned long long *"
%typemap(couttype) unsigned long long* * const "unsigned long long* *"
%typemap(couttype) const unsigned long long* * const "const unsigned long long* *"

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
// constant pointers
%typemap(couttype) char * const "char *"
%typemap(couttype) char* * const "char* *"
%typemap(couttype) const char* * const "const char* *"
%typemap(couttype) unsigned char * const "unsigned char *"
%typemap(couttype) unsigned char* * const "unsigned char* *"
%typemap(couttype) const unsigned char* * const "const unsigned char* *"

// float
%typemap(couttype) float, const float "float"
%typemap(couttype) float*, float&, float[ANY], float[] "float *"
%typemap(couttype) const float&, const float*, const float[ANY], const float[] "const float *"
%typemap(couttype) float**, float*&, const float*&, float*[ANY], float[ANY][ANY] "float **"
%typemap(couttype) const float**, const float*[ANY], const float[ANY][ANY] "const float **"
// constant pointers
%typemap(couttype) float * const "float *"
%typemap(couttype) float* * const "float* *"
%typemap(couttype) const float* * const "const float* *"
%typemap(couttype) unsigned float * const "unsigned float *"
%typemap(couttype) unsigned float* * const "unsigned float* *"
%typemap(couttype) const unsigned float* * const "const unsigned float* *"

// double
%typemap(couttype) double, const double "double"
%typemap(couttype) double*, double&, double[ANY], double[] "double *"
%typemap(couttype) const double&, const double*, const double[ANY], const double[] "const double *"
%typemap(couttype) double**, double*&, const double*&, double*[ANY], double[ANY][ANY] "double **"
%typemap(couttype) const double**, const double*[ANY], const double[ANY][ANY] "const double **"
// constant pointers
%typemap(couttype) double * const "double *"
%typemap(couttype) double* * const "double* *"
%typemap(couttype) const double* * const "const double* *"
%typemap(couttype) unsigned double * const "unsigned double *"
%typemap(couttype) unsigned double* * const "unsigned double* *"
%typemap(couttype) const unsigned double* * const "const unsigned double* *"

// size_t
%typemap(couttype) size_t, const size_t "size_t"
%typemap(couttype) size_t*, size_t&, size_t[ANY], size_t[] "size_t *"
%typemap(couttype) const size_t&, const size_t*, const size_t[ANY], const size_t[] "const size_t *"
%typemap(couttype) size_t**, size_t*&, size_t*[ANY], size_t[ANY][ANY] "size_t **"
%typemap(couttype) const size_t**, const size_t*&, const size_t*[ANY], const size_t[ANY][ANY] "const size_t **"
// constant pointers
%typemap(couttype) size_t * const "size_t *"
%typemap(couttype) size_t* * const "size_t* *"
%typemap(couttype) const size_t* * const "const size_t* *"

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

// typemaps for return values

// void
%typemap(proxycouttype) void "void"
%typemap(proxycouttype) void*, const void* "void *"
// constant pointers
%typemap(proxycouttype) void* * const "void* * const"
%typemap(proxycouttype) const void* * const "const void* * const"

// short
%typemap(proxycouttype) short, const short "short"
%typemap(proxycouttype) short*, short&, short[ANY], short[] "short *"
%typemap(proxycouttype) const short&, const short*, const short[ANY], const short[] "const short *"
%typemap(proxycouttype) unsigned short "unsigned short"
%typemap(proxycouttype) const unsigned short "const unsigned short"
%typemap(proxycouttype) unsigned short*, unsigned short&, unsigned short*, unsigned short[ANY], unsigned short[] "unsigned short *"
%typemap(proxycouttype) const unsigned short*, const unsigned short&, const unsigned short[ANY], const unsigned short[] "const unsigned short *"
%typemap(proxycouttype) short**, short*&, short*[ANY], short[ANY][ANY] "short **"
%typemap(proxycouttype) const short**, const short*&, const short*[ANY], const short[ANY][ANY] "const short **"
%typemap(proxycouttype) unsigned short**, unsigned short*&, unsigned short*[ANY], unsigned short[ANY][ANY] "unsigned short **"
%typemap(proxycouttype) const unsigned short**,const unsigned short*&, const unsigned short[ANY][ANY] "const unsigned short **"
// constant pointers
%typemap(proxycouttype) short * const "short * const"
%typemap(proxycouttype) short* * const "short* * const"
%typemap(proxycouttype) const short* * const "const short* * const"
%typemap(proxycouttype) unsigned short * const "unsigned short * const"
%typemap(proxycouttype) unsigned short* * const "unsigned short* * const"
%typemap(proxycouttype) const unsigned short* * const "const unsigned short* * const"

// int
%typemap(proxycouttype) int, const int "int"
%typemap(proxycouttype) int*, int&, int[ANY], int[] "int *"
%typemap(proxycouttype) const int&, const int*, const int[ANY], const int[] "const int *"
%typemap(proxycouttype) unsigned int "unsigned int"
%typemap(proxycouttype) const unsigned int "unsigned int"
%typemap(proxycouttype) unsigned int*, unsigned int&, unsigned int*, unsigned int[ANY], unsigned int[] "unsigned int *"
%typemap(proxycouttype) const unsigned int*, const unsigned int&, const unsigned int[ANY], const unsigned int[] "const unsigned int *"
%typemap(proxycouttype) int**, int*&, int*[ANY], int[ANY][ANY] "int **"
%typemap(proxycouttype) const int**, const int*&, const int*[ANY], const int[ANY][ANY] "const int **"
%typemap(proxycouttype) unsigned int**, unsigned int*&, unsigned int*[ANY], unsigned int[ANY][ANY] "unsigned int **"
%typemap(proxycouttype) const unsigned int**,const unsigned int*&, const unsigned int[ANY][ANY] "const unsigned int **"
// constant pointers
%typemap(proxycouttype) int * const "int * const"
%typemap(proxycouttype) int* * const "int* * const"
%typemap(proxycouttype) const int* * const "const int* * const"
%typemap(proxycouttype) unsigned int * const "unsigned int * const"
%typemap(proxycouttype) unsigned int* * const "unsigned int* * const"
%typemap(proxycouttype) const unsigned int* * const "const unsigned int* * const"

// long
%typemap(proxycouttype) long, const long "long"
%typemap(proxycouttype) long*, long&, long[ANY], long[] "long *"
%typemap(proxycouttype) const long&, const long*, const long[ANY], const long[] "const long *"
%typemap(proxycouttype) unsigned long "unsigned long"
%typemap(proxycouttype) const unsigned long "const unsigned long"
%typemap(proxycouttype) unsigned long*, unsigned long&, unsigned long*, unsigned long[ANY], unsigned long[] "unsigned long *"
%typemap(proxycouttype) const unsigned long*, const unsigned long&, const unsigned long[ANY], const unsigned long[] "const unsigned long *"
%typemap(proxycouttype) long**, long*&, long*[ANY], long[ANY][ANY] "long **"
%typemap(proxycouttype) const long**, const long*&, const long*[ANY], const long[ANY][ANY] "const long **"
%typemap(proxycouttype) unsigned long**, unsigned long*&, unsigned long*[ANY], unsigned long[ANY][ANY] "unsigned long **"
%typemap(proxycouttype) const unsigned long**,const unsigned long*&, const unsigned long[ANY][ANY] "const unsigned long **"
// constant pointers
%typemap(proxycouttype) long * const "long * const"
%typemap(proxycouttype) long* * const "long* * const"
%typemap(proxycouttype) const long* * const "const long* * const"
%typemap(proxycouttype) unsigned long * const "unsigned long * const"
%typemap(proxycouttype) unsigned long* * const "unsigned long* * const"
%typemap(proxycouttype) const unsigned long* * const "const unsigned long* * const"

// long long
%typemap(proxycouttype) long long, const long long "long long"
%typemap(proxycouttype) long long*, long long&, long long[ANY], long long[] "long long *"
%typemap(proxycouttype) const long long&, const long long*, const long long[ANY], const long long[] "const long long *"
%typemap(proxycouttype) unsigned long long "unsigned long long"
%typemap(proxycouttype) const unsigned long long "const unsigned long long"
%typemap(proxycouttype) unsigned long long*, unsigned long long&, unsigned long long*, unsigned long long[ANY], unsigned long long[] "unsigned long long *"
%typemap(proxycouttype) const unsigned long long*, const unsigned long long&, const unsigned long long[ANY], const unsigned long long[] "const unsigned long long *"
%typemap(proxycouttype) long long**, long long*&, long long*[ANY], long long[ANY][ANY] "long long **"
%typemap(proxycouttype) const long long**, const long long*&, const long long*[ANY], const long long[ANY][ANY] "const long long **"
%typemap(proxycouttype) unsigned long long**, unsigned long long*&, unsigned long long*[ANY], unsigned long long[ANY][ANY] "unsigned long long **"
%typemap(proxycouttype) const unsigned long long**,const unsigned long long*&, const unsigned long long[ANY][ANY] "const unsigned long long **"
// constant pointers
%typemap(proxycouttype) long long * const "long long * const"
%typemap(proxycouttype) long long* * const "long long* * const"
%typemap(proxycouttype) const long long* * const "const long long* * const"
%typemap(proxycouttype) unsigned long long * const "unsigned long long * const"
%typemap(proxycouttype) unsigned long long* * const "unsigned long long* * const"
%typemap(proxycouttype) const unsigned long long* * const "const unsigned long long* * const"

// char: signed/unsigned
%typemap(proxycouttype) char, const char "char"
%typemap(proxycouttype) char*, char&, char[ANY], char[] "$1_ltype"
%typemap(proxycouttype) const char&, const char*, const char[ANY], const char[] "const char *"
%typemap(proxycouttype) char**, char*&, char*[ANY], char[ANY][ANY] "char **"
%typemap(proxycouttype) const char**, const char*&, const char*[ANY], const char[ANY][ANY] "char **"
%typemap(proxycouttype) signed char**, signed char*&, signed char*[ANY], signed char[ANY][ANY] "signed char **"
%typemap(proxycouttype) const signed char**, const signed char*&, const signed char[ANY][ANY] "const signed char **"
%typemap(proxycouttype) signed char "signed char"
%typemap(proxycouttype) const signed char "const signed char"
%typemap(proxycouttype) signed char*, signed char&, signed char*, signed char[ANY], signed char[] "signed char *"
%typemap(proxycouttype) const signed char*, const signed char&, const signed char[ANY], const signed char[] "const $1_ltype"
%typemap(proxycouttype) unsigned char**, unsigned char*&, unsigned char*[ANY], unsigned char[ANY][ANY] "unsigned char **"
%typemap(proxycouttype) const unsigned char**, const unsigned char*&, const unsigned char[ANY][ANY] "const unsigned char **"
%typemap(proxycouttype) unsigned char "unsigned char"
%typemap(proxycouttype) const unsigned char "const unsigned char"
%typemap(proxycouttype) unsigned char*, unsigned char&, unsigned char*, unsigned char[ANY], unsigned char[] "unsigned char *"
%typemap(proxycouttype) const unsigned char*, const unsigned char&, const unsigned char[ANY], const unsigned char[] "const unsigned char *"
// constant pointers
%typemap(proxycouttype) char * const "char * const"
%typemap(proxycouttype) char* * const "char* * const"
%typemap(proxycouttype) const char* * const "const char* * const"
%typemap(proxycouttype) unsigned char * const "unsigned char * const"
%typemap(proxycouttype) unsigned char* * const "unsigned char* * const"
%typemap(proxycouttype) const unsigned char* * const "const unsigned char* * const"

// float
%typemap(proxycouttype) float, const float "float"
%typemap(proxycouttype) float*, float&, float[ANY], float[] "float *"
%typemap(proxycouttype) const float&, const float*, const float[ANY], const float[] "const float *"
%typemap(proxycouttype) float**, float*&, const float*&, float*[ANY], float[ANY][ANY] "float **"
%typemap(proxycouttype) const float**, const float*[ANY], const float[ANY][ANY] "const float **"
// constant pointers
%typemap(proxycouttype) float * const "float * const"
%typemap(proxycouttype) float* * const "float* * const"
%typemap(proxycouttype) const float* * const "const float* * const"
%typemap(proxycouttype) unsigned float * const "unsigned float * const"
%typemap(proxycouttype) unsigned float* * const "unsigned float* * const"
%typemap(proxycouttype) const unsigned float* * const "const unsigned float* * const"

// double
%typemap(proxycouttype) double, const double "double"
%typemap(proxycouttype) double*, double&, double[ANY], double[] "double *"
%typemap(proxycouttype) const double&, const double*, const double[ANY], const double[] "const double *"
%typemap(proxycouttype) double**, double*&, const double*&, double*[ANY], double[ANY][ANY] "double **"
%typemap(proxycouttype) const double**, const double*[ANY], const double[ANY][ANY] "const double **"
// constant pointers
%typemap(proxycouttype) double * const "double * const"
%typemap(proxycouttype) double* * const "double* * const"
%typemap(proxycouttype) const double* * const "const double* * const"
%typemap(proxycouttype) unsigned double * const "unsigned double * const"
%typemap(proxycouttype) unsigned double* * const "unsigned double* * const"
%typemap(proxycouttype) const unsigned double* * const "const unsigned double* * const"

// size_t
%typemap(proxycouttype) size_t, const size_t "size_t"
%typemap(proxycouttype) size_t*, size_t&, size_t[ANY], size_t[] "size_t *"
%typemap(proxycouttype) const size_t&, const size_t*, const size_t[ANY], const size_t[] "const size_t *"
%typemap(proxycouttype) size_t**, size_t*&, size_t*[ANY], size_t[ANY][ANY] "size_t **"
%typemap(proxycouttype) const size_t**, const size_t*&, const size_t*[ANY], const size_t[ANY][ANY] "const size_t **"
// constant pointers
%typemap(proxycouttype) size_t * const "size_t * const"
%typemap(proxycouttype) size_t* * const "size_t* * const"
%typemap(proxycouttype) const size_t* * const "const size_t* * const"

// objects
%typemap(proxycouttype) SWIGTYPE      "$&resolved_type*"
%typemap(proxycouttype) SWIGTYPE *    "$resolved_type*"
%typemap(proxycouttype) SWIGTYPE &    "$*resolved_type*"
%typemap(proxycouttype) SWIGTYPE *&    "$resolved_type**"
%typemap(proxycouttype) SWIGTYPE [ANY] "/*SWIGTYPE [ANY]*/ $1_ltype **"
%typemap(proxycouttype) SWIGTYPE * [ANY] "/*SWIGTYPE *[ANY] */ $1_ltype **"
%typemap(proxycouttype) SWIGTYPE ** "/*SWIGTYPE ** */ $1_ltype **"
%typemap(proxycouttype) enum SWIGTYPE "int"
%typemap(proxycouttype) enum SWIGTYPE &, enum SWIGTYPE * "int *"
%typemap(proxycouttype, fragment="fptr_decl") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(proxycouttype, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$1_ltype"
%typemap(proxycouttype, fragment="stdbool_inc") bool & "$1_basetype*"
%typemap(proxycouttype, fragment="stdbool_inc") const bool & "$1_basetype const *"

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

// constant pointers
%typemap(out) short* * const, int* * const, long* * const, long long* * const, char* * const, float* * const, double* * const "$result = ($1_ltype) $1;"
%typemap(out) const short* * const, const int* * const, const long* * const, const long long* * const, const char* * const, const float* * const, const double* * const "$result = ($1_ltype) $1;"

// size_t
%typemap(out) size_t, const size_t "$result = (size_t) $1;"
%typemap(out) size_t*, size_t&, size_t[ANY], size_t[] "$result = (size_t *) $1;"
%typemap(out) const size_t&, const size_t*, const size_t[ANY], const size_t[] "$result = (const size_t *) &$1;"
%typemap(out) size_t**, size_t*&, size_t*[ANY], size_t[ANY][ANY] "$result = (size_t **) $1;"
%typemap(out) const size_t**, const size_t*&, const size_t*[ANY], const size_t[ANY][ANY] "$result = (const size_t **) $1;"
// constant pointers
%typemap(out) size_t * const "$result = (size_t) $1;"
%typemap(out) size_t* * const "$result = (size_t *) $1;"
%typemap(out) const size_t* * const "$result = (const size_t **) $1;"

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
    $result = ($1_ltype) _temp;
  }
  else
    $result = ($1_ltype) 0;
}

// typemaps for 'cppresult'
// void
%typemap(cppouttype) void "void"
%typemap(cppouttype) void*, const void* "void *"
// constant pointers
%typemap(cppouttype) void * const "void * const"
%typemap(cppouttype) void* * const * const "void* *"
%typemap(cppouttype) const void* * const "const void* *"

// short
%typemap(cppouttype) short, const short "short"
%typemap(cppouttype) short*, short&, short[ANY], short[] "short *"
%typemap(cppouttype) const short&, const short*, const short[ANY], const short[] "const short *"
%typemap(cppouttype) unsigned short "unsigned short"
%typemap(cppouttype) const unsigned short "const unsigned short"
%typemap(cppouttype) unsigned short*, unsigned short&, unsigned short*, unsigned short[ANY], unsigned short[] "unsigned short *"
%typemap(cppouttype) const unsigned short*, const unsigned short&, const unsigned short[ANY], const unsigned short[] "const unsigned short *"
%typemap(cppouttype) short**, short*&, short*[ANY], short[ANY][ANY] "short **"
%typemap(cppouttype) const short**, const short*&, const short*[ANY], const short[ANY][ANY] "const short **"
%typemap(cppouttype) unsigned short**, unsigned short*&, unsigned short*[ANY], unsigned short[ANY][ANY] "unsigned short **"
%typemap(cppouttype) const unsigned short**,const unsigned short*&, const unsigned short[ANY][ANY] "const unsigned short **"
// constant pointers
%typemap(cppouttype) short * const "short *"
%typemap(cppouttype) short* * const "short* *"
%typemap(cppouttype) const short* * const "const short* *"
%typemap(cppouttype) unsigned short * const "unsigned short *"
%typemap(cppouttype) unsigned short* * const "unsigned short* *"
%typemap(cppouttype) const unsigned short* * const "const unsigned short* *"

// int
%typemap(cppouttype) int, const int "int"
%typemap(cppouttype) int*, int&, int[ANY], int[] "int *"
%typemap(cppouttype) const int&, const int*, const int[ANY], const int[] "const int *"
%typemap(cppouttype) unsigned int "unsigned int"
%typemap(cppouttype) const unsigned int "unsigned int"
%typemap(cppouttype) unsigned int*, unsigned int&, unsigned int*, unsigned int[ANY], unsigned int[] "unsigned int *"
%typemap(cppouttype) const unsigned int*, const unsigned int&, const unsigned int[ANY], const unsigned int[] "const unsigned int *"
%typemap(cppouttype) int**, int*&, int*[ANY], int[ANY][ANY] "int **"
%typemap(cppouttype) const int**, const int*&, int const **, int *const &, const int*[ANY], const int[ANY][ANY] "const int **"
%typemap(cppouttype) unsigned int**, unsigned int*&, unsigned int*[ANY], unsigned int[ANY][ANY] "unsigned int **"
%typemap(cppouttype) const unsigned int**,const unsigned int*&, const unsigned int[ANY][ANY] "const unsigned int **"
// constant pointers
%typemap(cppouttype) int * const "int *"
%typemap(cppouttype) int* * const "int* *"
%typemap(cppouttype) const int* * const "const int* *"
%typemap(cppouttype) unsigned int * const "unsigned int *"
%typemap(cppouttype) unsigned int* * const "unsigned int* *"
%typemap(cppouttype) const unsigned int* * const "const unsigned int* *"

// long
%typemap(cppouttype) long, const long "long"
%typemap(cppouttype) long*, long&, long[ANY], long[] "long *"
%typemap(cppouttype) const long&, const long*, const long[ANY], const long[] "const long *"
%typemap(cppouttype) unsigned long "unsigned long"
%typemap(cppouttype) const unsigned long "const unsigned long"
%typemap(cppouttype) unsigned long*, unsigned long&, unsigned long*, unsigned long[ANY], unsigned long[] "unsigned long *"
%typemap(cppouttype) const unsigned long*, const unsigned long&, const unsigned long[ANY], const unsigned long[] "const unsigned long *"
%typemap(cppouttype) long**, long*&, long*[ANY], long[ANY][ANY] "long **"
%typemap(cppouttype) const long**, const long*&, const long*[ANY], const long[ANY][ANY] "const long **"
%typemap(cppouttype) unsigned long**, unsigned long*&, unsigned long*[ANY], unsigned long[ANY][ANY] "unsigned long **"
%typemap(cppouttype) const unsigned long**,const unsigned long*&, const unsigned long[ANY][ANY] "const unsigned long **"
// constant pointers
%typemap(cppouttype) long * const "long *"
%typemap(cppouttype) long* * const "long* *"
%typemap(cppouttype) const long* * const "const long* *"
%typemap(cppouttype) unsigned long * const "unsigned long *"
%typemap(cppouttype) unsigned long* * const "unsigned long* *"
%typemap(cppouttype) const unsigned long* * const "const unsigned long* *"

// long long
%typemap(cppouttype) long long, const long long "long long"
%typemap(cppouttype) long long*, long long&, long long[ANY], long long[] "long long *"
%typemap(cppouttype) const long long&, const long long*, const long long[ANY], const long long[] "const long long *"
%typemap(cppouttype) unsigned long long "unsigned long long"
%typemap(cppouttype) const unsigned long long "const unsigned long long"
%typemap(cppouttype) unsigned long long*, unsigned long long&, unsigned long long*, unsigned long long[ANY], unsigned long long[] "unsigned long long *"
%typemap(cppouttype) const unsigned long long*, const unsigned long long&, const unsigned long long[ANY], const unsigned long long[] "const unsigned long long *"
%typemap(cppouttype) long long**, long long*&, long long*[ANY], long long[ANY][ANY] "long long **"
%typemap(cppouttype) const long long**, const long long*&, const long long*[ANY], const long long[ANY][ANY] "const long long **"
%typemap(cppouttype) unsigned long long**, unsigned long long*&, unsigned long long*[ANY], unsigned long long[ANY][ANY] "unsigned long long **"
%typemap(cppouttype) const unsigned long long**,const unsigned long long*&, const unsigned long long[ANY][ANY] "const unsigned long long **"
// constant pointers
%typemap(cppouttype) long long * const "long long *"
%typemap(cppouttype) long long* * const "long long* *"
%typemap(cppouttype) const long long* * const "const long long* *"
%typemap(cppouttype) unsigned long long * const "unsigned long long *"
%typemap(cppouttype) unsigned long long* * const "unsigned long long* *"
%typemap(cppouttype) const unsigned long long* * const "const unsigned long long* *"

// char: signed/unsigned
%typemap(cppouttype) char, const char "char"
%typemap(cppouttype) char*, char&, char[ANY], char[] "$1_ltype"
%typemap(cppouttype) const char&, const char*, const char[ANY], const char[] "const char *"
%typemap(cppouttype) char**, char*&, char*[ANY], char[ANY][ANY] "char **"
%typemap(cppouttype) const char**, const char*&, const char*[ANY], const char[ANY][ANY] "char **"
%typemap(cppouttype) signed char**, signed char*&, signed char*[ANY], signed char[ANY][ANY] "signed char **"
%typemap(cppouttype) const signed char**, const signed char*&, const signed char[ANY][ANY] "const signed char **"
%typemap(cppouttype) signed char "signed char"
%typemap(cppouttype) const signed char "const signed char"
%typemap(cppouttype) signed char*, signed char&, signed char*, signed char[ANY], signed char[] "signed char *"
%typemap(cppouttype) const signed char*, const signed char&, const signed char[ANY], const signed char[] "const $1_ltype"
%typemap(cppouttype) unsigned char**, unsigned char*&, unsigned char*[ANY], unsigned char[ANY][ANY] "unsigned char **"
%typemap(cppouttype) const unsigned char**, const unsigned char*&, const unsigned char[ANY][ANY] "const unsigned char **"
%typemap(cppouttype) unsigned char "unsigned char"
%typemap(cppouttype) const unsigned char "const unsigned char"
%typemap(cppouttype) unsigned char*, unsigned char&, unsigned char*, unsigned char[ANY], unsigned char[] "unsigned char *"
%typemap(cppouttype) const unsigned char*, const unsigned char&, const unsigned char[ANY], const unsigned char[] "const unsigned char *"
// constant pointers
%typemap(cppouttype) char * const "char *"
%typemap(cppouttype) char* * const "char* *"
%typemap(cppouttype) const char* * const "const char* *"
%typemap(cppouttype) unsigned char * const "unsigned char *"
%typemap(cppouttype) unsigned char* * const "unsigned char* *"
%typemap(cppouttype) const unsigned char* * const "const unsigned char* *"

// float
%typemap(cppouttype) float, const float "float"
%typemap(cppouttype) float*, float&, float[ANY], float[] "float *"
%typemap(cppouttype) const float&, const float*, const float[ANY], const float[] "const float *"
%typemap(cppouttype) float**, float*&, const float*&, float*[ANY], float[ANY][ANY] "float **"
%typemap(cppouttype) const float**, const float*[ANY], const float[ANY][ANY] "const float **"
// constant pointers
%typemap(cppouttype) float * const "float *"
%typemap(cppouttype) float* * const "float* *"
%typemap(cppouttype) const float* * const "const float* *"
%typemap(cppouttype) unsigned float * const "unsigned float *"
%typemap(cppouttype) unsigned float* * const "unsigned float* *"
%typemap(cppouttype) const unsigned float* * const "const unsigned float* *"

// double
%typemap(cppouttype) double, const double "double"
%typemap(cppouttype) double*, double&, double[ANY], double[] "double *"
%typemap(cppouttype) const double&, const double*, const double[ANY], const double[] "const double *"
%typemap(cppouttype) double**, double*&, const double*&, double*[ANY], double[ANY][ANY] "double **"
%typemap(cppouttype) const double**, const double*[ANY], const double[ANY][ANY] "const double **"
// constant pointers
%typemap(cppouttype) double * const "double *"
%typemap(cppouttype) double* * const "double* *"
%typemap(cppouttype) const double* * const "const double* *"
%typemap(cppouttype) unsigned double * const "unsigned double *"
%typemap(cppouttype) unsigned double* * const "unsigned double* *"
%typemap(cppouttype) const unsigned double* * const "const unsigned double* *"

// size_t
%typemap(cppouttype) size_t, const size_t "size_t"
%typemap(cppouttype) size_t*, size_t&, size_t[ANY], size_t[] "size_t *"
%typemap(cppouttype) const size_t&, const size_t*, const size_t[ANY], const size_t[] "const size_t *"
%typemap(cppouttype) size_t**, size_t*&, size_t*[ANY], size_t[ANY][ANY] "size_t **"
%typemap(cppouttype) const size_t**, const size_t*&, const size_t*[ANY], const size_t[ANY][ANY] "const size_t **"
// constant pointers
%typemap(cppouttype) size_t * const "size_t *"
%typemap(cppouttype) size_t* * const "size_t* *"
%typemap(cppouttype) const size_t* * const "const size_t* *"

%typemap(cppouttype, retobj="1") SWIGTYPE      "$1_ltype *"
%typemap(cppouttype) SWIGTYPE *    "$1_ltype"
%typemap(cppouttype) const SWIGTYPE * "const $1_ltype"
%typemap(cppouttype) SWIGTYPE &    "$1_ltype"
%typemap(cppouttype) SWIGTYPE *&   "$1_ltype"
%typemap(cppouttype) SWIGTYPE [ANY] "$1_ltype"
%typemap(cppouttype) SWIGTYPE * [ANY] "/*SWIGTYPE *[ANY] */ $1_ltype"
%typemap(cppouttype) SWIGTYPE ** "/*SWIGTYPE ** */ $1_basetype **"
%typemap(cppouttype, retobj="1") enum SWIGTYPE "int"
%typemap(cppouttype) enum SWIGTYPE &, enum SWIGTYPE * "int *"
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
