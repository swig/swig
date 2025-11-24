/* ----------------------------------------------------------------------------
 *  Errors and exceptions
 *
 * ---------------------------------------------------------------------------*/

#define SWIG_Error(code, msg)     SWIG_QuickJS_exception(ctx, code, msg)
#define SWIG_exception(code, msg) do { SWIG_QuickJS_exception(ctx, code, msg); SWIG_fail; } while (0)
#define SWIG_fail                 goto fail

#ifdef __cplusplus
extern "C" {
#endif

/* forward declarations */
const char *SWIG_QuickJS_ValueStr(JSContext *ctx, JSValueConst this_val);
const char *SWIG_QuickJS_typename(JSContext *ctx, JSValueConst this_val);
SWIGRUNTIME int SWIG_QuickJS_IsSwigObject(JSContext *ctx, JSValueConst this_val);
SWIGINTERN JSValueConst SWIG_QuickJS_baseRegistryClassLookup(JSContext *ctx, const char *name);


/*
 * SWIG_QuickJS_exception: throw an exception with a code  and a message.
 */
SWIGRUNTIME void SWIG_QuickJS_exception(JSContext *ctx, int code, const char* msg)
{
  JSValue exception;
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TRACE)
  printf("SWIG_QuickJS_exception: %s\n", msg);
#endif

  exception = JS_NewError(ctx);
  JS_DefinePropertyValueStr(ctx, exception, "message",
                           JS_NewString(ctx, msg?msg:"exception"),
                           JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  JS_DefinePropertyValueStr(ctx, exception, "code",
                           JS_NewInt32(ctx, code),
                           JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  JS_Throw(ctx, exception);
}

#define SWIG_QUICKJS_VALUE_MAX_LEN 512
#define SWIG_QUICKJS_EXCEPTION_MSG_MAX_LEN 600

static void SWIG_QuickJS_strcat(void *s, const char *v, long unsigned len) {
  if(v && len>=1 && (strlen((const char *)s)+len<SWIG_QUICKJS_VALUE_MAX_LEN)) strncat((char*)s, v, len);
}

const char *SWIG_QuickJS_ValueStr(JSContext *ctx, JSValueConst this_val)
{
  /* useful in callbacks, when the call result is exception: allows to
   * print more details on the exception that occurred. But this
   * can be useful in other cases. */
  int has_prop = false;
  JSValue obj;
  JSPropertyEnum *prop_names;
  uint32_t prop_num;
  JSValue prop_value;
  int j;

  static char val[SWIG_QUICKJS_VALUE_MAX_LEN] = "";

  JS_PrintValue(ctx, SWIG_QuickJS_strcat, val, this_val, NULL);
  if(JS_IsObject(this_val)) {
    has_prop = true;
    obj = JS_DupValue(ctx, this_val);
  } else if(JS_IsException(this_val)) {
    has_prop = true;
    // this clears the exception: dup the error object and throw it again
    obj = JS_GetException(ctx);
    JS_Throw(ctx, JS_DupValue(ctx,obj));
  }

  if(has_prop) {
    /* get the own properties of the value */
    JS_GetOwnPropertyNames(ctx, &prop_names, &prop_num, obj, JS_GPN_STRING_MASK);
    for(j=0; j<(int)prop_num; j++) {
      prop_value = JS_GetProperty(ctx, obj, prop_names[j].atom);
      JS_PrintValue(ctx, SWIG_QuickJS_strcat, val, prop_value, NULL);
      JS_FreeValue(ctx, prop_value);
    }
    JS_FreePropertyEnum(ctx, prop_names, prop_num);
  }
  return val;
}

SWIGRUNTIME void SWIG_QuickJS_raise(JSContext *ctx, JSValueConst obj, const char *type, swig_type_info *desc)
{
  JSValue exception;
  char val[SWIG_QUICKJS_VALUE_MAX_LEN] = "";
  char buffer[SWIG_QUICKJS_EXCEPTION_MSG_MAX_LEN];
  JS_PrintValue(ctx, SWIG_QuickJS_strcat, val, obj, NULL);
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TRACE)
  printf("SWIG_QuickJS_raise: %s\n", val);
#endif
  exception = JS_NewError(ctx);
  snprintf(buffer, SWIG_QUICKJS_EXCEPTION_MSG_MAX_LEN, "%s (%s)", val, SWIG_QuickJS_typename(ctx,obj));
  JS_DefinePropertyValueStr(ctx, exception, "message",
                           JS_NewString(ctx, buffer),
                           JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  JS_FreeValue(ctx, obj);
  JS_Throw(ctx, exception);
}

/* ----------------------------------------------------------------------------
 *  SWIG QuickJS internal classes
 *
 * ---------------------------------------------------------------------------*/

/* ----------------------------------------------------------------------------
 *  The prototype object (prototype of wrapped classes
 *  Note: these are stored in the class registry to get the class definitions
 *  when needed
 *
 * ---------------------------------------------------------------------------*/
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
#define SWIG_PROTOTYPE_CLASS_MAGIC 0xc1adc1ad
#endif

SWIGRUNTIME const SWIG_QuickJS_FunctionListEntry swig_prototype_class_prototype_functions[] = {
};

static SWIG_QuickJS_ClassDefinition SWIG_QuickJS_swig_prototype_class_class_definition = \
  {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
    SWIG_PROTOTYPE_CLASS_MAGIC,
#endif
    "swig_prototype_class", NULL, NULL, JS_UNDEFINED, JS_INVALID_CLASS_ID, JS_UNDEFINED,
    swig_prototype_class_prototype_functions, countof(swig_prototype_class_prototype_functions), NULL, 0, NULL, 0, NULL, 0};


/* ----------------------------------------------------------------------------
 *  The parent class of all Proxies - SwigObject
 *
 * ---------------------------------------------------------------------------*/
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
#define SWIG_OBJECT_MAGIC 0xc01dcafe
#endif

typedef struct {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
  unsigned magic;
#endif
  swig_type_info *type;
  void *ptr;
  bool own;
} SwigObjectData;

/*
 * Wrapped functions of SwigOjects
 */
SWIGRUNTIME JSValue _wrap_SwigObject_disown(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
  SwigObjectData *swig_object;
  
  if(argc!=0) {
    SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for SwigObject_disown.");
  }
    
  if(SWIG_QuickJS_IsSwigObject(ctx, this_val) <= 0) {
    return JS_ThrowTypeError(ctx, "SWIGObject_disown");
  }

  swig_object = (SwigObjectData *)JS_GetOpaque(this_val, JS_GetClassID(this_val));
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_PTRTRACE)
   printf("SwigObject_disown: %p (%p) (own=%d)\n", swig_object, swig_object->ptr, swig_object->own);
#endif
  swig_object->own = false;

  return JS_UNDEFINED;
  goto fail;
  fail:
  return JS_EXCEPTION;  
}

SWIGRUNTIME JSValue _wrap_SwigObject_equals(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
  JSValue jsresult;
  bool result;
  SwigObjectData *swig_object, *swig_object2;

  if(argc!=1) {
    SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for SwigObject_equals.");
  }

  if(SWIG_QuickJS_IsSwigObject(ctx, this_val) <= 0) {
    return JS_ThrowTypeError(ctx, "SwigObject_equals (lv)");
  }
  if(SWIG_QuickJS_IsSwigObject(ctx, argv[0]) <= 0) {
    return JS_ThrowTypeError(ctx, "SwigObject_equals (rv)");
  }

  swig_object = (SwigObjectData *)JS_GetOpaque(this_val, JS_GetClassID(this_val));
  swig_object2 = (SwigObjectData *)JS_GetOpaque(argv[0], JS_GetClassID(argv[0]));

  result = (swig_object->ptr == swig_object2->ptr);
  jsresult = JS_NewBool(ctx, result);

  return jsresult;
  goto fail;
  fail:
  return JS_EXCEPTION;
}

SWIGRUNTIME JSValue _wrap_SwigObject_toString(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
  /* as this method is included in the prototype, it is called for instances but also for the prototype itself */
  char buffer[128];
  SwigObjectData *swig_object;
  JSValueConst v;
  const char *s;

  if(argc!=0) {
    SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for SwigObject_toString.");
  }

  /* detect if this is the prototype */
  if(JS_GetClassID(this_val) == SWIG_QuickJS_swig_prototype_class_class_definition.class_id) {
    v = JS_GetPropertyStr(ctx, this_val, ".of.");
    s = JS_ToCString(ctx, v);
    snprintf(buffer, 128, "prototype of %s", s);
    JS_FreeCString(ctx, s);
    JS_FreeValue(ctx, v);
    return JS_NewString(ctx, buffer);
  }

  swig_object = (SwigObjectData *)JS_GetOpaque(this_val, JS_GetClassID(this_val));
  if(swig_object->type) {
    snprintf(buffer, 128, "%s at %p", SWIG_TypeName(swig_object->type), swig_object->ptr);
  } else {
    snprintf(buffer, 128, "pointer %p", swig_object->ptr);
  }
  return JS_NewString(ctx, buffer);

  goto fail;
  fail:
  return JS_EXCEPTION;
}

SWIGRUNTIME
void SwigObject_delete(JSRuntime *rt, JSValue this_val)
{
  /* Note: no context, impossible to call IsSwigObject to make an additional check */
  SwigObjectData* swig_object = (SwigObjectData*)JS_GetOpaque(this_val, JS_GetClassID(this_val));
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_PTRTRACE)
  printf("SwigObject_delete: %p (%p,%s)\n", swig_object, swig_object->ptr, (swig_object->type)?SWIG_TypePrettyName(swig_object->type):"pointer");
#endif
  memset(swig_object, 0, sizeof(SwigObjectData));
  js_free_rt(rt, swig_object);
  JS_SetOpaque(this_val, NULL);
}

