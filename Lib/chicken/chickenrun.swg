/* -*- c -*-
 * -----------------------------------------------------------------------
 * swig_lib/chicken/chickenrun.swg
 *
 * Author: John Lenz <jelenz@wisc.edu>
 * ----------------------------------------------------------------------- */

#include <chicken.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#define SWIG_malloc(size) \
  malloc(size)
#define SWIG_free(mem) \
  free(mem)
#define SWIG_MakeString(c) \
  SWIG_Chicken_MakeString(c)
#define SWIG_ConvertPtr(s, result, type, flags) \
  SWIG_Chicken_ConvertPtr(s, result, type, flags)
#define SWIG_MustGetPtr(s, type, argnum, flags) \
  SWIG_Chicken_MustGetPtr(s, type, argnum, flags)
#define SWIG_NewPointerObj(ptr, type, owner) \
  SWIG_Chicken_NewPointerObj((void*)ptr, type, owner, &known_space)
#define swig_barf SWIG_Chicken_Barf

#define SWIG_contract_assert(expr, message) if (!(expr)) { \
                                              SWIG_Chicken_Barf(SWIG_BARF1_CONTRACT_ASSERT, C_text(message)); } else

/* Runtime API */
#define SWIG_GetModule(clientdata) SWIG_Chicken_GetModule()
#define SWIG_SetModule(clientdata, pointer) SWIG_Chicken_SetModule(pointer)

#define C_swig_is_bool(x) C_truep (C_booleanp (x))
#define C_swig_is_char(x) C_truep (C_charp (x))
#define C_swig_is_fixnum(x) C_truep (C_fixnump (x))
#define C_swig_is_flonum(x) (C_truep (C_blockp (x)) && C_truep (C_flonump (x)))
#define C_swig_is_string(x) (C_truep (C_blockp (x)) && C_truep (C_stringp (x)))
#define C_swig_is_vector(x) (C_truep (C_blockp (x)) && C_truep (C_vectorp (x)))
#define C_swig_is_list(x) (C_truep (C_i_listp (x)))
#define C_swig_is_pair(x) (C_truep (C_blockp(x)) && C_truep (C_pairp(x)))
#define C_swig_is_ptr(x) (C_truep (C_blockp (x)) && C_truep (C_pointerp (x)))
#define C_swig_is_swigpointer(x) (C_truep (C_blockp(x)) && C_truep (C_swigpointerp(x)))
#define C_swig_is_closurep(x) (C_truep (C_blockp(x)) && C_truep(C_closurep(x)))

#define SWIG_APPEND_VALUE(object) \
  if (resultobj == C_SCHEME_UNDEFINED) \
    resultobj = object; \
  else { \
    C_word *pair_space = C_alloc(C_SIZEOF_PAIR); \
    if (!gswig_list_p) { \
      gswig_list_p = 1; \
      C_word *pair_space2 = C_alloc(C_SIZEOF_PAIR); \
      resultobj = C_pair(&pair_space2, resultobj, C_SCHEME_END_OF_LIST); \
      resultobjlast = resultobj; \
    } \
    C_word tmp = C_pair(&pair_space, object, C_SCHEME_END_OF_LIST); \
    C_set_block_item(resultobjlast, 1, tmp); \
    resultobjlast = tmp; \
  }

#define SWIG_POINTER_DISOWN 1

enum {
  SWIG_BARF1_BAD_ARGUMENT_TYPE /* 1 arg */,
  SWIG_BARF1_ARGUMENT_NULL /* 1 arg */,
  SWIG_BARF1_CONTRACT_ASSERT /* 1 arg */,
};

typedef C_word (*swig_chicken_destructor)(C_word,C_word,C_word,C_word);
typedef struct swig_chicken_clientdata {
  void *gc_proxy_create;
  swig_chicken_destructor destroy;
} swig_chicken_clientdata;
  
