%insert(wrapper) %{
 
SWIGINTERN bool JS_registerClass(JSContext* context, JSObject* parentObject,
                             const char* className,
                             JSClassDef* definition) {

    JSString js_className = JS_NewString(className);
    JSClassID classID;
    JS_NewClassID(&classID);
    JS_NewClass(JS_GetRuntime(context), classID, js_className);
    JSObject* classObject = JS_NewObjectClass(context, classID));

    JS_SetPropertyValue(context, parentObject, 
                      js_className, classObject,
                      JS_PROP_C_W_E
    )
    
    return true;
}

SWIGINTERN bool JS_registerNamespace(JSContext* context, 
                           JSObject* namespaceObj, JSObject* parentNamespace,
                           const char* name)
{
    JSString js_name = JS_NewString(name);
    JS_SetPropertyValue(context, parentNamespace,
                        js_name, namespaceObj,
                        JS_PROP_C_W_E);
    
    return true;
}

// Note: Functions in QuickJS are just tagged JSValues.
SWIGINTERN bool JS_registerFunction(JSContext* context, JSObject* object, 
                        const char* functionName, JSValue callback)
{
    JSString js_functionName = JS_NewString(functionName);
    JS_SetPropertyValue(context, object, js_functionName,
                        callback, 
                        JS_PROP_C_W_E);
    return true;
}

SWIGINTERN bool JS_veto_set_variable(JSContext* context, JSObject* thisObject, JSString* propertyName, JSValue* value, JSValue** exception)
{
    char buffer[256];
    char msg[512];
    int res;
    
    JSString propertyName = JS_NewString(context, buffer, 256);
    res = sprintf(msg, "Tried to write read-only variable: %s.", buffer);
    
    if(res<0) {
      SWIG_exception(SWIG_ERROR, "Tried to write read-only variable.");
    } else {
      SWIG_exception(SWIG_ERROR, msg);
    }
fail:    
    return false;
}

SWIGINTERN JSvalue* JS_CharPtrToJSValue(JSContext* context, char* cstr) {
  JSValue* val;
  
  // JSString jsstring = JS_NewString(context, (char*) cstr);
  val = JS_NewString(context, cstr);
  // JSStringRelease(jsstring);

  return val;
}
%}