static JSValue SwigObject_new(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
    SWIG_exception(SWIG_ERROR, "Class swig_object  can not be instantiated directly");
    fail:
    return JS_EXCEPTION;
}

SWIGRUNTIME const SWIG_QuickJS_FunctionListEntry swig_object_prototype_functions[] = {
  SWIG_JS_CFUNC_DEF("disown",0,_wrap_SwigObject_disown),
  SWIG_JS_CFUNC_DEF("equals",1,_wrap_SwigObject_equals),
  SWIG_JS_CFUNC_DEF("toString",0, _wrap_SwigObject_toString)
};

static SWIG_QuickJS_ClassDefinition SWIG_QuickJS_swig_object_class_definition = \
  {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
    SWIG_PROTOTYPE_CLASS_MAGIC,
#endif
    "swig_object", SwigObject_delete, SwigObject_new, JS_UNDEFINED, JS_INVALID_CLASS_ID, JS_UNDEFINED,
    swig_object_prototype_functions, countof(swig_object_prototype_functions), NULL, 0, NULL, 0, NULL, 0};

/* ----------------------------------------------------------------------------
 *  Runtime support of object pointers
 *
 * ---------------------------------------------------------------------------*/

 /*
  * SWIG_QuickJS_IsSwigObject: determine if a JSValue is a wrapper object.
  * This function test is the class of the prototype matches the swig object prototype class.
  * Return true if the JSValue is a wrapped object, false if it is not and -1 in case of exception.
  */
