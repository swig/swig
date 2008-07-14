/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * c.swg
 * ----------------------------------------------------------------------------- */ 

%insert("runtime") "clabels.swg"
%insert("proxy_header") "cproxy.swg"

%insert("runtime") %{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <setjmp.h>
%}

// typemaps for function parameters

%typemap(ctype) void, short, int, long, char, float, double "$1_type"
%typemap(ctype) unsigned short, unsigned int, unsigned long, unsigned char "$1_type"
%typemap(ctype) void *, short *, int *, long *, char *, float *, double * "$1_type"
%typemap(ctype) void **, short **, int **, long **, char **, float **, double ** "$1_type"
%typemap(ctype) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$1_type"
%typemap(ctype) unsigned short **, unsigned int **, unsigned long **, unsigned char ** "$1_type"
%typemap(ctype) short &, int &, long &, char &, float &, double & "$1_basetype *"
%typemap(ctype) unsigned short &, unsigned int &, unsigned long &, unsigned char & "$1_basetype *"
%typemap(ctype) const short, const int, const long, const char, const float, const double "$1_type"
%typemap(ctype) const unsigned short, const unsigned int, const unsigned long, const unsigned char "$1_type"
%typemap(ctype) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$1_type"
%typemap(ctype) bool                  "_Bool"
%typemap(ctype) void * [ANY], short * [ANY], int * [ANY], long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$1 = ($1_basetype*) $input;"
%typemap(ctype) SWIGTYPE         "struct SwigObj$1_type *"
%typemap(ctype) SWIGTYPE *       "struct SwigObj$1_type"
%typemap(ctype) SWIGTYPE &       "struct SwigObj$1_basetype*"
%typemap(ctype) SWIGTYPE * [ANY] "struct SwigObj$1_basetype*"

%typemap(in) short, int, long, char, float, double, bool "$1 = ($1_type) $input;"
%typemap(in) void *, short *, int *, long *, char *, float *, double *, bool * "$1 = ($1_type) $input;"
%typemap(in) void **, short **, int **, long **, char **, float **, double **, bool * "$1 = ($1_type) $input;"
%typemap(in) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$1 = ($1_type) $input;"
%typemap(in) unsigned short **, unsigned int **, unsigned long **, unsigned char ** "$1 = ($1_type) $input;"
%typemap(in) const void *, const short *, const int *, const long *, const char *, const float *, const double *, const bool * "$1 = ($1_basetype *) $input;"
%typemap(in) const unsigned short *, const unsigned int *, const unsigned long *, const unsigned char * "$1 = ($1_type) $input;"
%typemap(in) unsigned short, unsigned int, unsigned long, unsigned char "$1 = ($1_type) $input;"
%typemap(in) short &, int &, long &, char &, float &, double &, bool & "$1 = ($1_basetype *) $input;"
%typemap(in) const short &, const int &, const long &, const char &, const float &, const double &, const bool & "$1 = ($1_basetype const *) $input;"
%typemap(in) unsigned short &, unsigned int &, unsigned long &, unsigned char &  "$1 = ($1_basetype *) $input;"
%typemap(in) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned char & "$1 = ($1_basetype const *) $input;"


%typemap(in) SWIGTYPE {
  $1 = * ($1_type *) ($input->obj);
}

%typemap(in) SWIGTYPE * {
  if ($input)
    $1 = ($1_type) $input->obj;
}

%typemap(in) SWIGTYPE * [ANY] {
  if ($input) {
    $1 = ($1_basetype*) malloc($1_dim0 * sizeof($1_basetype));
    int i;
    for (i = 0; i < $1_dim0; ++i)
      if ($input[i])
        $1[i] = ($1_basetype) $input[i]->obj;
      else
        $1[i] = ($1_basetype) 0;
  }
  else
    $1 = ($1_basetype*) 0;
}

%typemap(in) SWIGTYPE & {
  if ($input)
    $1 = ($1_basetype *) $input->obj;
  else
    $1 = ($1_basetype *) 0;
}

// typemaps for return values

%typemap(couttype) void, short, int, long, char, float, double "$1_type"
%typemap(couttype) void *, short *, int *, long *, char *, float *, double* "$1_type"
%typemap(couttype) const short, const int, const long, const char, const float, const double "$1_basetype"
%typemap(couttype) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$1_type"
%typemap(couttype) short &, int &, long &, char &, float &, double & "$1_basetype *"
%typemap(couttype) const short &, const int &, const long &, const char &, const float &, const double & "$1_basetype const *"
%typemap(couttype) bool       "_Bool"
%typemap(couttype) SWIGTYPE   "struct SwigObj$1_type *"
%typemap(couttype) SWIGTYPE * "struct SwigObj$1_type"
%typemap(couttype) SWIGTYPE & "struct SwigObj$1_basetype *"

%typemap(out) short, int, long, char, float, double, bool "$result = $1;"
%typemap(out) void*, short*, int*, long*, char*, float*, double*, bool* "$result = $1;"
%typemap(out) const short, const int, const long, const char, const float, const double "$result = $1;"
%typemap(out) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$result = $1;"
%typemap(out) unsigned short, unsigned int, unsigned long, unsigned char "$result = $1;"
%typemap(out) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$result = $1;"
%typemap(out) short &, int &, long &, char &, float &, double & "$result = $1;"
%typemap(out) unsigned short &, unsigned int &, unsigned long &, unsigned char & "$result = $1;"
%typemap(out) const short &, const int &, const long &, const char &, const float &, const double & "$result = $1;"
%typemap(out) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned char & "$result = $1;"
%typemap(out) void ""

// allocate new "object-struct" by default

