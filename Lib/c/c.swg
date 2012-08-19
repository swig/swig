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

%define explicit_same_type(TM, T)
%typemap(TM) T, const T "T"
%typemap(TM) T*, T&, T[ANY], T[] "T *"
%typemap(TM) const T&, const T*, const T[ANY], const T[] "const T *"
%typemap(TM) T**, T*&, T*[ANY], T[ANY][ANY] "T **"
%typemap(TM) const T**, const T*&, const T*[ANY], const T[ANY][ANY] "const T **"
// constant pointers
%typemap(TM) T * const "T * const"
%typemap(TM) T* * const "T* * const"
%typemap(TM) const T* * const "const T* * const"
%enddef

// void
%typemap(proxy) void "void"
%typemap(proxy) void*, void& "void *"
%typemap(proxy) const void&, const void* "const void *"
%typemap(proxy) void**, void*& "void **"
%typemap(proxy) const void**, const void*& "const void **"
// constant pointers
%typemap(proxy) void* * const "void* * const"
%typemap(proxy) const void* * const "const void* * const"

explicit_same_type(proxy, short);
explicit_same_type(proxy, unsigned short);
explicit_same_type(proxy, int);
explicit_same_type(proxy, unsigned int);
explicit_same_type(proxy, long);
explicit_same_type(proxy, unsigned long);
explicit_same_type(proxy, long long);
explicit_same_type(proxy, unsigned long long);
explicit_same_type(proxy, char);
explicit_same_type(proxy, signed char);
explicit_same_type(proxy, unsigned char);
explicit_same_type(proxy, float);
explicit_same_type(proxy, double);
explicit_same_type(proxy, size_t);

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
// void
%typemap(ctype) void "void"
%typemap(ctype) void*, void& "void *"
%typemap(ctype) const void&, const void* "const void *"
%typemap(ctype) void**, void*&, void*[ANY], void[ANY][ANY] "void **"
%typemap(ctype) const void**, const void*& "const void **"
// constant pointers
%typemap(ctype) void* * const "void* * const"
%typemap(ctype) const void* * const "const void* * const"


explicit_same_type(ctype, short);
explicit_same_type(ctype, unsigned short);
explicit_same_type(ctype, int);
explicit_same_type(ctype, unsigned int);
explicit_same_type(ctype, long);
explicit_same_type(ctype, unsigned long);
explicit_same_type(ctype, long long);
explicit_same_type(ctype, unsigned long long);
explicit_same_type(ctype, char);
explicit_same_type(ctype, signed char);
explicit_same_type(ctype, unsigned char);
explicit_same_type(ctype, float);
explicit_same_type(ctype, double);
explicit_same_type(ctype, size_t);

// special cases of array passing - does not intended to be used for objects
%typemap(ctype) SWIGTYPE [] "$1_ltype"
%typemap(ctype) SWIGTYPE ((&)[ANY]) "$1_basetype **"

%typemap(ctype) short [ANY][ANY], int [ANY][ANY], long [ANY][ANY], char [ANY][ANY], float [ANY][ANY], double [ANY][ANY] "$1_ltype"
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


%define in_assignment_cast(PRE, POST)
PRE short POST, PRE int POST, PRE long POST, PRE long long POST, PRE char POST, PRE float POST, PRE double POST "$1 = ($1_ltype) $input;"
%enddef

//this macro is necessary, because 'unsigned double' is not allowed.
%define in_assignment_cast_unsigned_only(PRE, POST)
PRE float POST, PRE double POST, PRE signed char POST "$1 = ($1_ltype) $input;"
%enddef

%define in_assignment_group(PRE)
in_assignment_cast(PRE,empty_macro_arg);
in_assignment_cast(PRE,*);
in_assignment_cast(PRE,&);
in_assignment_cast(PRE,[ANY]);
in_assignment_cast(PRE,*&);
in_assignment_cast(PRE,**);
%enddef

in_assignment_group(empty_macro_arg);
in_assignment_group(const);
in_assignment_group(unsigned);
in_assignment_group(unsigned const);

in_assignment_cast_unsigned_only(,);
in_assignment_cast_unsigned_only(,*);
in_assignment_cast_unsigned_only(,&);
in_assignment_cast_unsigned_only(,[ANY]);
in_assignment_cast_unsigned_only(,**);
in_assignment_cast_unsigned_only(,*&);
in_assignment_cast_unsigned_only(const,);
in_assignment_cast_unsigned_only(const,*);
in_assignment_cast_unsigned_only(const,&);
in_assignment_cast_unsigned_only(const,[ANY]);
in_assignment_cast_unsigned_only(const,*&);

