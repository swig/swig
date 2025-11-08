
%insert(init) %{
    
SWIGRUNTIME void
SWIG_QuickJS_SetModule(JSContext *ctx, swig_module_info *swig_module)
{
    JSValue globalObject;
    JSValue object;
    
    globalObject = JS_GetGlobalObject(ctx);

    object = JS_NewObjectClass(ctx, SWIG_QuickJS_module_info_class_id);
    JS_SetOpaque(object, (void*)swig_module);

    JS_SetPropertyStr(ctx, globalObject, "swig_module_info_data", object);
    JS_FreeValue(ctx, globalObject);
}

SWIGRUNTIME swig_module_info *
SWIG_QuickJS_GetModule(JSContext *ctx)
{
    JSValue globalObject;
    JSValue object;
    swig_module_info *info = NULL;

    globalObject = JS_GetGlobalObject(ctx);

    object = JS_GetPropertyStr(ctx, globalObject, "swig_module_info_data");
    if (JS_IsException(object))
        return 0;
    if (!JS_IsUndefined(object)) {
        info = (swig_module_info*)JS_GetOpaque(object, SWIG_QuickJS_module_info_class_id);
    }
    JS_FreeValue(ctx, object);
    JS_FreeValue(ctx, globalObject);
    return (swig_module_info*)info;
}

#define SWIG_GetModule(clientdata)                SWIG_QuickJS_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer)       SWIG_QuickJS_SetModule(clientdata, pointer)
#define SWIG_INIT_CLIENT_DATA_TYPE                JSContext*
%}

%insert(init) "swiginit.swg"

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer definition
 *   - $jsname:                   module name
 * ----------------------------------------------------------------------------- */
%fragment ("js_initializer_define", "templates") %{
#ifndef SWIG_INIT  
#define SWIG_INIT js_init_module
#endif
%}

// Open the initializer function
%insert(init)
%{
#ifdef __cplusplus
extern "C" {
#endif

SWIGINTERN int SWIG_module_initialize(JSContext *ctx, JSModuleDef *m);

JSModuleDef *SWIG_INIT(JSContext *ctx, const char *module_name) 
{
    char name_buffer[128];
    char *name;
    JSModuleDef *m;
    int i;
    
    /* remove the ".so" or ".dll" extension */
    assert(strlen(module_name)<128);
    strncpy(name_buffer, module_name, 128);
    for(i=strlen(module_name); i>=0; i--) {
        if(name_buffer[i] == '.') {
            name_buffer[i] = '\0';
            break;
        }
    }
    /* remove any path prefix in the module name */
    name = name_buffer;
    for(i=strlen(name_buffer); i>=0; i--) {
        if(name_buffer[i] == '/') {
            name = &(name_buffer[i+1]);
            break;
        }
    }
    
    /* printf("Module name: %s => %s\n", module_name, name); */
    m = JS_NewCModule(ctx, module_name, SWIG_module_initialize);
    if (!m)
        return NULL;
        
    JS_AddModuleExport(ctx, m, name);
        
    return m;
}


SWIGINTERN int SWIG_module_initialize(JSContext *ctx, JSModuleDef *m)
{
  int r;
  JSValue globalObject;

  SWIG_InitializeModule(ctx);

  r = SWIG_QuickJS_createRegistries(ctx);
  if(r < 0) { 
    return SWIG_ERROR; 
  }

  /* Register the swig prototype class, which is the class of the prototype of wrapper objects
   * but, as it cannot have itself as prototype, register it manually (not with JS_register_class()) */
  SWIG_QuickJS_ClassDefinition *d = &SWIG_QuickJS_swig_prototype_class_class_definition;
  assert(JS_NewClassID(&(d->class_id)));
  JSClassDef class_def = { d->class_name, d->dtor, NULL, NULL, NULL };
  JS_NewClass(JS_GetRuntime(ctx), d->class_id, &class_def);

  /* Register the swig object class, which is the class of the instances of wrapped objects */
  r = JS_registerClass(ctx, exports_namespace,
                          SWIG_QuickJS_swig_object_class_definition.class_name,
                          &SWIG_QuickJS_swig_object_class_definition,
                          false);
  if(r <= 0) { 
    return SWIG_ERROR; 
  }

  /* Register the packed data class */
  r = JS_registerClass(ctx, exports_namespace,
                          SWIG_QuickJS_packed_data_class_definition.class_name,
                          &SWIG_QuickJS_packed_data_class_definition,
                          false);
  if(r <= 0) { 
    return SWIG_ERROR; 
  }

  /* XXX Create the JS Class to store/retrieve the module information (SWIG_Get/Set_Module)
   * note: this object has no properties at all, not registered as an actual class
   * (for now)  */
  assert(JS_NewClassID(&SWIG_QuickJS_module_info_class_id));
  JSClassDef module_info_class_def = { "swig_module_info", NULL, NULL, NULL, NULL };
  JS_NewClass(JS_GetRuntime(ctx), SWIG_QuickJS_module_info_class_id, &module_info_class_def);

#if 0
  /* Create the JS Class to store/retreive namespace info  => XXX not useful ? Namespace
   * have no data, just variables and functions as properties ? */
  assert(JS_NewClassID(&SWIG_QuickJS_namespace_info_class_id));
  JSClassDef namespace_info_class_def = { "swig_namespace_info", NULL, NULL, NULL, NULL };
  JS_NewClass(JS_GetRuntime(ctx), SWIG_QuickJS_namespace_info_class_id, &namespace_info_class_def);
#endif

  /* Register helper functions at global level */
  globalObject = JS_GetGlobalObject(ctx);
  /* SWIG_type: return the type of a variable (as a string) */
  JS_SetPropertyStr(ctx, globalObject, "SWIG_type", 
      JS_NewCFunction(ctx, _wrap_SWIG_QuickJS_typename, "SWIG_type", 1));
  JS_FreeValue(ctx, globalObject);

%} /* end of %insert(init) */

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                   module name
 *   - $jscreatenamespaces:       part with code for creating namespace objects
 *   - $jscreateclasses:          part with code for creating classes
 *   - $jsregisternamespaces:     part with code for registration of namespaces
 * ----------------------------------------------------------------------------- */
%fragment ("js_initializer", "templates") %{ 

    /* Create objects for namespaces */
    $jscreatenamespaces

    /* Register classes */
    $jsregisterclasses

    /* Register namespaces */
    $jsregisternamespaces

    if(JS_SetModuleExport(ctx, m, "$jsname", exports_namespace)) {
        return SWIG_ERROR;
    }
    return SWIG_OK;
}
#ifdef __cplusplus
}
#endif
%}