SWIGRUNTIME int SWIG_QuickJS_IsSwigObject(JSContext *ctx, JSValueConst this_val)
{
  JSValue proto;
  int result = false;
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
  SwigObjectData *swig_object;
#endif

  if (JS_IsObject(this_val)) {
    proto = JS_GetPrototype(ctx, this_val);
    if(JS_IsException(proto)) return -1;
    result = (JS_GetClassID(proto) == SWIG_QuickJS_swig_prototype_class_class_definition.class_id);
    JS_FreeValue(ctx, proto);
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
    /* check the SwigObject */
    swig_object = (SwigObjectData*)JS_GetOpaque(this_val, JS_GetClassID(this_val));
    if (swig_object && swig_object->magic != SWIG_OBJECT_MAGIC) {
      printf("SWIG_QuickJS_IsSwigObject: Error - classID is swig prototype but magic don't match (%p)\n", swig_object);
      result = false;
    }
#endif
  }
  return result;
}


SWIGRUNTIME int SWIG_QuickJS_ConvertPtr(JSContext *ctx, JSValueConst val, void** ptr, swig_type_info *type, int flags) {
  SwigObjectData *swig_object;

  /* special case: JavaScript null => C NULL pointer */
  if(JS_IsNull(val)) {
    if(ptr) *ptr=0;
    return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }

  if(SWIG_QuickJS_IsSwigObject(ctx, val) <= 0) {
    return SWIG_ERROR;
  }

  swig_object = (SwigObjectData*)JS_GetOpaque(val, JS_GetClassID(val));

#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_PTRTRACE)
   printf("SWIG_QuickJS_ConvertPtr: %p (%p,%s) (flags=%x) (own=%d)\n", swig_object, swig_object->ptr,
      type?SWIG_TypePrettyName(type):"unknown type", flags, swig_object->own);
#endif
  assert(ptr);
  *ptr = NULL;
  if (!type || swig_object->type == type) {
    *ptr = swig_object->ptr;
  } else {
    swig_cast_info *tc = SWIG_TypeCheckStruct(swig_object->type, type);
    if (tc) {
      int newmemory = 0;
      *ptr = SWIG_TypeCast(tc, swig_object->ptr, &newmemory);
      assert(!newmemory); /* newmemory handling not yet implemented */
    } else if (swig_object->type->clientdata && type->clientdata) {
      /* this part implements the cross-module inheritance, see
       * explanation around baseRegistry in javascripthelpers.swg */
      int found = 0;
      SWIG_QuickJS_ClassDefinition *clsDef = (SWIG_QuickJS_ClassDefinition*)(swig_object->type->clientdata);
      SWIG_QuickJS_ClassDefinition *pClsDef = (SWIG_QuickJS_ClassDefinition*)(type->clientdata);
      JSValueConst base_map = SWIG_QuickJS_baseRegistryClassLookup(ctx, clsDef->class_name);
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
      if(clsDef->magic != SWIG_PROTOTYPE_CLASS_MAGIC) {
        printf("SWIG_QuickJS_ConvertPtr: Warning: not a class %s\n", swig_object->type->str);
        return SWIG_ERROR;
      }
      if(pClsDef->magic != SWIG_PROTOTYPE_CLASS_MAGIC) {
        printf("SWIG_QuickJS_ConvertPtr: Warning: not a class %s\n", type->str);
        return SWIG_ERROR;
      }
#endif       
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_BASES)
      printf("SWIG_QuickJS_ConvertPtr: check source %s to target %s\n", clsDef->class_name, pClsDef->class_name);
#endif      
      if(JS_IsObject(base_map)) {
        JSAtom atom = JS_NewAtom(ctx, pClsDef->class_name);
        if(atom != JS_ATOM_NULL) {
          found = JS_HasProperty(ctx, base_map, atom);
          JS_FreeAtom(ctx, atom);
        }
      }
      JS_FreeValue(ctx, base_map);
      if(!found) {
        return SWIG_ERROR;
      }
      *ptr = swig_object->ptr;
    } else {
      return SWIG_ERROR;
    }
  }

  if (((flags & SWIG_POINTER_RELEASE) == SWIG_POINTER_RELEASE) && !swig_object->own) {
    return SWIG_ERROR_RELEASE_NOT_OWNED;
  } else {
    if (flags & SWIG_POINTER_DISOWN) {
      swig_object->own = false;
    }
    if (flags & SWIG_POINTER_CLEAR) {
      swig_object->ptr = 0;
    }
  }
  return SWIG_OK;
}

