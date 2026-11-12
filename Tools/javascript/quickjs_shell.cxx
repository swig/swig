#include <stdio.h>
#include <stdbool.h>
#include <quickjs.h>
#include <quickjs-libc.h>

#include "js_shell.h"



/* #define QUICKJS_SHELL_DEBUG 1 */
#define MAXPATH 1000

#ifndef countof
#define countof(x) (sizeof(x) / sizeof((x)[0]))
#endif
#ifndef FALSE
enum {
    FALSE = 0,
    TRUE = 1,
};
#endif

extern "C" {
/*
 * "C" functions to interface the QuickJS engine
 */

/* Create a JS context and load the standard modules, also used to initialize the worker context */
static JSContext *QuickJS_NewCustomContext(JSRuntime *rt)
{
    JSContext *ctx;
    ctx = JS_NewContext(rt);
    if (!ctx)
        return NULL;
    /* system modules */
    js_init_module_std(ctx, "std");
    js_init_module_os(ctx, "os");
    return ctx;
}

/*
 * quickjs_load_module: load a dynamic module (.so)
 * Return the loaded module or an exception
 */
static JSValue quickjs_load_module(JSContext *ctx, const char *basename, const char *filename)
{
  JSValue prom;
  JSValue r;
  JSAtom atom;
  JSValue jsresult;

  prom = JS_LoadModule(ctx, basename, filename);
  if(JS_IsException(prom)) {
#ifdef QUICKJS_SHELL_DEBUG
    printf("load_module (load): cannot load module %s\n", filename);
#endif
    return JS_EXCEPTION;
  }

  /* await frees the prom object and returns the promise result or an exception */
  r = js_std_await(ctx, prom);
  if(JS_IsException(r)) {
#ifdef QUICKJS_SHELL_DEBUG
    printf("load_module (await): cannot load module %s\n", filename);
#endif
    /* promise rejection is handled */
    js_std_promise_rejection_tracker(ctx, prom, JS_UNDEFINED, true, NULL);
    return JS_EXCEPTION;
  }

  atom = JS_NewAtom(ctx, basename);
  if (JS_HasProperty(ctx, r, atom)) {
    /* module loaded as basename */
    jsresult = JS_GetProperty(ctx, r, atom);
    if(JS_IsObject(jsresult)) {
#ifdef QUICKJS_SHELL_DEBUG
      printf("load_module: %s loaded from %s\n", basename, filename);
#endif
    } else {
      JS_FreeAtom(ctx, atom);
#ifdef QUICKJS_SHELL_DEBUG
      printf("load_module: warning, loaded module from %s does not define %s\n", filename, basename);
#endif
      return JS_ThrowReferenceError(ctx, "%s not defined", basename);
    }
  } else {
    JS_FreeAtom(ctx, atom);
#ifdef QUICKJS_SHELL_DEBUG
    printf("load_module: %s not found inside module %s\n", basename, filename);
#endif
    return JS_ThrowReferenceError(ctx, "%s not found", basename);
  }
  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, r);

  return jsresult;
}

/*
 * quickjs_require: implement the JS wrapper around load module
 */
static JSValue quickjs_require(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv)
{
  JSValue jsresult;
  const char *basename;
  char filename[MAXPATH];

  if(argc != 1) {
    return JS_ThrowTypeError(ctx, "require: expect 1 argument (%d)", argc);
  }
  if(!JS_IsString(argv[0])) {
    return JS_ThrowTypeError(ctx, "require: expect a string as argument");
  }
  basename = JS_ToCString(ctx, argv[0]);
  if(!basename || strlen(basename) == 0) {
    return JS_ThrowTypeError(ctx, "require: expect a  non-empty string as argument");
  }

  snprintf(filename, MAXPATH, "%s.so", basename);
  jsresult = quickjs_load_module(ctx, basename, filename);

  JS_FreeCString(ctx, basename);
  return jsresult;
}

