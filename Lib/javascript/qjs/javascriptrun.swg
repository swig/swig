/* ----------------------------------------------------------------------------
 *  Errors and exceptions
 *
 * ---------------------------------------------------------------------------*/

#define SWIG_Error(code, msg)     SWIG_QJS_exception(context, exception, code, msg)
#define SWIG_exception(code, msg) do { SWIG_QJS_exception(context, exception, code, msg); SWIG_fail; } while (0)
#define SWIG_fail                 goto fail

SWIGRUNTIME void SWIG_Javascript_Raise(JSContext* context, JSValue** exception, const char* type) {
  JSString* message = JS_NewString(context, type);
  JSValue* error_arguments[1]; 
  JSObject* exception_object;
  JSValue* exception_value;
  exception_value = JS_ToString(context, message);
  /* Converting the result to an object will let JavascriptCore add 
     "sourceURL" (file) and "line" (number) and "message" to the exception,
     instead of just returning a raw string. This is extremely important for debugging your errors.
     Using JSObjectMakeError is better than JSValueToObject because the latter only populates
     "sourceURL" and "line", but not "message" or any others I don't know about.
   */
  // error_arguments[0] = exception_value;
  exception_object = JS_EXCEPTION;

  /* Return the exception_object */
  *exception = exception_object;

  JS_FreeValue(message);
}

SWIGRUNTIME void SWIG_QJS_exception(JSContext* context, JSValue* *exception, int code, const char* msg) {
  SWIG_Javascript_Raise(context, exception, msg);
}

/* ----------------------------------------------------------------------------
 *  The parent class of all Proxies
 *
 * ---------------------------------------------------------------------------*/

typedef struct {
  bool swigCMemOwn;
  void *swigCObject;
  swig_type_info *info;
} SwigPrivData;

SWIGRUNTIME JSValue* _wrap_SwigObject_disown(JSContext* context, JSObject* function, JSObject* thisObject, size_t argc, const JSValue* argv[], JSvalue* exception)
{
  JSValue* jsresult;

  JSObject* obj = JS_ToObject(context, thisObject);
  SwigPrivData *cdata = (SwigPrivData *) JS_VALUE_GET_PTR(obj);

  cdata->swigCMemOwn = false;

  jsresult = JS_UNDEFINED;
  return jsresult;
}

SWIGRUNTIME JSValue _wrap_SwigObject_getCPtr(JSContext* context, JSObject* function, JSObject* thisObject, size_t argc, const JSValue* argv[], JSValue** exception)
{
  JSvalue* jsresult;
  long result;

  JSObject* obj = JS_ToObject(context, thisObject);
  SwigPrivData *cdata = (SwigPrivData*) JS_VALUE_GET_PTR(obj);

  result = (long) cdata->swigCObject;
  jsresult = JS_NewInt64(context, result);

  return jsresult;
}

SWIGRUNTIME JSValue* _wrap_SwigObject_equals(JSContext* context, JSObject* function, JSObject* thisObject, size_t argc, const JSValue* argv[], JSValue** exception)
{
  JSValue* jsresult;
  bool result;

  JSObject* obj = JS_ToObject(context, thisObject);
  SwigPrivData *cdata = (SwigPrivData*) JS_VALUE_GET_PTR(obj);

  JSObject obj2 = JS_ToObject(context, argv[0]);
  SwigPrivData *cdata2 = (SwigPrivData*) JS_VALUE_GET_PTR(obj2);

  result = (cdata->swigCObject == cdata2->swigCObject);
  jsresult = JS_ToBool(context, result);

  return jsresult;
}
// TODO: Starting here, finish converting over to QuickJS
SWIGRUNTIME JSValue _SwigObject_values[] = {
  {
    0, 0, 0, 0
  }
};

SWIGRUNTIME JS_Object _SwigObject_functions[] = {
  {
    "disown",_wrap_SwigObject_disown
  },
  {
    "equals",_wrap_SwigObject_equals
  },
  {
    "getCPtr",_wrap_SwigObject_getCPtr
  },
  {
    0, 0, 0
  }
};

SWIGRUNTIME JSClassDef _SwigObject_objectDefinition;

SWIGRUNTIME JSClass* _SwigObject_classRef;