static char *
SWIG_Chicken_MakeString(C_word str) {
  char *ret;
  size_t l;

  l = C_header_size(str);
  ret = (char *) SWIG_malloc( (l + 1) * sizeof(char));
  if (!ret) return NULL;

  memcpy(ret, C_c_string(str), l);
  ret[l] = '\0';
  return ret;
}

static C_word SWIG_Chicken_LookupSymbol(char *name, C_SYMBOL_TABLE *stable) {
  C_word *a = C_alloc(C_SIZEOF_STRING (strlen (name)));
  C_word n = C_string2(&a, name);
  C_word sym = C_find_symbol(n, stable);
  if (C_truep(sym)) {
    return C_symbol_value(sym);
  } else {
    return C_SCHEME_FALSE;
  }
}

/* Just a helper function.  Do not export it */
static void SWIG_Chicken_Panic (C_char *) C_noret;
static void SWIG_Chicken_Panic (C_char *msg)
{
  C_word *a = C_alloc (C_SIZEOF_STRING (strlen (msg)));
  C_word scmmsg = C_string2 (&a, msg);
  C_halt (scmmsg);
  exit (5); /* should never get here */
}

static void
SWIG_Chicken_Barf(int code, C_char *msg, ...) C_noret;
static void
SWIG_Chicken_Barf(int code, C_char *msg, ...)
{
  char *errorhook = C_text("\003syserror-hook");
  C_word *a = C_alloc (C_SIZEOF_STRING (strlen (errorhook)));
  C_word err = C_intern2 (&a, errorhook);
  int c = -1;
  int i, barfval;
  va_list v;

  
  C_temporary_stack = C_temporary_stack_bottom;
  err = C_block_item(err, 0);

  if(C_immediatep (err))
    SWIG_Chicken_Panic (C_text ("`##sys#error-hook' is not defined"));

  switch (code) {
  case SWIG_BARF1_BAD_ARGUMENT_TYPE:
    barfval = C_BAD_ARGUMENT_TYPE_ERROR;
    c = 1;
    break;
  case SWIG_BARF1_ARGUMENT_NULL:
    barfval = C_BAD_ARGUMENT_TYPE_ERROR;
    c = 1;
    break;
  case SWIG_BARF1_CONTRACT_ASSERT:
    barfval = C_OUT_OF_RANGE_ERROR;
    c = 1;
    break;
  default:
    SWIG_Chicken_Panic (C_text (msg));
  };

  if(c > 0 && !C_immediatep (err)) {
    C_save (C_fix (barfval));

    i = c;
    if (i) {
      C_word *b = C_alloc (C_SIZEOF_STRING (strlen (msg)));
      C_word scmmsg = C_string2 (&b, msg);
      C_save (scmmsg);
      i--;
    }

    va_start (v, msg);

    while(i--)
      C_save (va_arg (v, C_word));

    va_end (v);
    C_do_apply (c + 1, err, 
		C_SCHEME_UNDEFINED);  /* <- no continuation is passed:
					 '##sys#error-hook' may not
					 return! */
  }
  else if (msg) {
    SWIG_Chicken_Panic (msg);
  }
  else {
    SWIG_Chicken_Panic (C_text ("unspecified panic"));
  }
}

static void
SWIG_Chicken_Finalizer(C_word argc, C_word closure, C_word continuation, C_word s)
{
  swig_type_info *type;
  swig_chicken_clientdata *cdata;

  if (argc == 3 && s != C_SCHEME_FALSE && C_swig_is_swigpointer(s)) {
    type = (swig_type_info *) C_block_item(s, 1);
    if (type) {
      cdata = (swig_chicken_clientdata *) type->clientdata;
      if (cdata && cdata->destroy) {
	/* this will not return, but will continue correctly */
        cdata->destroy(3,closure,continuation,s);
      }
    }
  }
  C_kontinue(continuation, C_SCHEME_UNDEFINED);
}
static C_word finalizer_obj[2] = {(C_word) (C_CLOSURE_TYPE|1), (C_word) SWIG_Chicken_Finalizer};

