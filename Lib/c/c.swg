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

//unconsted types are necessary, because some the methods using this declare variables of the resolved type first and assign their values later
//used by 'cmodtype' and 'cppouttype' typemaps
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

%define explicit_same_type_unconsted_all_primitive_types_but_void(TM)
same_macro_all_primitive_types_but_void(explicit_same_type_unconsted,TM);
%enddef

//Used by 'ctype' typemap
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

%define explicit_same_type_all_primitive_types_but_void(TM)
same_macro_all_primitive_types_but_void(explicit_same_type,TM);
%enddef

//Used by 'in' and 'out' typemaps
%define same_action(TM, T, ACTION)
%typemap(TM) T, const T ACTION
%typemap(TM) T*, T&, T[ANY], T[] ACTION
%typemap(TM) const T&, const T*, const T[ANY], const T[] ACTION
%typemap(TM) T**, T*&, T*[ANY], T[ANY][ANY] ACTION
%typemap(TM) const T**, const T*&, const T*[ANY], const T[ANY][ANY] ACTION
// constant pointers
%typemap(TM) T * const ACTION
%typemap(TM) T* * const ACTION
%typemap(TM) const T* * const ACTION
%enddef

%define same_action_all_primitive_types_but_void(TM, ACTION)
same_action(TM, short, ACTION);
same_action(TM, unsigned short, ACTION);
same_action(TM, int, ACTION);
same_action(TM, unsigned int, ACTION);
same_action(TM, long, ACTION);
same_action(TM, unsigned long, ACTION);
same_action(TM, long long, ACTION);
same_action(TM, unsigned long long, ACTION);
same_action(TM, char, ACTION);
same_action(TM, signed char, ACTION);
same_action(TM, unsigned char, ACTION);
//unsigned only
same_action(TM, float, ACTION);
same_action(TM, double, ACTION);
same_action(TM, size_t, ACTION);
%enddef

// Typemaps for proxy function parameters
// void
%typemap(ctype) void "void"
%typemap(ctype) void*, void& "void *"
%typemap(ctype) const void&, const void* "const void *"
%typemap(ctype) void**, void*& "void **"
%typemap(ctype) const void**, const void*& "const void **"
// constant pointers
%typemap(ctype) void* * const "void* * const"
%typemap(ctype) const void* * const "const void* * const"

explicit_same_type_all_primitive_types_but_void(ctype);