%typemap(out) SWIGTYPE {
  $result = (struct SwigObj$1_type *) malloc(sizeof(struct SwigObj$1_type));
  $result->obj = (void*) &$1;
  #if SWIG_C_RUNTIME
  $result->typenames[0] = 0;    // FIXME
  #endif
}

%typemap(out) SWIGTYPE * {
  $result = (struct SwigObj$1_type) malloc(sizeof(struct SwigObj$*1_type));
  $result->obj = (void*) $1;
  #if SWIG_C_RUNTIME
  $result->typenames[0] = 0;    // FIXME
  #endif
}

%typemap(out) SWIGTYPE & {
  $result = (struct SwigObj$1_basetype *) malloc(sizeof(struct SwigObj$1_basetype));
  $result->obj = (void*) $1;
  #if SWIG_C_RUNTIME
  $result->typenames[0] = 0;    // FIXME
  #endif
}

// exception handling

%typemap(throws) SWIGTYPE {
  (void)_e;
  SWIG_CThrowException(3, "C++ $1_type exception thrown");
}

%insert("runtime") %{

#define SWIG_MAX_HANDLERS 256
#define SWIG_MAX_RT_STACK 256

SWIGEXPORTC int SWIG_exception_code;
SWIGEXPORTC jmp_buf SWIG_rt_env;
SWIGEXPORTC int SWIG_rt_init = 0;
SWIGINTERN struct {
  int reg;
  int code;
  void (*fun)();
} SWIG_Handlers[SWIG_MAX_HANDLERS];
SWIGINTERN int SWIG_next_handler = 0;
SWIGINTERN jmp_buf *SWIG_rt_stack_base = 0;
SWIGINTERN jmp_buf *SWIG_rt_stack_ptr = 0;

SWIGINTERN void SWIG_rt_stack_push() {
  // TODO: check for stack overflow
  memcpy(SWIG_rt_stack_ptr, SWIG_rt_env, sizeof(SWIG_rt_env));
  SWIG_rt_stack_ptr++;
}

SWIGINTERN void SWIG_rt_stack_pop() {
  if (SWIG_rt_stack_ptr == SWIG_rt_stack_base)
    return;
  SWIG_rt_stack_ptr--;
  memcpy(SWIG_rt_env, SWIG_rt_stack_ptr, sizeof(SWIG_rt_env));
}

#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORTC void SWIG_rt_try() {
  SWIG_rt_stack_push();
}

SWIGEXPORTC int SWIG_rt_catch(int code) {
  int result = (SWIG_exception_code == code);
  if (result)
    SWIG_rt_stack_pop();
  return result;
}

SWIGEXPORTC void SWIG_rt_throw(int code) {
  longjmp(SWIG_rt_env, code);
}

SWIGEXPORTC void SWIG_rt_endtry() {
  SWIG_rt_stack_pop();
  longjmp(SWIG_rt_env, SWIG_exception_code);
}

SWIGEXPORTC void SWIG_Register_Handler(int code, void (*fun)()) {
  if (SWIG_next_handler < SWIG_MAX_HANDLERS) {
    int i = SWIG_next_handler++;
    SWIG_Handlers[i].reg = 1;
    SWIG_Handlers[i].code = code;
    SWIG_Handlers[i].fun = fun;
  }
}

SWIGEXPORTC void SWIG_Unregister_Handler(int code) {
  int i;
  for (i = 0; i < SWIG_next_handler; ++i) {
    if (SWIG_Handlers[i].code == code)
      SWIG_Handlers[i].reg = 0;
  }
}

#ifdef __cplusplus
}
#endif

SWIGINTERN void SWIG_Runtime_init() {
  int i, code;
  if (!SWIG_rt_init) {
    SWIG_rt_init = 1;
    for (i = 0; i < SWIG_MAX_HANDLERS; ++i)
      SWIG_Handlers[i].reg = 0;
    SWIG_rt_stack_base = SWIG_rt_stack_ptr = (jmp_buf *) malloc(sizeof(jmp_buf) * SWIG_MAX_RT_STACK);
    if (code = setjmp(SWIG_rt_env)) {
      for (i = 0; i < SWIG_next_handler; ++i) {
        if (SWIG_Handlers[i].reg)
          if (SWIG_Handlers[i].code == code)
            SWIG_Handlers[i].fun();
      }
      fprintf(stderr, "Unhandled exception. Exitting...\n");
      exit(code);
    }
  }
}

SWIGINTERN void SWIG_CThrowException(int code, char *msg) {
  if (SWIG_rt_init)
    longjmp(SWIG_rt_env, code);
  else {
    fprintf(stderr, "%s\n", msg);
    exit(code);
  }
}

%}

%insert("proxy_header") %{
#include <setjmp.h>

void SWIG_Register_Handler(int code, void (*fun)());
void SWIG_Unregister_Handler(int code);
int SWIG_exception_try();
void SWIG_exception_throw();

SWIGIMPORT jmp_buf SWIG_rt_env;
SWIGIMPORT int SWIG_exception_code;
SWIGIMPORT void SWIG_rt_try();
SWIGIMPORT int SWIG_rt_catch();
SWIGIMPORT void SWIG_rt_throw(int val);
SWIGIMPORT int SWIG_rt_endtry();

#define SWIG_try \
  SWIG_rt_try(); \
  if ((SWIG_exception_code = setjmp(SWIG_rt_env)) == 0) 
#define SWIG_catch(val) else if (SWIG_rt_catch(val))
#define SWIG_throw(val) SWIG_rt_throw(val);
#define SWIG_endtry else SWIG_rt_endtry();
%}