SWIGRUNTIME int SWIG_QJS_ConvertInstancePtr(JSContext* context, JSObject* objRef, void** ptr, swig_type_info *info, int flags) {
  SwigPrivData *cdata;

  cdata = (SwigPrivData *) JS_VALUE_GET_PTR(objRef);
  if (cdata == NULL) {
    return SWIG_ERROR;
  }
  assert(ptr);
  *ptr = NULL;
  if (!info || cdata->info == info) {
    *ptr = cdata->swigCObject;
  } else {
    swig_cast_info *tc = SWIG_TypeCheckStruct(cdata->info, info);
    if (tc) {
      int newmemory = 0;
      *ptr = SWIG_TypeCast(tc, cdata->swigCObject, &newmemory);
      assert(!newmemory); /* newmemory handling not yet implemented */
    } else {
      return SWIG_ERROR;
    }
  }

  if (flags & SWIG_POINTER_DISOWN) {
    cdata->swigCMemOwn = false;
  }

  return SWIG_OK;
}

SWIGRUNTIME int SWIG_QJS_ConvertPtr(JSContext* context, JSValue* valRef, void** ptr, swig_type_info *info, int flags) {
  JSObject* objRef;

  /* special case: JavaScript null => C NULL pointer */
  if(JS_IsNull(valRef)) {
    *ptr=0;
    return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }

  if(!JS_IsObject(valRef)) {
    return SWIG_TypeError;
  }

  objRef = JS_ToObject(context, valRef);
  if(objRef == NULL) {
    return SWIG_ERROR;
  }

  return SWIG_QJS_ConvertInstancePtr(context, objRef, ptr, info, flags);
}

SWIGRUNTIME JSObject* SWIG_QJS_NewPointerObj(JSContext* context, void *ptr, swig_type_info *info, int flags) {
  JSClass* classRef;
  JSObject* result;
  SwigPrivData *cdata;

  if (ptr == NULL) {
    // HACK: it is not possible to use JSValueToObject (causing seg-fault)
    // This static cast turned out to be a workaround
    // In future, we should change the interface of this method
    // to return JSValueRef instead of JSObjectRef.
    return JS_NULL;
  }

  if(info->clientdata == NULL) {
    classRef = _SwigObject_classRef;
  } else {
    classRef = (JSClass*) info->clientdata;
  }

    // result = JSObjectMake(context, classRef, NULL);
  JSClassID classID;
  JS_NewClassID(&classID);

  JS_NewClass(JS_GetRuntime(context), classID, classRef);
  result = JS_NewObjectClass(context, classID));


  cdata = (SwigPrivData*) malloc(sizeof(SwigPrivData));
  cdata->swigCObject = ptr;
  cdata->swigCMemOwn = (flags & SWIG_POINTER_OWN) ? 1 : 0;
  cdata->info = info;

  // JSObjectSetPrivate(result, cdata);
  JS_VALUE_GET_PTR(result) = cdata;
    // JS_SetPropertyStr(context, result, ,
    //                   JS_NewCFunction(ctx, js_print, "print", 1));  

  return result;
}

#define SWIG_ConvertPtr(obj, ptr, info, flags)    SWIG_QJS_ConvertPtr(context, obj, ptr, info, flags)
#define SWIG_NewPointerObj(ptr, info, flags)      SWIG_QJS_NewPointerObj(context, ptr, info, flags)

#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_QJS_ConvertInstancePtr(context, obj, pptr, type, flags)
#define SWIG_NewInstanceObj(thisvalue, type, flags)     SWIG_QJS_NewPointerObj(context, thisvalue, type, flags)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_QJS_ConvertPtr(context, obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_QJS_NewPointerObj(context, ptr, type, 0)

/* ----------------------------------------------------------------------------
 *  A class for packed data
 *
 * ---------------------------------------------------------------------------*/

typedef struct {
  void *data;
  size_t size;
  swig_type_info *type;
} SwigPackedData;

SWIGRUNTIME JSValue _SwigPackedData_values[] = {
  {
    0, 0, 0, 0
  }
};
SWIGRUNTIME JSValue _SwigPackedData_functions[] = {
  {
    0, 0, 0
  }
};
SWIGRUNTIME JSClassDef _SwigPackedData_objectDefinition;
SWIGRUNTIME JSClass* _SwigPackedData_classRef;

SWIGRUNTIMEINLINE
int SwigQJSPacked_Check(JSContext* context, JSValue* valRef) {
  // JSValue proto = JS_GetPrototype(context, *valRef);
  // JSClassId classId = 
  return JS_OrdinaryIsInstanceOf(context, valRef, _SwigPackedData_classRef);
  // return JSValueIsObjectOfClass(context, valRef, _SwigPackedData_classRef);
}