SWIGRUNTIME JSValue SWIG_QuickJS_NewPointerObj(JSContext *ctx, void *ptr, swig_type_info *type, int flags) {
  JSValue result;
  SwigObjectData *swig_object;

  if (ptr == NULL) {
    return JS_NULL;
  }

  /* initialize the object data */
  swig_object = (SwigObjectData*)js_malloc_rt(JS_GetRuntime(ctx), sizeof(SwigObjectData));
  if (swig_object == NULL) {
    return JS_ThrowOutOfMemory(ctx);
  }
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_PTRTRACE)
  printf("SWIG_NewPointerObj: %p (%p,%s) (own=%x)\n", swig_object, ptr, type?SWIG_TypePrettyName(type):"pointer",
    flags & SWIG_POINTER_OWN);
#endif
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
  swig_object->magic = SWIG_OBJECT_MAGIC;
#endif
  swig_object->ptr = ptr;
  swig_object->own = (flags & SWIG_POINTER_OWN) ? 1 : 0;
  swig_object->type = type;

  /* initialize the JS instance */
  SWIG_QuickJS_ClassDefinition *def = NULL;
  if(type && type->clientdata) {
    def = (SWIG_QuickJS_ClassDefinition*)type->clientdata;
    result = JS_NewObjectClass(ctx, def->class_id);
  } else {
    result = JS_NewObjectClass(ctx, SWIG_QuickJS_swig_object_class_definition.class_id);
  }
  if (JS_IsException(result)) {
    js_free(ctx, swig_object);
    return JS_EXCEPTION;
  }
  JS_SetOpaque(result, swig_object);

  return result;
}


