/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * Javascript support code
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <quickjs.h>
#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>


/* Max length of type name */
#define SWIG_QUICKJS_CLASS_NAME_MAX 1024

/* macro to replace the QuickJS macros, which are not C++ compatible */
#define SWIG_JS_CFUNC_DEF(name, length, func1) { name, length, func1 }
#define SWIG_JS_CGETSET_DEF(name, fgetter, fsetter) { name, fgetter, fsetter }

enum {
  SWIG_CONST_TYPE_ENUM,
  SWIG_CONST_TYPE_BOOL,
  SWIG_CONST_TYPE_INT8,
  SWIG_CONST_TYPE_INT32,
  SWIG_CONST_TYPE_UINT32,
  SWIG_CONST_TYPE_INT64,
  SWIG_CONST_TYPE_UINT64,
  SWIG_CONST_TYPE_DOUBLE,
  SWIG_CONST_TYPE_CHAR,
  SWIG_CONST_TYPE_STRING,
  SWIG_CONST_TYPE_OBJECT,
  SWIG_CONST_TYPE_UNDEFINED
};
#define SWIG_JS_PROP_ENUM_DEF(name, val) { name, SWIG_CONST_TYPE_INT64, NULL, 0, (int64_t)val, 0.0 }
#define SWIG_JS_PROP_BOOL_DEF(name, val) { name, SWIG_CONST_TYPE_BOOL, NULL, (int32_t)val, 0, 0.0 }
#define SWIG_JS_PROP_INT32_DEF(name, val) { name, SWIG_CONST_TYPE_INT32, NULL, val, 0, 0.0 }
#define SWIG_JS_PROP_UINT32_DEF(name, val) { name, SWIG_CONST_TYPE_UINT32, NULL, (int32_t)val, 0, 0.0 }
#define SWIG_JS_PROP_INT64_DEF(name, val) { name, SWIG_CONST_TYPE_INT64, NULL, 0, val, 0.0 }
#define SWIG_JS_PROP_UINT64_DEF(name, val) { name, SWIG_CONST_TYPE_UINT64, NULL, 0, (int64_t)val, 0.0 }
#define SWIG_JS_PROP_CHAR_DEF(name, val) { name, SWIG_CONST_TYPE_CHAR, NULL, (int32_t)val, 0, 0.0 }
#define SWIG_JS_PROP_DOUBLE_DEF(name, val) { name, SWIG_CONST_TYPE_DOUBLE, NULL, 0, 0, val }
#define SWIG_JS_PROP_STRING_DEF(name, val) { name, SWIG_CONST_TYPE_STRING, val, 0, 0, 0.0 }
#define SWIG_JS_PROP_UNDEFINED_DEF(name, val) { name, SWIG_CONST_TYPE_UNDEFINED, NULL, 0, 0, 0.0 }

typedef struct {
  const char *name;
  uint8_t length;
  JSCFunction *func;
} SWIG_QuickJS_FunctionListEntry;

typedef struct {
  const char *name;
  JSValue (*getter)(JSContext *ctx, JSValueConst this_val);
  JSValue (*setter)(JSContext *ctx, JSValueConst this_val, JSValueConst val);
} SWIG_QuickJS_VariableListEntry;

typedef struct {
  const char *name;
  int8_t tag;
  const char *str;
  int32_t i32; /* includes bool, int and unsigned */
  int64_t i64; /* includes enum, long, long long, usigned long, unsigned long long */
  double f64; /* includes float and double */
} SWIG_QuickJS_ConstantListEntry;

typedef struct {
  unsigned magic;
  const char *class_name;
  JSClassFinalizer *dtor;
  JSCFunction *ctor;
  JSValue base_prototype;
  JSClassID class_id;
  JSValue prototype;
  const SWIG_QuickJS_FunctionListEntry *functions;
  int functions_num;
  const SWIG_QuickJS_VariableListEntry *variables;
  int variables_num;
  const SWIG_QuickJS_ConstantListEntry *constants;
  int constants_num;
  const char **bases;
  int bases_num;
} SWIG_QuickJS_ClassDefinition;

#define countof(x) (sizeof(x) / sizeof((x)[0]))
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */

%insert(runtime) "javascriptrun.swg";      /* Runtime support */
