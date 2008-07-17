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

typedef struct {
  void *obj;
  const char **typenames;
} SwigObj;
%}

// typemaps for function parameters

%typemap(ctype) void, short, int, long, char, float, double, bool "$1_type"
%typemap(ctype) unsigned short, unsigned int, unsigned long, unsigned char "$1_type"
%typemap(ctype) void *, short *, int *, long *, char *, float *, double *, bool * "$1_type"
%typemap(ctype) void **, short **, int **, long **, char **, float **, double **, bool ** "$1_type"
%typemap(ctype) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$1_type"
%typemap(ctype) unsigned short **, unsigned int **, unsigned long **, unsigned char ** "$1_type"
%typemap(ctype) short &, int &, long &, char &, float &, double &, bool & "$1_basetype *"
%typemap(ctype) unsigned short &, unsigned int &, unsigned long &, unsigned char & "$1_basetype *"
%typemap(ctype) const short, const int, const long, const char, const float, const double, const bool "$1_type"
%typemap(ctype) const unsigned short, const unsigned int, const unsigned long, const unsigned char "$1_type"
%typemap(ctype) const void *, const short *, const int *, const long *, const char *, const float *, const double *, const bool * "$1_type"
%typemap(ctype) void * [ANY], short * [ANY], int * [ANY], long * [ANY], char * [ANY], float * [ANY], double * [ANY], bool * [ANY] "$1 = ($1_basetype*) $input;"
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

%typemap(couttype) void, short, int, long, char, float, double, bool "$1_type"
%typemap(couttype) void *, short *, int *, long *, char *, float *, double*, bool* "$1_type"
%typemap(couttype) const short, const int, const long, const char, const float, const double, const bool "$1_basetype"
%typemap(couttype) const void *, const short *, const int *, const long *, const char *, const float *, const double *, const bool * "$1_type"
%typemap(couttype) short &, int &, long &, char &, float &, double &, bool & "$1_basetype *"
%typemap(couttype) const short &, const int &, const long &, const char &, const float &, const double &, const bool & "$1_basetype const *"
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

%typemap(throws) int, long, short, unsigned int, unsigned long, unsigned short {
  char error_msg[256];
  sprintf(error_msg, "C++ $1_type exception thrown, value: %d", $1);
  SWIG_CThrowException(0, error_msg);
}

%typemap(throws) char *, const char * {
  SWIG_CThrowException(0, $1);
}

// this should match only non-built-in and non-template objects
%typemap(throws) SWIGTYPE {
  SWIG_CThrowException(0, "C++ $1_type exception thrown");
}

%insert("runtime") %{

#define SWIG_MAX_RT_STACK 256

SWIGEXPORTC struct {
  int code;
  char *msg;
  SwigObj *klass;
} SWIG_exception;

SWIGEXPORTC jmp_buf SWIG_rt_env;
SWIGEXPORTC int SWIG_rt_init = 0;
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

SWIGINTERN void SWIG_cleanup() {
  if (SWIG_rt_stack_base)
    free(SWIG_rt_stack_base);
  if (SWIG_exception.msg)
   free(SWIG_exception.msg);
}

#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORTC void SWIG_rt_try() {
  SWIG_rt_stack_push();
}

SWIGEXPORTC int SWIG_rt_catch(const char *type) {
  int result = 0;
  if (!type || (strcmp("SWIG_AnyException", type) == 0)) {
    result = 1;
  }
  else if (SWIG_exception.klass) {
    int i = 0;
    while (SWIG_exception.klass->typenames[i]) {
      if (strcmp(SWIG_exception.klass->typenames[i++], type) == 0) {
        result = 1;
        break;
      }
    }
  }
  if (result)
    SWIG_rt_stack_pop();
  return result;
}

SWIGEXPORTC void SWIG_rt_throw(SwigObj *klass, const char *msg) {
  if (SWIG_exception.msg) {
    free(SWIG_exception.msg);
    SWIG_exception.msg = (char *) 0;
  }
  if (msg) {
    SWIG_exception.msg = (char *) malloc(strlen(msg));
    strcpy(SWIG_exception.msg, msg);
  }
  SWIG_exception.klass = klass;
  longjmp(SWIG_rt_env, 1);
}

SWIGEXPORTC void SWIG_rt_endtry() {
  if (SWIG_exception.msg)
    free(SWIG_exception.msg);
  SWIG_rt_stack_pop();
  longjmp(SWIG_rt_env, SWIG_exception.code);
}

SWIGEXPORTC int SWIG_exit(int code) {
  SWIG_cleanup();
  exit(code);
}

#ifdef __cplusplus
}
#endif

SWIGINTERN void SWIG_terminate() {
  fprintf(stderr, "Unhandled exception: %s\n%s (error code: %d)\nExitting...\n", 
    SWIG_exception.klass->typenames[0],
    SWIG_exception.msg, 
    SWIG_exception.code);
  SWIG_exit(SWIG_exception.code);
}

SWIGINTERN void SWIG_Runtime_init() {
  int i, code;
  if (!SWIG_rt_init) {
    SWIG_rt_init = 1;
    SWIG_rt_stack_base = SWIG_rt_stack_ptr = (jmp_buf *) malloc(sizeof(jmp_buf) * SWIG_MAX_RT_STACK);
    if (SWIG_exception.code = setjmp(SWIG_rt_env))
      SWIG_terminate();
  }
}

SWIGINTERN void SWIG_CThrowException(void *klass, const char *msg) {    
  if (SWIG_rt_init)
    SWIG_rt_throw((SwigObj *) klass, msg);
  else
    SWIG_terminate();
}
%}

%insert("proxy_header") %{
// special value indicating any type of exception like 'catch(...)'
#define SWIG_AnyException "SWIG_AnyException"

#include <stdbool.h>
#include <setjmp.h>

SWIGIMPORT jmp_buf SWIG_rt_env;

typedef struct {
  void *obj;
  const char **typenames;
} SwigObj;

SWIGIMPORT struct {
  int code;
  char *msg;
  SwigObj *klass;
} SWIG_exception;

SWIGIMPORT void SWIG_rt_try();
SWIGIMPORT int SWIG_rt_catch(const char *type);
SWIGIMPORT void SWIG_rt_throw(SwigObj *klass, const char * msg);
SWIGIMPORT int SWIG_rt_endtry();
SWIGIMPORT int SWIG_exit(int code);

#define SWIG_try \
  SWIG_rt_try(); \
  if ((SWIG_exception.code = setjmp(SWIG_rt_env)) == 0) 
#define SWIG_catch(type) else if (SWIG_rt_catch(#type))
#define SWIG_throw(klass) SWIG_rt_throw((SwigObj *) klass, 0);
#define SWIG_throw_msg(klass, msg) SWIG_rt_throw((SwigObj *) klass, msg);
#define SWIG_endtry else SWIG_rt_endtry();
%}

