/*
 * swigqjs.c
 *
 * Copy of the QuickJS qjs.c file, the standard
 * interpreter with some modifications
 * - -e expr option is evaluated first, it is not
 *    exclusive of running a file
 * - 'require' and 'assert' functions added
 * - interactive mode and file includes removed
 */

#include <stdio.h>
#include <stdbool.h>
#include <quickjs.h>
#include <cutils.h>
#include <quickjs-libc.h>


/* #define MYQJS_DEBUG 1 */
#define MAXPATH 1000


static int eval_buf(JSContext *ctx, const void *buf, int buf_len,
                    const char *filename, int eval_flags)
{
    JSValue val;
    int ret;

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
        ret = -1;
    } else {
        ret = 0;
    }
    JS_FreeValue(ctx, val);
    return ret;
}

static int eval_file(JSContext *ctx, const char *filename, int module)
{
    uint8_t *buf;
    int ret, eval_flags;
    size_t buf_len;

    buf = js_load_file(ctx, &buf_len, filename);
    if (!buf) {
        perror(filename);
        exit(1);
    }

    if (module < 0) {
        module = (has_suffix(filename, ".mjs") ||
                  JS_DetectModule((const char *)buf, buf_len));
    }
    if (module)
        eval_flags = JS_EVAL_TYPE_MODULE;
    else
        eval_flags = JS_EVAL_TYPE_GLOBAL;
    ret = eval_buf(ctx, buf, buf_len, filename, eval_flags);
    js_free(ctx, buf);
    return ret;
}

/* also used to initialize the worker context */
static JSContext *JS_NewCustomContext(JSRuntime *rt)
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
 * load_module: load a dynamic module (.so)
 * Return the loaded module or an exception
 */
JSValue myjs_load_module(JSContext *ctx, const char *basename, const char *filename)
{
  JSValue prom;
  JSValue r;
  JSAtom atom;
  JSValue jsresult;

  prom = JS_LoadModule(ctx, basename, filename);
  if(JS_IsException(prom)) {
#ifdef MYQJS_DEBUG
    printf("load_module (load): cannot load module %s\n", filename);
#endif    
    return JS_EXCEPTION;
  }
  
  /* await frees the prom object and returns the promise result or an exception */
  r = js_std_await(ctx, prom);
  if(JS_IsException(r)) {
#ifdef MYQJS_DEBUG
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
#ifdef MYQJS_DEBUG
    if(JS_IsObject(jsresult)) {
      printf("load_module: %s loaded from %s\n", basename, filename);
    }
#endif
  } else {
#ifdef MYQJS_DEBUG
    printf("load_module: %s not found inside module %s\n", basename, filename);
#endif
    return JS_ThrowReferenceError(ctx, "%s not found", basename);
  }
  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, r);
  
  return jsresult;
}

/*
 * myjs_require: implement the JS wrapper around load module
 */
JSValue myjs_require(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv)
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
  
  /* try current directory (XXX: one day, use environment variable like 'QUICKJS_CPATH' */
  snprintf(filename, MAXPATH, "%s.so", basename);
  jsresult = myjs_load_module(ctx, basename, filename);
  if(JS_IsException(jsresult)) {
    /* clear the exception */
    JS_FreeValue(ctx, JS_GetException(ctx));
    /* try default directory */
    snprintf(filename, MAXPATH, "/usr/lib/qjs/%s.so", basename);
    jsresult = myjs_load_module(ctx, basename, filename);
  }

  JS_FreeCString(ctx, basename);
  return jsresult;
}

/*
 * myjs_assert: implement an assert function
 * The check is OK if the expression evaluates to 'true' (in a very broad
 * sense: boolean: its value; number: != 0; string: not empty; object: alwas true
 * undefined: false, null: false.
 */