SWIGRUNTIME
swig_type_info* SwigQJSPacked_UnpackData(JSContext* context, JSValue* valRef, void *ptr, size_t size) {
  if (SwigQJSPacked_Check(context, valRef)) {
    // JSObjectRef objRef = JSValueToObject(context, valRef, NULL);
    SwigPackedData *sobj = (SwigPackedData *) valRef;
    if (sobj->size != size) return 0;
    memcpy(ptr, sobj->data, size);
    return sobj->type;
  } else {
    return 0;
  }
}

SWIGRUNTIME
int SWIG_QJS_ConvertPacked(JSContext* context, JSValue* valRef, void *ptr, size_t sz, swig_type_info *ty) {
  swig_type_info *to = SwigQJSPacked_UnpackData(context, valRef, ptr, sz);
  if (!to) return SWIG_ERROR;
  if (ty) {
    if (to != ty) {
      /* check type cast? */
      swig_cast_info *tc = SWIG_TypeCheck(to->name,ty);
      if (!tc) return SWIG_ERROR;
    }
  }
  return SWIG_OK;
}

SWIGRUNTIME
JSValueRef SWIG_QJS_NewPackedObj(JSContext* context, void *data, size_t size, swig_type_info *type) {

  JSClass* classRef = _SwigObject_classRef;
  JSObject* result = JS_NewObjectClass(context, classRef->class_id);

  SwigPackedData* cdata = (SwigPackedData*) malloc(sizeof(SwigPackedData));
  cdata->data = data;
  cdata->size = size;
  cdata->type = type;

  JS_SetObjectData(context, result, cdata);

  return result;
}

/*  SwigPackedData wrappers  */
SWIGRUNTIME
void _wrap_SwigPackedData_delete(JSObject* obj)
{
  SwigPackedData* cdata = (SwigPackedData*) JS_GetObjectData(context, *obj);
  if (cdata) {
    free(cdata->data);
  }
}

/* for C++ member pointers, ie, member methods */

#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_JSC_ConvertPacked(context, obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_JSC_NewPackedObj(context, ptr, sz, type)


/* ---------------------------------------------------------------------------
 * Support for IN/OUTPUT typemaps (see Lib/typemaps/inoutlist.swg)
 *
 * ---------------------------------------------------------------------------*/
SWIGRUNTIME
unsigned int SWIGQJS_ArrayLength(JSContext* context, JSObject* arr) {
  static JSString LENGTH = 0;
  JSValue* exception = NULL;
  JSValue* js_length;
  double length;

  if (LENGTH == 0) {
    LENGTH = JS_NewString("length");
  }

  js_length = JS_GetPropertyStr(context, arr, LENGTH);
  if (exception == 0 && JS_IsNumber(context, js_length)) {
    length = JS_ToNumeric(context, js_length);
    return (unsigned int) length;
  } else {
    return 0;
  }
}

SWIGRUNTIME
bool SWIGQJS_ValueIsArray(JSContext* context, JSValue* value) {
  if (JS_IsObject(context, value)) {
    static JSString* ArrayString = NULL;
    static JSString* isArrayString = NULL;
    JSObject* array = NULL;
    JSObject* isArray = NULL;
    JSValue* retval = NULL;

    if (!ArrayString)
      ArrayString = JS_NewString("Array");
    if (!isArrayString)
      isArrayString = JS_NewString("isArray");

    array = (JSObject*)JS_GetPropertyStr(context, JS_GetGlobalObject(context), ArrayString);
    isArray = (JSObjectRef)JS_GetPropertyStr(context, array, isArrayString);
    retval = JS_Call(context, isArray, NULL, 1, &value);

    if (!JS_IsNull(retval))
      return JS_ToBool(context, retval);
  }
  return false;
}

SWIGRUNTIME
JSValue* SWIGQJS_AppendOutput(JSContext* context, JSValue* value, JSValue* obj) {
  JSObject* arr;
  unsigned int length;

  if (JS_IsUndefined(context, value)) {
    arr = JS_NewObjectClass(context, JS_CLASS_ARRAY);
    // arr = JSObjectMakeArray(context, 0, 0, 0);
  } else if (!SWIGQJS_ValueIsArray(context, value)) {
    // arr = JSObjectMakeArray(context, 1, &value, 0);
    arr = JS_NewObjectClass(context, JS_CLASS_ARRAY);
    JS_SetPropertyValue(context, arr, 0, value, JS_PROP_C_W_E);
  } else {
    arr = JS_ToObject(context, value);
  }

  length = SWIGQJS_ArrayLength(context, arr);
  JS_SetPropertyValue(context, arr, 0, obj, JS_PROP_C_W_E);
  return arr;
}