%typemap(in) short [ANY], int [ANY], long [ANY], long long [ANY], char [ANY], float [ANY], double [ANY], unsigned char [ANY] "$1 = ($1_basetype *) $input;"
%typemap(in) short * [ANY], int * [ANY], long * [ANY], long long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$1 = ($1_basetype *) $input;"

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
%typemap(couttype) const void* * const "void* *"

//unconsted types are necessary, because some the methods using this declare variables of the resolved type first and assign their values later
%define explicit_same_type_unconsted(TM, T)
%typemap(TM) T, const T "T"
%typemap(TM) T*, T&, T[ANY], T[] "T *"
%typemap(TM) const T&, const T*, const T[ANY], const T[] "const T *"
%typemap(TM) T**, T*&, T*[ANY], T[ANY][ANY] "T **"
%typemap(TM) const T**, const T*&, T *const &, const T*[ANY], const T[ANY][ANY] "const T **"
// constant pointers
%typemap(TM) T * const "T *"
%typemap(TM) T* * const "T* *"
%typemap(TM) const T* * const "const T* *"
%enddef

explicit_same_type_unconsted(couttype, short);
explicit_same_type_unconsted(couttype, unsigned short);
explicit_same_type_unconsted(couttype, int);
explicit_same_type_unconsted(couttype, unsigned int);
explicit_same_type_unconsted(couttype, long);
explicit_same_type_unconsted(couttype, unsigned long);
explicit_same_type_unconsted(couttype, long long);
explicit_same_type_unconsted(couttype, unsigned long long);
explicit_same_type_unconsted(couttype, char);
explicit_same_type_unconsted(couttype, signed char);
explicit_same_type_unconsted(couttype, unsigned char);
explicit_same_type_unconsted(couttype, float);
explicit_same_type_unconsted(couttype, double);
explicit_same_type_unconsted(couttype, size_t);

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

explicit_same_type(proxyccouttype, short);
explicit_same_type(proxyccouttype, unsigned short);
explicit_same_type(proxyccouttype, int);
explicit_same_type(proxyccouttype, unsigned int);
explicit_same_type(proxyccouttype, long);
explicit_same_type(proxyccouttype, unsigned long);
explicit_same_type(proxyccouttype, long long);
explicit_same_type(proxyccouttype, unsigned long long);
explicit_same_type(proxyccouttype, char);
explicit_same_type(proxyccouttype, signed char);
explicit_same_type(proxyccouttype, unsigned char);
explicit_same_type(proxyccouttype, float);
explicit_same_type(proxyccouttype, double);
explicit_same_type(proxyccouttype, size_t)

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


%define out_assignment_no_cast(PRE, POST)
PRE short POST, PRE int POST, PRE long POST, PRE long long POST, PRE char POST, PRE float POST, PRE double POST "$result = $1;"
%enddef

//this macro is necessary, because 'unsigned double' is not allowed.
%define out_assignment_no_cast_unsigned_only(PRE, POST)
PRE float POST, PRE double POST, PRE signed char POST "$result = $1;"
%enddef

%define out_assignment_group(PRE)
out_assignment_no_cast(PRE,);
out_assignment_no_cast(PRE,*);
out_assignment_no_cast(PRE,&);
out_assignment_no_cast(PRE,[ANY]);
out_assignment_no_cast(PRE,*&);
out_assignment_no_cast(PRE,**);
%enddef

out_assignment_group();
out_assignment_group(const);
out_assignment_group(unsigned);
out_assignment_group(unsigned const);

out_assignment_no_cast_unsigned_only(,);
out_assignment_no_cast_unsigned_only(,*);
out_assignment_no_cast_unsigned_only(,&);
out_assignment_no_cast_unsigned_only(,[ANY]);
out_assignment_no_cast_unsigned_only(,**);
out_assignment_no_cast_unsigned_only(,*&);
out_assignment_no_cast_unsigned_only(const,);
out_assignment_no_cast_unsigned_only(const,*);
out_assignment_no_cast_unsigned_only(const,&);
out_assignment_no_cast_unsigned_only(const,[ANY]);
out_assignment_no_cast_unsigned_only(const,*&);

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
explicit_same_type_unconsted(cppouttype, short);
explicit_same_type_unconsted(cppouttype, unsigned short);
explicit_same_type_unconsted(cppouttype, int);
explicit_same_type_unconsted(cppouttype, unsigned int);
explicit_same_type_unconsted(cppouttype, long);
explicit_same_type_unconsted(cppouttype, unsigned long);
explicit_same_type_unconsted(cppouttype, long long);
explicit_same_type_unconsted(cppouttype, unsigned long long);
explicit_same_type_unconsted(cppouttype, char);
explicit_same_type_unconsted(cppouttype, signed char);
explicit_same_type_unconsted(cppouttype, unsigned char);
explicit_same_type_unconsted(cppouttype, float);
explicit_same_type_unconsted(cppouttype, double);
explicit_same_type_unconsted(cppouttype, size_t);

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