JSValue myjs_assert(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv)
{
  int result;
  int32_t i32;
  double f64;
  JSValue err;
  const char *s;

  if(argc != 1) {
#ifdef MYQJS_DEBUG
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

/*
 * myjs_add_functions: add the functions defined in this file in global scope
 * Return 0 is OK, -1 in case of error
 */
int myjs_add_functions(JSContext *ctx)
{
  JSValueConst globalObject;

  globalObject = JS_GetGlobalObject(ctx);
  JS_SetPropertyStr(ctx, globalObject, "require",
      JS_NewCFunction(ctx, myjs_require, "require", 1));
  JS_SetPropertyStr(ctx, globalObject, "assert",
      JS_NewCFunction(ctx, myjs_assert, "assert", 1));

  JS_FreeValue(ctx, globalObject);
  return 0;
}

#define PROG_NAME "myqjs"

void help(void)
{
#ifdef QJS_VERSION_MAJOR
      printf("QuickJS-ng version %d.%d pl%d\n"
           "usage: " PROG_NAME " [options] [file [args]]\n"
           "-h  --help         list options\n"
           "-e  --eval EXPR    evaluate EXPR\n"
           "-i  --interactive  go to interactive mode\n"
           "-I  --include file include an additional file\n"
           "    --std          make 'std' and 'os' available to the loaded script\n",
           QJS_VERSION_MAJOR, QJS_VERSION_MINOR, QJS_VERSION_PATCH);
#else
      printf("QuickJS version " CONFIG_VERSION "\n"
           "usage: " PROG_NAME " [options] [file [args]]\n"
           "-h  --help         list options\n"
           "-e  --eval EXPR    evaluate EXPR\n"
           "    --std          make 'std' and 'os' available to the loaded script\n");
#endif           
    exit(1);
}

int main(int argc, char **argv)
{
    JSRuntime *rt;
    JSContext *ctx;
    int optind;
    char *expr_list[32];
    int expr_count = 0;
    int load_std = 0;
    int i;

    /* cannot use getopt because we want to pass the command line to
       the script */
    optind = 1;
    while (optind < argc && *argv[optind] == '-') {
        char *arg = argv[optind] + 1;
        const char *longopt = "";
        /* a single - is not an option, it also stops argument scanning */
        if (!*arg)
            break;
        optind++;
        if (*arg == '-') {
            longopt = arg + 1;
            arg += strlen(arg);
            /* -- stops argument scanning */
            if (!*longopt)
                break;
        }
        for (; *arg || *longopt; longopt = "") {
            char opt = *arg;
            if (opt)
                arg++;
            if (opt == 'h' || opt == '?' || !strcmp(longopt, "help")) {
                help();
                continue;
            }
            if (opt == 'e' || !strcmp(longopt, "eval")) {
                if (optind >= argc) {
                    fprintf(stderr, "expecting expression");
                    exit(1);
                }
                if (expr_count >= countof(expr_list)) {
                    fprintf(stderr, "too many expressions");
                    exit(1);
                }
                expr_list[expr_count++] = argv[optind++];
                continue;
            }
            if (!strcmp(longopt, "std")) {
                load_std = 1;
                continue;
            }
            if (opt == 'L') {
              /* ignore for now */
              optind++;
              continue;
            }
            if (opt) {
                fprintf(stderr, "%s: unknown option '-%c'\n", argv[0], opt);
            } else {
                fprintf(stderr, "%s: unknown option '--%s'\n", argv[0], longopt);
            }
            help();
        }
    }

    rt = JS_NewRuntime();
    if (!rt) {
        fprintf(stderr, PROG_NAME ": cannot allocate JS runtime\n");
        exit(2);
    }

    js_std_set_worker_new_context_func(JS_NewCustomContext);
    js_std_init_handlers(rt);
    ctx = JS_NewCustomContext(rt);
    if (!ctx) {
        fprintf(stderr, PROG_NAME ": cannot allocate JS context\n");
        exit(2);
    }

    /* loader for ES6 modules */
    JS_SetModuleLoaderFunc2(rt, NULL, js_module_loader, js_module_check_attributes, NULL);

    JS_SetHostPromiseRejectionTracker(rt, js_std_promise_rejection_tracker,
                                          NULL);

    js_std_add_helpers(ctx, argc - optind, argv + optind);

    /* make 'std' and 'os' visible to non module code */
    if (load_std) {
        const char *str = "import * as std from 'std';\n"
            "import * as os from 'os';\n"
            "globalThis.std = std;\n"
            "globalThis.os = os;\n";
        eval_buf(ctx, str, strlen(str), "<input>", JS_EVAL_TYPE_MODULE);
    }

    myjs_add_functions(ctx);

    for(i = 0; i < expr_count; i++) {
        if (eval_buf(ctx, expr_list[i], strlen(expr_list[i]), "<cmdline>", 0)) {
          printf("Error in expression '%s'\n", expr_list[i]);
          goto fail;
        }
    }

    if (optind >= argc) {
        printf("Error: missing file to run.\n");
    } else {
        const char *filename;
        filename = argv[optind];
        if (eval_file(ctx, filename, -1))
            goto fail;
    }

    js_std_loop(ctx);

    js_std_free_handlers(rt);
    JS_FreeContext(ctx);
    JS_FreeRuntime(rt);

    return 0;
 fail:
    js_std_free_handlers(rt);
    JS_FreeContext(ctx);
    JS_FreeRuntime(rt);
    return 1;

}