/*
 * quickjs_assert: implement an assert function
 * The check is OK if the expression evaluates to 'true' (in a very broad
 * sense: boolean: its value; number: != 0; string: not empty; object: alwas true
 * undefined: false, null: false).
 */
static JSValue quickjs_assert(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv)
{
  int result;
  int32_t i32;
  double f64;
  JSValue err;
  const char *s;

  if(argc != 1) {
#ifdef QUICKJS_SHELL_DEBUG
    printf("assert: bad number of arguments: %d\n", argc);
#endif
    return JS_ThrowTypeError(ctx, "assert: expect 1 argument (%d)", argc);
  }
  if(JS_IsUndefined(argv[0]) || JS_IsNull(argv[0])) {
    result = 0;
  } else if(JS_IsBool(argv[0])) {
    result = JS_ToBool(ctx, argv[0]);
  } else if (JS_IsNumber(argv[0])) {
    if(!JS_ToInt32(ctx, &i32, argv[0])) {
      result = (i32 != 0);
    } else {
      (void)JS_ToFloat64(ctx, &f64, argv[0]);
      result = (f64 != 0.0);
    }
  } else if (JS_IsString(argv[0])) {
    s = JS_ToCString(ctx, argv[0]);
    result = (strlen(s) > 0);
    JS_FreeCString(ctx, s);
  } else if (JS_IsObject(argv[0])) {
    result = 1;
  } else {
    return JS_ThrowTypeError(ctx, "assert: expect a \"boolean\" expression as argument");
  }
  if(!result) {
    err  = JS_NewError(ctx);
    JS_SetPropertyStr(ctx, err, "message", JS_NewString(ctx, "assertion failed"));
    return JS_Throw(ctx, err);
  }
  return JS_UNDEFINED;
}

} /* extern "C" */


class QuickJSShell: public JSShell {

public:
  QuickJSShell() {
    rt = NULL;
    ctx = NULL;
    strict = 0;
  }

  virtual ~QuickJSShell();

  virtual bool RunScript(const std::string &scriptPath);

  virtual bool RunShell();


protected:

  virtual bool InitializeEngine();

  virtual bool ExecuteScript(const std::string &source, const std::string &scriptPath);

  virtual bool DisposeEngine();

private:
  bool EvalBuffer(const char *buf, int buf_len, const char *filename, int eval_flags);
  bool EvalFile(const char *filename, int module, int strict);

  JSRuntime *rt;
  JSContext *ctx;
  int strict;
};

QuickJSShell::~QuickJSShell() {
  if(rt) {
    js_std_free_handlers(rt);
  }
  if(ctx) {
    JS_FreeContext(ctx);
    ctx = NULL;
  }
  if(rt) {
    JS_FreeRuntime(rt);
    rt = NULL;
  }
}

bool QuickJSShell::InitializeEngine() {
  if(rt) {
    js_std_free_handlers(rt);
  }
  if(ctx) {
    JS_FreeContext(ctx);
    ctx = NULL;
  }
  if(rt) {
    JS_FreeRuntime(rt);
    rt = NULL;
  }

  rt = JS_NewRuntime();
  if (!rt) {
      fprintf(stderr, "quickjs: cannot allocate JS runtime\n");
      return false;
  }

  js_std_set_worker_new_context_func(QuickJS_NewCustomContext);
  js_std_init_handlers(rt);
  ctx = QuickJS_NewCustomContext(rt);
  if (!ctx) {
      fprintf(stderr, "quickjs: cannot allocate JS context\n");
      return false;
  }

  /* loader for ES6 modules */
  JS_SetModuleLoaderFunc2(rt, NULL, js_module_loader, js_module_check_attributes, NULL);

  JS_SetHostPromiseRejectionTracker(rt, js_std_promise_rejection_tracker,
                                        NULL);

  js_std_add_helpers(ctx, 0, NULL);

  /* add the C primitives in the context */
  JSValueConst globalObject;
  int r;

  globalObject = JS_GetGlobalObject(ctx);
  r = JS_SetPropertyStr(ctx, globalObject, "require",
      JS_NewCFunction(ctx, quickjs_require, "require", 1));
  if (r == -1) {
    JS_FreeValue(ctx, globalObject);
    return false;
  }
  r = JS_SetPropertyStr(ctx, globalObject, "assert",
      JS_NewCFunction(ctx, quickjs_assert, "assert", 1));
  if (r == -1) {
    JS_FreeValue(ctx, globalObject);
    return false;
  }
  JS_FreeValue(ctx, globalObject);

  return true;
}