#define SWIG_ConvertPtr(obj, ptr, type, flags)    SWIG_QuickJS_ConvertPtr(ctx, obj, ptr, type, flags)
#define SWIG_NewPointerObj(ptr, type, flags)      SWIG_QuickJS_NewPointerObj(ctx, ptr, type, flags)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_QuickJS_ConvertPtr(ctx, obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_QuickJS_NewPointerObj(ctx, ptr, type, 0)


/* ----------------------------------------------------------------------------
 *  A class for packed data
 *
 * ---------------------------------------------------------------------------*/
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
#define SWIG_PACKED_DATA_MAGIC 0xcafecafe
#endif

typedef struct {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
  unsigned magic;
#endif
  swig_type_info *type;
  void *data;
  size_t size;
} SwigPackedData;

SWIGRUNTIMEINLINE int SWIG_QuickJS_IsPackedData(JSValue val);

/*  SwigPackedData wrappers  */
SWIGRUNTIME JSValue _wrap_SwigPackedData_toString(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
  char buffer[128];

  if(SWIG_QuickJS_IsPackedData(this_val) <= 0) {
    return JS_ThrowTypeError(ctx, "SWIGPackedData_toString");
  }
  SwigPackedData *packed_data = (SwigPackedData *)JS_GetOpaque(this_val, JS_GetClassID(this_val));
  snprintf(buffer, 128, "%s at %p[%lu]", SWIG_TypeName(packed_data->type), packed_data->data, packed_data->size);
  return JS_NewString(ctx, buffer);
}


SWIGRUNTIME SWIG_QuickJS_FunctionListEntry swig_packed_data_prototype_functions[] = {
  SWIG_JS_CFUNC_DEF("toString",0, _wrap_SwigPackedData_toString)
};

SWIGRUNTIME JSValue SwigPackedData_new(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
    SWIG_exception(SWIG_ERROR, "Class swig_packet_data can not be instantiated directly");
fail:
    return JS_EXCEPTION;
}

SWIGRUNTIME void SwigPackedData_delete(JSRuntime *rt, JSValue this_val)
{
  SwigPackedData* packed_data;

  if(SWIG_QuickJS_IsPackedData(this_val) <= 0) {
    printf("SwigPackedData_delete: Error - not a packed data\n");
    return;
  }

  packed_data = (SwigPackedData*)JS_GetOpaque(this_val, JS_GetClassID(this_val));
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_PTRTRACE)
  printf("SwigPackedData_delete: %p\n", packed_data);
#endif
  js_free_rt(rt, packed_data->data);
  js_free_rt(rt, packed_data);
  JS_SetOpaque(this_val, NULL);
}

static SWIG_QuickJS_ClassDefinition SWIG_QuickJS_packed_data_class_definition = \
  {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
    SWIG_PROTOTYPE_CLASS_MAGIC,
#endif
    "swig_packed_data", SwigPackedData_delete, SwigPackedData_new, JS_UNDEFINED, JS_INVALID_CLASS_ID, JS_UNDEFINED,
    swig_packed_data_prototype_functions, countof(swig_packed_data_prototype_functions), NULL, 0, NULL, 0, NULL, 0};

