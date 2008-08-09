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

%typemap(ctype) void, short, int, long, char, float, double "$1_type"
%typemap(ctype) unsigned short, unsigned int, unsigned long, unsigned char "$1_type"
%typemap(ctype) void *, short *, int *, long *, char *, float *, double * "$1_type"
%typemap(ctype) void **, short **, int **, long **, char **, float **, double ** "$1_type"
%typemap(ctype) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$1_type"
%typemap(ctype) unsigned short **, unsigned int **, unsigned long **, unsigned char ** "$1_type"
%typemap(ctype) short &, int &, long &, char &, float &, double &  "$1_basetype *"
%typemap(ctype) unsigned short &, unsigned int &, unsigned long &, unsigned char & "$1_basetype *"
%typemap(ctype) const short &, const int &, const long &, const char &, const float &, const double & "$1_basetype const *"
%typemap(ctype) const short, const int, const long, const char, const float, const double  "$1_type"
%typemap(ctype) const unsigned short, const unsigned int, const unsigned long, const unsigned char "$1_type"
%typemap(ctype) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$1_type"
%typemap(ctype) short [ANY], int [ANY], long [ANY], char [ANY], float [ANY], double [ANY] "$1_basetype *"
%typemap(ctype) void * [ANY], short * [ANY], int * [ANY], long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$1_basetype **"
%typemap(ctype) SWIGTYPE         "SwigObj *"
%typemap(ctype) SWIGTYPE *       "SwigObj *"
%typemap(ctype) SWIGTYPE &       "SwigObj *"
%typemap(ctype) SWIGTYPE * [ANY] "SwigObj *"
%typemap(ctype) enum SWIGTYPE    "$1_type"