static C_word
SWIG_Chicken_NewPointerObj(void *ptr, swig_type_info *type, int owner, C_word **data)
{
  swig_chicken_clientdata *cdata = (swig_chicken_clientdata *) type->clientdata;

  if (ptr == NULL)
    return C_SCHEME_FALSE;
  else {
    C_word cptr = C_swigmpointer(data, ptr, type);
    /* add finalizer to object */
    if (owner)
      C_do_register_finalizer(cptr, (C_word) finalizer_obj);

    /* wrap the result inside a proxy class if one is available */
    if (cdata && cdata->gc_proxy_create) {
      C_word closure = CHICKEN_gc_root_ref(cdata->gc_proxy_create);
      if (C_swig_is_closurep(closure)) {
        C_save(cptr);
        return C_callback(closure, 1);
      }
    }
    return cptr;
  }
}

/* Return 0 if successful. */
static int
SWIG_Chicken_ConvertPtr(C_word s, void **result, swig_type_info *type, int flags)
{
  swig_cast_info *cast;
  swig_type_info *from;

  if (s == C_SCHEME_FALSE) {
    *result = NULL;
  } else if (C_swig_is_swigpointer(s)) {
    /* try and convert type */
    from = (swig_type_info *) C_block_item(s, 1);
    if (!from) return 1;
    if (type) {
      cast = SWIG_TypeCheckStruct(from, type);
      if (cast) {
        *result = SWIG_TypeCast(cast, (void *) C_block_item(s, 0));
      } else {
        return 1;
      }
    } else {
      *result = (void *) C_block_item(s, 0);
    }

    /* check if we are disowning this object */
    if (flags & SWIG_POINTER_DISOWN) {
      C_do_unregister_finalizer(s);
    }
  }

  return 0;
}

static SWIGINLINE void *
SWIG_Chicken_MustGetPtr (C_word s, swig_type_info *type, int argnum, int flags)
{
  void *result;
  if (SWIG_Chicken_ConvertPtr(s, &result, type, flags)) {
    /* type mismatch */
    SWIG_Chicken_Barf(SWIG_BARF1_BAD_ARGUMENT_TYPE, 
      "Type error in argument %i: expected a %s.", argnum, type->name);
  }
  return result;
}

static char *chicken_runtimevar_name = "type_pointer" SWIG_TYPE_TABLE_NAME;

static swig_module_info *
SWIG_Chicken_GetModule() {
    swig_module_info *ret = 0;
    C_word sym;

    /* lookup the type pointer... it is stored in it's own symbol table */
    C_SYMBOL_TABLE *stable = C_find_symbol_table("swig_runtime_data" SWIG_RUNTIME_VERSION);
    if (stable != NULL) {
      sym = SWIG_Chicken_LookupSymbol(chicken_runtimevar_name, stable);
      if (C_truep(sym) && C_swig_is_ptr(sym)) {
        ret = (swig_module_info *) C_block_item(sym, 0);
      }
    }

    return ret;
}

static void
SWIG_Chicken_SetModule(swig_module_info *module) {
    C_word *a;
    C_SYMBOL_TABLE *stable;
    C_word sym;
    C_word pointer;
    static C_word *space = 0;
    
    /* type pointer is stored in it's own symbol table */
    stable = C_find_symbol_table("swig_runtime_data" SWIG_RUNTIME_VERSION);
    if (stable == NULL) {
      stable = C_new_symbol_table("swig_runtime_data" SWIG_RUNTIME_VERSION, 16);
    }

    if (!space) {
      space = (C_word *) C_malloc((C_SIZEOF_POINTER + C_SIZEOF_INTERNED_SYMBOL(C_strlen(chicken_runtimevar_name))) * sizeof(C_word));
    }
    a = space;
    pointer = C_mpointer(&a, (void *) module);
    sym = C_intern_in(&a, C_strlen(chicken_runtimevar_name), chicken_runtimevar_name, stable);
    C_set_block_item(sym, 0, pointer);
}

#ifdef __cplusplus
}
#endif