SWIGRUNTIMEINLINE int SWIG_QuickJS_IsPackedData(JSValue val)
{
  /* XXX add typecheck with magic */
  return JS_IsObject(val) && (JS_GetClassID(val) == SWIG_QuickJS_packed_data_class_definition.class_id);
}

SWIGRUNTIME swig_type_info* Swig_QuickJS_UnpackData(JSContext *ctx, JSValue val, void *ptr, size_t size)
{
  if (SWIG_QuickJS_IsPackedData(val)) {
    SwigPackedData *sobj = (SwigPackedData *) JS_GetOpaque(val, SWIG_QuickJS_packed_data_class_definition.class_id);;
    if (sobj->size != size) return 0;
    if (!ptr) return 0;
    memcpy(ptr, sobj->data, size);
    return sobj->type;
  } else {
    return NULL;
  }
}

SWIGRUNTIME
int SWIG_QuickJS_ConvertPacked(JSContext *ctx, JSValue val, void *ptr, size_t sz, swig_type_info *ty)
{
  swig_type_info *to = Swig_QuickJS_UnpackData(ctx, val, ptr, sz);
  if (!to) return SWIG_ERROR;
  if (ty) {
    if (to != ty) {
      /* check type cast */
      swig_cast_info *tc = SWIG_TypeCheck(to->name,ty);
      if (!tc) return SWIG_ERROR;
    }
  }
  return SWIG_OK;
}

SWIGRUNTIME
JSValue SWIG_QuickJS_NewPackedObj(JSContext *ctx, void *data, size_t size, swig_type_info *type)
{
  JSValue result = JS_NewObjectClass(ctx, SWIG_QuickJS_packed_data_class_definition.class_id);
  if (JS_IsException(result)) {
      return JS_EXCEPTION;
  }
  SwigPackedData* packed_data = (SwigPackedData*)js_malloc_rt(JS_GetRuntime(ctx), sizeof(SwigPackedData));
  if (packed_data == NULL) {
    JS_FreeValue(ctx, result);
    return JS_ThrowOutOfMemory(ctx);
  }
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_PTRTRACE)
  printf("SWIG_NewPackedObj: %p\n", packed_data);
#endif

  packed_data->data = js_malloc_rt(JS_GetRuntime(ctx), size);
  if (packed_data->data == NULL) {
    js_free_rt(JS_GetRuntime(ctx), packed_data);
    JS_FreeValue(ctx, result);
    return JS_ThrowOutOfMemory(ctx);
  }
  memcpy(packed_data->data, data, size);
  packed_data->size = size;
  packed_data->type = type;
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_TYPECHECK)
  packed_data->magic = SWIG_PACKED_DATA_MAGIC;
#endif
  JS_SetOpaque(result, packed_data);

  return result;
}

