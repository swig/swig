%insert(init) %{
SWIGRUNTIME void
SWIG_QJS_SetModule(JSContext* context, swig_module_info *swig_module) {
    JSObject* globalObject;
    JSString* moduleName;
    JSClassDef classDef;
    JSClass* classRef;
    JSObject* object;

    if(context == 0){
        return;
    }

    globalObject = JS_GetGlobalObject(context);
    moduleName = JS_NewString("swig_module_info_data");

    JSClassID classID;
    JS_NewClassID(&classID);
    JS_NewClass(JS_GetRuntime(context), classID, classDef);
    object = JS_NewObjectClass(context, classID);

    // classDef  = js_std_class_def;
    // classRef = JSClassCreate(&classDef);

    // object = JSObjectMake(context, classRef, NULL);
    JS_VALUE_GET_PTR(object) = (void*)swig_module

    JS_SetPropertyStr(context, globalObject, moduleName, object);

    // JSClassRelease(classRef);
    // JSStringRelease(moduleName);
}
SWIGRUNTIME swig_module_info *
SWIG_QJS_GetModule(JSContext* context) {
    JSObject* globalObject;
    JSString* moduleName;
    JSValue* value;
    JSObject* object;

    if(context == 0){
        return 0;
    }

    globalObject = JS_GetGlobalObject(context);
    moduleName = JS_NewString("swig_module_info_data");

    if(JS_GetPropertyStr(context, globalObject, moduleName) == false) {
        // JSStringRelease(moduleName);
        return 0;
    }

    value = JS_GetPropertyValue(context, globalObject, moduleName, NULL);
    // object = JSValueToObject(context, value, NULL);
    // JSStringRelease(moduleName);

    return (swig_module_info*)value;
}

#define SWIG_GetModule(clientdata)                SWIG_QJS_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer)       SWIG_QJS_SetModule(clientdata, pointer)
#define SWIG_INIT_CLIENT_DATA_TYPE                JSContext*
%}

%insert(init) "swiginit.swg"

%fragment ("js_initializer_define", "templates") %{
#define SWIGQJS_INIT $jsname_initialize
%}

// Open the initializer function
%insert(init)
%{

#ifdef __cplusplus
extern "C" {
#endif

bool SWIGQJS_INIT (JSContext* context, JSObject* *exports) {
    SWIG_InitializeModule(context);
%}

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                   module name
 *   - $jscreatenamespaces:       part with code for creating namespace objects
 *   - $jscreateclasses:          part with code for creating classes
 *   - $jsregisternamespaces:     part with code for registration of namespaces
 * ----------------------------------------------------------------------------- */
%fragment ("js_initializer", "templates") %{
    /* Initialize the base swig type object */
    _SwigObject_objectDefinition.staticFunctions = _SwigObject_functions;
    _SwigObject_objectDefinition.staticValues = _SwigObject_values;
    // _SwigObject_classRef = JSClassCreate(&_SwigObject_objectDefinition);

    JSClassID classID;
    JS_NewClassID(&classID);
    JS_NewClass(JS_GetRuntime(context), classID, &_SwigObject_objectDefinition);
    _SwigObject_classRef = JS_NewObjectClass(context, classID));

    /* Initialize the PackedData class */
    _SwigPackedData_objectDefinition.staticFunctions = _SwigPackedData_functions;
    _SwigPackedData_objectDefinition.staticValues = _SwigPackedData_values;
    _SwigPackedData_objectDefinition.finalize = _wrap_SwigPackedData_delete;
    // _SwigPackedData_classRef = JSClassCreate(&_SwigPackedData_objectDefinition);
    JSClassID classID;
    JS_NewClassID(&classID);
    JS_NewClass(JS_GetRuntime(context), classID, &_SwigPackedData_objectDefinition);
    _SwigPackedData_classRef = JS_NewObjectClass(context, classID));


    /* Create objects for namespaces */
    $jscreatenamespaces

    /* Register classes */
    $jsregisterclasses

    /* Register namespaces */
    $jsregisternamespaces

    *exports = exports_object;

    return true;
}
#ifdef __cplusplus
}
#endif
%}