// objects
%typemap(ctype) SWIGTYPE      "$&resolved_type*"
%typemap(ctype) SWIGTYPE *    "$resolved_type*"
%typemap(ctype) SWIGTYPE &    "$*resolved_type*"
%typemap(ctype) SWIGTYPE *&    "$resolved_type**"
%typemap(ctype) SWIGTYPE [ANY] "/*SWIGTYPE [ANY]*/ $1_ltype **"
%typemap(ctype) SWIGTYPE * [ANY] "/*SWIGTYPE *[ANY] */ $1_ltype **"
%typemap(ctype) SWIGTYPE ** "/*SWIGTYPE ** */ $1_ltype **"
%typemap(ctype) enum SWIGTYPE "int"
%typemap(ctype) enum SWIGTYPE &, enum SWIGTYPE * "int *"
%typemap(ctype, fragment="fptr_decl") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(ctype, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$1_ltype"
%typemap(ctype, fragment="stdbool_inc") bool & "$1_basetype*"
%typemap(ctype, fragment="stdbool_inc") const bool & "$1_basetype const *"

// Typemaps for wrapper function parameters and its local variables
// void
%typemap(cmodtype) void "void"
%typemap(cmodtype) void*, void& "void *"
%typemap(cmodtype) const void&, const void* "const void *"
%typemap(cmodtype) void**, void*&, void*[ANY], void[ANY][ANY] "void **"
%typemap(cmodtype) const void**, const void*& "const void **"
// unconst constant pointers
%typemap(cmodtype) void* * const "void* *"
%typemap(cmodtype) const void* * const "const void* *"

explicit_same_type_unconsted_all_primitive_types_but_void(cmodtype);

// special cases of array passing - does not intended to be used for objects
%typemap(cmodtype) SWIGTYPE [] "$1_ltype"
%typemap(cmodtype) SWIGTYPE ((&)[ANY]) "$1_basetype **"

%typemap(cmodtype) SWIGTYPE         "SwigObj *"
%typemap(cmodtype) SWIGTYPE *       "SwigObj *"
%typemap(cmodtype) SWIGTYPE &       "SwigObj *"
%typemap(cmodtype) SWIGTYPE [ANY][ANY], SWIGTYPE ** "/* whoa */ SwigObj ***"
%typemap(cmodtype) SWIGTYPE *[ANY]  "/*ooooh*/ SwigObj **"
%typemap(cmodtype) SWIGTYPE *&      "/* *& */ SwigObj **"
%typemap(cmodtype) enum SWIGTYPE    "int"
%typemap(cmodtype) enum SWIGTYPE &, enum SWIGTYPE *  "int *"
%typemap(cmodtype, fragment="fptr_decl", fragment="fptr_decl_proxy") SWIGTYPE (CLASS::*) "SWIG_CPP_FP"

%typemap(cmodtype, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool *, bool * [ANY] "$1_type"
%typemap(cmodtype, fragment="stdbool_inc") bool & "$1_ltype"
%typemap(cmodtype, fragment="stdbool_inc") const bool & "$1_ltype const"


// Typemaps for assigning wrapper parameters to local variables
same_action_all_primitive_types_but_void(in, "$1 = ($1_ltype) $input;")

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


// Typemaps for assigning result values to a special return variable
same_action_all_primitive_types_but_void(out, "$result = $1;")

%typemap(out) void ""

%typemap(out, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$result = ($1_ltype) $1;"
%typemap(out, fragment="stdbool_inc") bool &, const bool & "$result = $1;"

%typemap(out) enum SWIGTYPE "$result = (int) $1;"
%typemap(out) enum SWIGTYPE &, enum SWIGTYPE * "$result = (int *) &$1;"

%typemap(out) SWIGTYPE (CLASS::*) {
  *($&1_ltype) &$result = $1; 
}

%typemap(out) SWIGTYPE *&, SWIGTYPE ** {
  static SwigObj* _ptr = (SwigObj*) SWIG_create_object($1, SWIG_STR($1_basetype));
  $result = &_ptr;
}

%typemap(out) SWIGTYPE {
  $result = (SwigObj*) SWIG_create_object(&$1, SWIG_STR($1_basetype));
}

%typemap(out) SWIGTYPE *, SWIGTYPE & {
  $result = (SwigObj*) SWIG_create_object($1, SWIG_STR($1_basetype));
}

%typemap(out) SWIGTYPE * [ANY], SWIGTYPE [ANY][ANY] {
  static SwigObj **_temp = 0;
  if ($1) {
    size_t i = 0;
    if (_temp) {
        for ( ; i < $1_dim0; ++i)
          SWIG_destroy_object< $1_ltype >(_temp[i]);
        free(_temp);
    }
    _temp = (SwigObj**) malloc($1_dim0 * sizeof(SwigObj*));
    for (i = 0 ; i < $1_dim0; ++i) {
      if ($1[i]) {
        _temp[i] = SWIG_create_object($1[i], SWIG_STR($1_ltype));
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
explicit_same_type_unconsted_all_primitive_types_but_void(cppouttype);

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

%insert("runtime") %{
typedef struct {
  void *obj;
  const char* symname;
  bool (*derives_from)(const char* type);
} SwigObj;

template <class T> SWIGINTERN void SWIG_destroy_object(SwigObj* object) {
  if (!object)
    return;

  delete static_cast<T*>(object->obj);

  free(object);
}

template <class T> struct SWIG_derives_from {
  static bool check(const char* type) { return false; }
};

template <class T> SWIGINTERN SwigObj* SWIG_create_object(T* obj, const char* symname) {
  SwigObj* const result = (SwigObj*)malloc(sizeof(SwigObj));
  if (result) {
    result->obj = const_cast<void*>(static_cast<const void*>(obj));
    result->symname = symname;
    result->derives_from = SWIG_derives_from<T>::check;
  }

  return result;
}
%}

%insert("proxy_header") %{
    typedef struct SwigObjStruct SwigObj;
%}

  #ifdef SWIG_C_EXCEPT
  
%include "cexcept.swg"
    
  #else
    
#ifdef __cplusplus
extern "C" {
#endif
SWIGEXPORTC int SWIG_exit(int code) { exit(code); }
#ifdef __cplusplus
}
#endif
%}

  #endif
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