/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_QuickJS_ConvertPacked(ctx, obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_QuickJS_NewPackedObj(ctx, ptr, sz, type)

/* ----------------------------------------------------------------------------
 *  SWIG QuickJS internal classes definitions
 *
 * ---------------------------------------------------------------------------*/
static JSClassID SWIG_QuickJS_module_info_class_id = 0;
#if 0
static JSClassID SWIG_QuickJS_namespace_info_class_id = 0;
#endif

/* ---------------------------------------------------------------------------
 * Runtime Helper functions: SWIG_getptr
 *
 * ---------------------------------------------------------------------------*/

/* A function to get the pointer of a wrapped object */
int SWIG_QuickJS_getptr(JSContext *ctx, void **ptr, JSValueConst this_val)
{
  if(ptr == NULL) {
    return -1;
  }
  if (SWIG_QuickJS_IsSwigObject(ctx, this_val) <= 0) {
    return -1;
  }
  SwigObjectData *swig_object = (SwigObjectData *)JS_GetOpaque(this_val, JS_GetClassID(this_val));
  *ptr = swig_object->ptr;
  return 0;
}

/* ---------------------------------------------------------------------------
 * Runtime Helper functions: SWIG_typename
 *
 * ---------------------------------------------------------------------------*/

/* A function to get the typestring of a wrapped object (but works with all types)
 */
const char *SWIG_QuickJS_typename(JSContext *ctx, JSValueConst this_val)
{
  SwigObjectData *swig_object;
  const char *str = NULL;
  int tag;

  if (SWIG_QuickJS_IsSwigObject(ctx, this_val)) {
    swig_object = (SwigObjectData *)JS_GetOpaque(this_val, JS_GetClassID(this_val));
    if(swig_object->type) {
      str = SWIG_TypePrettyName(swig_object->type);
    } else {
      str = "pointer";
    }
  }

  if(str) return str;

  tag = JS_VALUE_GET_NORM_TAG(this_val);

  switch(tag) {
  case JS_TAG_INT:
      str = "int";
      break;
  case JS_TAG_BOOL:
      str = "bool";
      break;
  case JS_TAG_NULL:
      str = "null";
      break;
  case JS_TAG_EXCEPTION:
      str = "exception";
      break;
  case JS_TAG_UNINITIALIZED:
      str = "uninitialized";
      break;
  case JS_TAG_UNDEFINED:
      str = "undefined";
      break;
  case JS_TAG_FLOAT64:
      str = "float64";
      break;
  case JS_TAG_SHORT_BIG_INT:
      str = "short big int";
      break;
  case JS_TAG_BIG_INT:
      str = "big int";
      break;
  case JS_TAG_STRING:
  case JS_TAG_STRING_ROPE:
      str = "string";
      break;
  case JS_TAG_FUNCTION_BYTECODE:
      str = "bytecode";
      break;
  case JS_TAG_OBJECT:
      if(JS_IsError(ctx, this_val)) str = "error";
      else if (JS_IsArray(ctx, this_val)) str = "array";
      else if (JS_IsFunction(ctx, this_val)) str = "function";
      else str = "object";
      break;
  case JS_TAG_SYMBOL:
      str = "symbol";
      break;
  case JS_TAG_MODULE:
      str = "module";
      break;
  default:
      str = "unknown type";
      break;
  }
  return str;
}

/* Callable function to get the userdata's type */
SWIGRUNTIME JSValue _wrap_SWIG_QuickJS_typename(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst argv[])
{
  const char *result;
  JSValue jsresult;

  if (argc != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for SWIG_type.");


  result = SWIG_QuickJS_typename(ctx, argv[0]);
  jsresult = JS_NewString(ctx, result);

  return jsresult;

  goto fail;
  fail:
  return JS_EXCEPTION;
}


#define SWIG_ArrayLength(a) SWIG_QuickJS_ArrayLength(ctx, a)

SWIGRUNTIME
unsigned int SWIG_QuickJS_ArrayLength(JSContext *ctx, JSValue arr)
{
  JSValue idx_val;
  int idx;
  assert(JS_IsArray(ctx, arr));

  idx_val = JS_GetPropertyStr(ctx, arr, "length");
  if(JS_ToInt32(ctx, &idx, idx_val)) return 0;
  assert(idx>=0);
  JS_FreeValue(ctx, idx_val);
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_ARRAYLEN)
  printf("SWIG_ArrayLength: %d\n", idx);
#endif
  return idx;
}

/* Multiple output: processed as array: create a Javascript array if needed
 * and append the output obj to it. */
JSValue SWIG_QuickJS_AppendOutput(JSContext *ctx, JSValue result, JSValue obj)
{
  /* if the current result is
   * - undefined: create an array and put the object at position 0
   * - an array: the multiple ouput has started in this array, append the object to it
   * - any other value (primitive type, object): create an array and put the current result
   * at position 0 and put the object at position 1.
   */
  JSValue r;
  int idx;
  if(JS_IsException(obj)) {
    r = obj;
    if(JS_IsArray(ctx, result)) {
      JS_FreeValue(ctx, result);
    }
  } else {
    if(JS_IsUndefined(result)) {
      r = JS_NewArray(ctx);
      idx = 0;
    } else if (JS_IsArray(ctx, result)) {
      r = result;
      idx = SWIG_QuickJS_ArrayLength(ctx, r);
    } else {
      r = JS_NewArray(ctx);
      JS_SetPropertyUint32(ctx,r,0,result);
      idx = 1;
    }

    JS_SetPropertyUint32(ctx,r,(uint32_t)idx,obj);
  }

  return r;
}



#ifdef __cplusplus
}
#endif