bool QuickJSShell::DisposeEngine() {
  if(rt) {
    js_std_free_handlers(rt);
  }
  if(ctx) {
    JS_FreeContext(ctx);
    ctx = NULL;
  }
  if(rt) {
    JS_FreeRuntime(rt);
    rt = NULL;
  }
  return true;
}

bool QuickJSShell::RunScript(const std::string &scriptPath) {
  if(!InitializeEngine())
    return false;

  if (!EvalFile(scriptPath.c_str(), -1, strict))
    return false;

  js_std_loop(ctx);
  return true;
}

bool QuickJSShell::RunShell() {
  if(!InitializeEngine())
    return false;

  static const int kBufferSize = 1024;
  while (true) {
    char buffer[kBufferSize];
    printf("> ");
    char *str = fgets(buffer, kBufferSize, stdin);
    if (str == NULL) break;
    if(!EvalBuffer(str, strlen(str), "<cmdline>", strict?JS_EVAL_FLAG_STRICT:0)) {
      printf("Error in expression '%s'\n", str);
      return false;
    }
  }
  printf("\n");

  DisposeEngine();
  return true;
}

bool QuickJSShell::ExecuteScript(const std::string &source, const std::string &scriptPath) {
  if(!EvalBuffer(source.c_str(), source.length(), "<cmdline>", strict?JS_EVAL_FLAG_STRICT:0)) {
    printf("Error in expression '%s'\n", source.c_str());
    return false;
  }

  return true;
}

bool QuickJSShell::EvalBuffer(const char *buf, int buf_len,
                    const char *filename, int eval_flags) {
    JSValue val;
    bool ret;

    if ((eval_flags & JS_EVAL_TYPE_MASK) == JS_EVAL_TYPE_MODULE) {
        /* for the modules, we compile then run to be able to set
           import.meta */
        val = JS_Eval(ctx, buf, buf_len, filename,
                      eval_flags | JS_EVAL_FLAG_COMPILE_ONLY);
        if (!JS_IsException(val)) {
            js_module_set_import_meta(ctx, val, TRUE, TRUE);
            val = JS_EvalFunction(ctx, val);
        }
        val = js_std_await(ctx, val);
    } else {
        val = JS_Eval(ctx, buf, buf_len, filename, eval_flags);
    }
    if (JS_IsException(val)) {
        js_std_dump_error(ctx);
        ret = false;
    } else {
        ret = true;
    }
    JS_FreeValue(ctx, val);
    return ret;
}

bool QuickJSShell::EvalFile(const char *filename, int module, int strict) {
    char *buf;
    int ret, eval_flags;
    size_t buf_len;

    buf = (char*)js_load_file(ctx, &buf_len, filename);
    if (!buf) {
        perror(filename);
        exit(1);
    }

    if (module < 0) {
        module = JS_DetectModule((const char *)buf, buf_len);
    }
    if (module) {
        eval_flags = JS_EVAL_TYPE_MODULE;
    } else {
        eval_flags = JS_EVAL_TYPE_GLOBAL;
        if (strict)
            eval_flags |= JS_EVAL_FLAG_STRICT;
    }
    ret = EvalBuffer(buf, buf_len, filename, eval_flags);
    js_free(ctx, buf);
    return ret;
}

JSShell *QuickJSShell_Create() {
  return new QuickJSShell();
}