%fragment("stdbool_inc", "proxy_header") {#include <stdbool.h>}
%typemap(ctype, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool *, bool * [ANY] "$1_type"
%typemap(ctype, fragment="stdbool_inc") bool & "$1_basetype *"
%typemap(ctype, fragment="stdbool_inc") const bool & "$1_basetype const *"

%typemap(in) short, int, long, char, float, double "$1 = ($1_type) $input;"
%typemap(in) void *, short *, int *, long *, char *, float *, double * "$1 = ($1_type) $input;"
%typemap(in) void **, short **, int **, long **, char **, float **, double ** "$1 = ($1_basetype **) $input;"
%typemap(in) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$1 = ($1_type) $input;"
%typemap(in) unsigned short **, unsigned int **, unsigned long **, unsigned char ** "$1 = ($1_type) $input;"
%typemap(in) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$1 = ($1_basetype *) $input;"
%typemap(in) const unsigned short *, const unsigned int *, const unsigned long *, const unsigned char * "$1 = ($1_type) $input;"
%typemap(in) unsigned short, unsigned int, unsigned long, unsigned char "$1 = ($1_type) $input;"
%typemap(in) short &, int &, long &, char &, float &, double &, bool & "$1 = ($1_basetype *) $input;"
%typemap(in) const short &, const int &, const long &, const char &, const float &, const double & "$1 = ($1_basetype *) $input;"
%typemap(in) unsigned short &, unsigned int &, unsigned long &, unsigned char &  "$1 = ($1_basetype *) $input;"
%typemap(in) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned char & "$1 = ($1_basetype *) $input;"
%typemap(in) short [ANY], int [ANY], long [ANY], char [ANY], float [ANY], double [ANY] "$1 = ($1_basetype *) $input;"
%typemap(in) void * [ANY], short * [ANY], int * [ANY], long * [ANY], char * [ANY], float * [ANY], double * [ANY] "$1 = ($1_basetype *) $input;"

%typemap(in, fragment="stdbool_inc") bool, bool *, bool **, const bool, const bool * "$1 = ($1_type) $input;"
%typemap(in, fragment="stdbool_inc") bool & "$1 = ($1_basetype *) $input;"
%typemap(in, fragment="stdbool_inc") const bool &, const bool * "$1 = ($1_basetype *) $input;"

%typemap(in) enum SWIGTYPE "$1 = ($1_type) $input;"

%typemap(in) SWIGTYPE {
  $1 = * ($1_type *) ($input->obj);
}

%typemap(in) SWIGTYPE * {
  if ($input)
    $1 = ($1_ltype) $input->obj;
}

%typemap(in) SWIGTYPE * [ANY] {
  if ($input) {
    $1 = ($1_basetype *) malloc($1_dim0 * sizeof($1_basetype));
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
%typemap(couttype) short [ANY], int [ANY], long [ANY], char [ANY], float [ANY], double [ANY] "$1_basetype *"
%typemap(couttype) SWIGTYPE      "SwigObj *"
%typemap(couttype) SWIGTYPE *    "SwigObj *"
%typemap(couttype) SWIGTYPE &    "SwigObj *"
%typemap(couttype) enum SWIGTYPE "$1_type"

%typemap(couttype, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$1_type"
%typemap(couttype, fragment="stdbool_inc") bool & "$1_basetype*"
%typemap(couttype, fragment="stdbool_inc") const bool & "$1_basetype const *"

%typemap(out) short, int, long, char, float, double "$result = $1;"
%typemap(out) void*, short*, int*, long*, char*, float*, double* "$result = $1;"
%typemap(out) const short, const int, const long, const char, const float, const double "$result = $1;"
%typemap(out) const void *, const short *, const int *, const long *, const char *, const float *, const double * "$result = $1;"
%typemap(out) unsigned short, unsigned int, unsigned long, unsigned char "$result = $1;"
%typemap(out) unsigned short *, unsigned int *, unsigned long *, unsigned char * "$result = $1;"
%typemap(out) short &, int &, long &, char &, float &, double & "$result = $1;"
%typemap(out) unsigned short &, unsigned int &, unsigned long &, unsigned char & "$result = $1;"
%typemap(out) const short &, const int &, const long &, const char &, const float &, const double & "$result = $1;"
%typemap(out) const unsigned short &, const unsigned int &, const unsigned long &, const unsigned char & "$result = $1;"
%typemap(out) short [ANY], int [ANY], long [ANY], char [ANY], float [ANY], double [ANY] "$result = $1;"
%typemap(out) void ""

%typemap(out, fragment="stdbool_inc") bool, bool *, const bool, const bool * "$result = $1;"
%typemap(out, fragment="stdbool_inc") bool &, const bool & "$result = $1;"

%typemap(out) enum SWIGTYPE "$result = ($1_type) $1;"

// allocate new "object-struct" by default

%typemap(out) SWIGTYPE {
  $result = SWIG_create_object(SWIG_STR($1_type));
  $result->obj = (void*) &$1;
}


%typemap(out) SWIGTYPE *, SWIGTYPE & {
  $result = SWIG_create_object(SWIG_STR($1_basetype));
  $result->obj = (void*) $1;
}

// exception handling

%typemap(throws) BASIC_INT_TYPES {
  char error_msg[256];
  sprintf(error_msg, "C++ $1_type exception thrown, value: %d", $1);
  SWIG_CThrowException(0, error_msg);
}

%apply BASIC_INT_TYPES { int, long, short, unsigned int, unsigned long, unsigned short, int &, long &, short &, unsigned int &, unsigned long &, unsigned short & };

%typemap(throws) char *, const char * {
  SWIG_CThrowException(0, $1);
}

// this should match only SwigObj objects
%typemap(throws) SWIGTYPE {
  SwigObj *c_ex;
  c_ex = SWIG_create_object(SWIG_STR($1_basetype));
  c_ex->obj = (void*) &$1;
  SWIG_CThrowException(c_ex, "C++ $1_type exception thrown");
}

%typemap(throws) SWIGTYPE * {
  SwigObj *c_ex;
  c_ex = SWIG_create_object(SWIG_STR($1_basetype));
  c_ex->obj = (void*) $1;
  SWIG_CThrowException(c_ex, "C++ $1_type exception thrown");
}

%insert("runtime") %{
#define SWIG_STR(x) #x
#define SWIG_MAX_RT_STACK 256
#define SWIG_REGISTRY_INIT 256

SWIGINTERN SwigObj **SWIG_registry_base = 0;
SWIGINTERN SwigObj **SWIG_registry = 0;
SWIGINTERN int SWIG_registry_size = SWIG_REGISTRY_INIT;

SWIGINTERN SwigObj *SWIG_create_object(const char *classname);
SWIGINTERN void SWIG_destroy_object(SwigObj *object);

SWIGEXPORTC struct SWIG_exc_struct {
  int code;
  char *msg;
  SwigObj *klass;
  int handled;
} SWIG_exc = { 0, 0, 0, 0 };

SWIGEXPORTC jmp_buf SWIG_rt_env;
SWIGEXPORTC int SWIG_rt_init = 0;
SWIGINTERN jmp_buf SWIG_cpp_back_env;
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

SWIGINTERN void SWIG_add_registry_entry(SwigObj *entry) {
  if (SWIG_registry_base == 0) {
    SWIG_registry_base = SWIG_registry = (SwigObj **) malloc(SWIG_registry_size * sizeof(SwigObj *));
    memset(SWIG_registry_base, 0, SWIG_registry_size * sizeof(SwigObj *));
  }
  *SWIG_registry = entry;
  SWIG_registry++;
  if ((SWIG_registry - SWIG_registry_base) == SWIG_registry_size) {
    SWIG_registry = SWIG_registry_base;
    SWIG_registry_size += SWIG_REGISTRY_INIT;
    int new_size = SWIG_registry_size * sizeof(SwigObj *);
    SWIG_registry_base = (SwigObj **) malloc(new_size);
    memset(SWIG_registry_base, 0, new_size);
    memcpy(SWIG_registry_base, SWIG_registry, (SWIG_registry_size - SWIG_REGISTRY_INIT) * sizeof(SwigObj *));
    free(SWIG_registry);
    SWIG_registry = SWIG_registry_base + (SWIG_registry_size - SWIG_REGISTRY_INIT);
  }
}

SWIGINTERN void SWIG_remove_registry_entry(SwigObj *entry) {
  int i;
  for (i = 0; i < SWIG_registry_size; ++i) {
    if (*(SWIG_registry_base + i) == entry) {
      *(SWIG_registry_base + i) = 0;
      break;
    }
  }
}

SWIGINTERN void SWIG_cleanup() {
  if (SWIG_rt_stack_base)
    free(SWIG_rt_stack_base);
  if (SWIG_exc.msg)
   free(SWIG_exc.msg);
  if (SWIG_exc.klass) {
    if (SWIG_exc.klass->typenames)
      free(SWIG_exc.klass->typenames);
    free(SWIG_exc.klass);
  }
  int i;
  if (SWIG_registry_base) {
    for (i = 0; i < SWIG_registry_size; ++i) {
      if (*(SWIG_registry_base + i)) {
        SWIG_destroy_object(*(SWIG_registry_base + i));
        *(SWIG_registry_base + i)  = 0;
      }
    }
  }
  free(SWIG_registry_base);
  SWIG_registry_base = 0;
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
  else if (SWIG_exc.klass) {
    int i = 0;
    while (SWIG_exc.klass->typenames[i]) {
      if (strcmp(SWIG_exc.klass->typenames[i++], type) == 0) {
        result = 1;
        break;
      }
    }
  }
  if (result) {
    SWIG_rt_stack_pop();
    SWIG_exc.handled = 1;
  }
  return result;
}

SWIGEXPORTC void SWIG_rt_throw(SwigObj *klass, const char *msg) {
  if (SWIG_exc.msg) {
    free(SWIG_exc.msg);
    SWIG_exc.msg = (char *) 0;
  }
  if (msg) {
    SWIG_exc.msg = (char *) malloc(strlen(msg) + 1);
    strcpy(SWIG_exc.msg, msg);
  }
  SWIG_exc.klass = klass;
  SWIG_exc.handled = 0;
  longjmp(SWIG_rt_env, 1);
}

SWIGEXPORTC void SWIG_rt_unhandled() {
  if (SWIG_exc.msg) { 
    free(SWIG_exc.msg);
    SWIG_exc.msg = 0;
  }
  SWIG_rt_stack_pop();
  longjmp(SWIG_rt_env, SWIG_exc.code);
}

SWIGEXPORTC void SWIG_rt_endtry() {
  if (SWIG_exc.handled) {
    if (setjmp(SWIG_rt_env) == 0) {
      SWIG_rt_stack_push();
      longjmp(SWIG_cpp_back_env, 1);
    }
  }
  else {
    SWIG_rt_stack_pop();  // pop the SWIG_try context
  }
}

SWIGEXPORTC int SWIG_exit(int code) {
  SWIG_cleanup();
  exit(code);
}

#ifdef __cplusplus
}
#endif

SWIGINTERN void SWIG_terminate() {
  fprintf(stderr, "Unhandled exception: %s\n%s\nExitting...\n", 
    SWIG_exc.klass->typenames[0],
    SWIG_exc.msg ? SWIG_exc.msg : "");
  SWIG_exit(SWIG_exc.code);
}

SWIGINTERN void SWIG_Runtime_init() {
  int i, code;
  if (!SWIG_rt_init) {
    SWIG_rt_init = 1;
    SWIG_rt_stack_base = SWIG_rt_stack_ptr = (jmp_buf *) malloc(sizeof(jmp_buf) * SWIG_MAX_RT_STACK);
    if (SWIG_exc.code = setjmp(SWIG_rt_env)) {
      // deallocate C++ exception
      if (setjmp(SWIG_rt_env) == 0) {
        SWIG_rt_stack_push();
        SWIG_exc.handled = 1;
        longjmp(SWIG_cpp_back_env, 1);
      }
      SWIG_terminate();
    }
  }
}

#define SWIG_CThrowException(klass, msg) \
  if (setjmp(SWIG_cpp_back_env) == 0) \
    SWIG_rt_throw((SwigObj *) klass, msg);

%}

%insert("proxy_header") %{
// special value indicating any type of exception like 'catch(...)'
#define SWIG_AnyException "SWIG_AnyException"

#include <setjmp.h>

SWIGIMPORT jmp_buf SWIG_rt_env;

typedef struct {
  void *obj;
  const char **typenames;
} SwigObj;

SWIGIMPORT struct SWIG_exc_struct {
  int code;
  char *msg;
  SwigObj *klass;
} SWIG_exc;

SWIGIMPORT void SWIG_rt_try();
SWIGIMPORT int SWIG_rt_catch(const char *type);
SWIGIMPORT void SWIG_rt_throw(SwigObj *klass, const char * msg);
SWIGIMPORT int SWIG_rt_unhandled();
SWIGIMPORT void SWIG_rt_endtry();
SWIGIMPORT int SWIG_exit(int code);

#define SWIG_try \
  SWIG_rt_try(); \
  if ((SWIG_exc.code = setjmp(SWIG_rt_env)) == 0) 
#define SWIG_catch(type) else if (SWIG_rt_catch(#type))
#define SWIG_throw(klass) SWIG_rt_throw((SwigObj *) klass, 0);
#define SWIG_throw_msg(klass, msg) SWIG_rt_throw((SwigObj *) klass, msg);
#define SWIG_endtry else SWIG_rt_unhandled(); SWIG_rt_endtry();
%}

