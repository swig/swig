
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

#define SWIG_GetModule(clientdata)                SWIG_QuickJS_GetModule((JSContext*)clientdata)
#define SWIG_SetModule(clientdata, pointer)       SWIG_QuickJS_SetModule((JSContext*)clientdata, pointer)
#define SWIG_INIT_CLIENT_DATA_TYPE                void*
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
#ifndef DEFAULT_NAMESPACE
#define DEFAULT_NAMESPACE $jsname_namespace
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

SWIGINTERN int SWIG_module_local_initialize(JSContext *ctx, JSModuleDef *m)
{
  int r = 0;

%} /* end of %insert(init) */

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the top part of thr module initializer function
 *   - $jsname:                   module name
 *   - $jsglobalnamespace         declaration of the module namespace
 *   - $jscreatenamespaces:       part with code for creating namespace object
 *   - $jscreateclasses:          part with code for creating classes
 *   - $jsregisternamespaces:     part with code for registration of namespaces*
 * ----------------------------------------------------------------------------- */
%fragment ("js_initializer", "templates") %{

  return r;
} /* end of SWIG_module_local_initialize */

SWIGINTERN int SWIG_module_initialize(JSContext *ctx, JSModuleDef *m)
{
  int r;
  JSValue globalObject;
  JSValue swigObjectRegistry;
  JSAtom atom;
  JSValue v;
  char buf[128];

  SWIG_InitializeModule(ctx);

  r = SWIG_QuickJS_createRegistries(ctx);
  if(r < 0) {
    return SWIG_ERROR;
  }

  /* Get the swig-object-registry (stores common swig items, like prototypes, in order
   * not to duplicate them for every module loaded. */
  swigObjectRegistry = SWIG_QuickJS_getSwigObjectRegistry(ctx);
  if(JS_IsException(swigObjectRegistry)) {return SWIG_ERROR;}

  $jsglobalnamespace

  /* Register the swig prototype class, which is the class of the prototype of wrapper objects
   * but, as it cannot have itself as prototype, register it manually (not with SWIG_QuickJS_register_class())
   * The class_id of the prototype class is stored in the swigObjectRegistry, in order to create
   * the class_id and register the class only once */
  SWIG_QuickJS_ClassDefinition *d = &SWIG_QuickJS_swig_prototype_class_class_definition;
  atom = JS_NewAtom(ctx, d->class_name);
  if(JS_HasProperty(ctx, swigObjectRegistry, atom)) {
    v = JS_GetProperty(ctx, swigObjectRegistry, atom);
    if(!JS_IsNumber(v)) {return SWIG_ERROR;}
    if(JS_ToUint32(ctx, &(d->class_id), v)) {return SWIG_ERROR;}
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_MULTIMODULE)
    printf("SWIG_module_initialize: info - %s found in swigObjectRegistry (%u).\n", d->class_name, d->class_id);
#endif
    JS_FreeValue(ctx, v);
  } else {
    assert(JS_NewClassID(&(d->class_id)));
    JSClassDef class_def = { d->class_name, d->dtor, NULL, NULL, NULL };
    r = JS_NewClass(JS_GetRuntime(ctx), d->class_id, &class_def);
    if (r == -1) { return SWIG_ERROR; }
    r = JS_SetProperty(ctx, swigObjectRegistry, atom, JS_NewUint32(ctx, d->class_id));
    if (r == -1) { return SWIG_ERROR; }
  }
  JS_FreeAtom(ctx, atom);

  /* Register the swig object class, which is the class of the instances of wrapped objects
   * The class_id of the swig_object class is stored in the swigObjectRegistry (as swig_object), in
   * order to create the class_id and register the class only once ;
   * the class prototype is also stored in the swigObjectRegistry (as swig_object_prototype)
   * in order to setup properly the class definition.
   * */
  d = &SWIG_QuickJS_swig_object_class_definition;
  atom = JS_NewAtom(ctx, d->class_name);
  if(JS_HasProperty(ctx, swigObjectRegistry, atom)) {
    v = JS_GetProperty(ctx, swigObjectRegistry, atom);
    if(!JS_IsNumber(v)) {return SWIG_ERROR;}
    if(JS_ToUint32(ctx, &(d->class_id), v)) {return SWIG_ERROR;}
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_MULTIMODULE)
    printf("SWIG_module_initialize: info - %s found in swigObjectRegistry (%u).\n", d->class_name, d->class_id);
#endif
    JS_FreeValue(ctx, v);
  } else {
    r = SWIG_QuickJS_registerClass(ctx, DEFAULT_NAMESPACE,
                          SWIG_QuickJS_swig_object_class_definition.class_name,
                          &SWIG_QuickJS_swig_object_class_definition,
                          false);
    if(r <= 0) {
      return SWIG_ERROR;
    }
    JS_SetProperty(ctx, swigObjectRegistry, atom, JS_NewUint32(ctx, d->class_id));
  }
  JS_FreeAtom(ctx, atom);

  snprintf(buf, 128, "%s_prototype", d->class_name);
  atom = JS_NewAtom(ctx, buf);
  if(JS_HasProperty(ctx, swigObjectRegistry, atom)) {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_MULTIMODULE)
    printf("SWIG_module_initialize: info - %s found in swigObjectRegistry.\n", buf);
#endif
    v = JS_GetProperty(ctx, swigObjectRegistry, atom);
    if(!JS_IsObject(v)) {return SWIG_ERROR;}
    d->prototype = v;
    JS_FreeValue(ctx, v);
  } else {
    r = JS_SetProperty(ctx, swigObjectRegistry, atom, JS_DupValue(ctx, d->prototype));
    if (r == -1) { return SWIG_ERROR; }
  }
  JS_FreeAtom(ctx, atom);

  /* Register the packed data class (same as above, checking if class_id and prototypes are
   * alreaady defined and stored in the swigObjectRegistry). */
  d = &SWIG_QuickJS_packed_data_class_definition;
  atom = JS_NewAtom(ctx, d->class_name);
  if(JS_HasProperty(ctx, swigObjectRegistry, atom)) {
    v = JS_GetProperty(ctx, swigObjectRegistry, atom);
    if(!JS_IsNumber(v)) {return SWIG_ERROR;}
    if(JS_ToUint32(ctx, &(d->class_id), v)) {return SWIG_ERROR;}
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_MULTIMODULE)
    printf("SWIG_module_initialize: info - %s found in swigObjectRegistry (%u).\n", d->class_name, d->class_id);
#endif
    JS_FreeValue(ctx, v);
  } else {
    r = SWIG_QuickJS_registerClass(ctx, DEFAULT_NAMESPACE,
                          SWIG_QuickJS_packed_data_class_definition.class_name,
                          &SWIG_QuickJS_packed_data_class_definition,
                          false);
    if(r <= 0) {
      return SWIG_ERROR;
    }
    r = JS_SetProperty(ctx, swigObjectRegistry, atom, JS_NewUint32(ctx, d->class_id));
    if (r == -1) { return SWIG_ERROR; }
  }
  JS_FreeAtom(ctx, atom);

  snprintf(buf, 128, "%s_prototype", d->class_name);
  atom = JS_NewAtom(ctx, buf);
  if(JS_HasProperty(ctx, swigObjectRegistry, atom)) {
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_MULTIMODULE)
    printf("SWIG_module_initialize: info - %s found in swigObjectRegistry.\n", buf);
#endif
    v = JS_GetProperty(ctx, swigObjectRegistry, atom);
    if(!JS_IsObject(v)) {return SWIG_ERROR;}
    d->prototype = v;
    JS_FreeValue(ctx, v);
  } else {
    r = JS_SetProperty(ctx, swigObjectRegistry, atom, JS_DupValue(ctx, d->prototype));
    if (r == -1) { return SWIG_ERROR; }
  }
  JS_FreeAtom(ctx, atom);

  /* XXX Create the JS Class to store/retrieve the module information (SWIG_Get/Set_Module)
   * note: this object has no properties at all, not registered as an actual class
   * (for now)  */
  atom = JS_NewAtom(ctx, "swig_module_info");
  if(JS_HasProperty(ctx, swigObjectRegistry, atom)) {
    v = JS_GetProperty(ctx, swigObjectRegistry, atom);
    if(!JS_IsNumber(v)) {return SWIG_ERROR;}
    if(JS_ToUint32(ctx, &SWIG_QuickJS_module_info_class_id, v)) {return SWIG_ERROR;}
#if defined(SWIGRUN_DEBUG) && (SWIGRUN_DEBUG & SWIGRUN_DEBUG_MULTIMODULE)
    printf("SWIG_module_initialize: info - swig_module_info found in swigObjectRegistry (%u).\n", SWIG_QuickJS_module_info_class_id);
#endif
    JS_FreeValue(ctx, v);
  } else {
    assert(JS_NewClassID(&SWIG_QuickJS_module_info_class_id));
    JSClassDef module_info_class_def = { "swig_module_info", NULL, NULL, NULL, NULL };
    r = JS_NewClass(JS_GetRuntime(ctx), SWIG_QuickJS_module_info_class_id, &module_info_class_def);
    if (r == -1) { return SWIG_ERROR; }
    r = JS_SetProperty(ctx, swigObjectRegistry, atom, JS_NewUint32(ctx, SWIG_QuickJS_module_info_class_id));
    if (r == -1) { return SWIG_ERROR; }
  }
  JS_FreeAtom(ctx, atom);

  JS_FreeValue(ctx, swigObjectRegistry);

#if 0
  /* Create the JS Class to store/retreive namespace info  => XXX not useful ? Namespace
   * have no data, just variables and functions as properties, using a generic object is enough ? */
  assert(JS_NewClassID(&SWIG_QuickJS_namespace_info_class_id));
  JSClassDef namespace_info_class_def = { "swig_namespace_info", NULL, NULL, NULL, NULL };
  JS_NewClass(JS_GetRuntime(ctx), SWIG_QuickJS_namespace_info_class_id, &namespace_info_class_def);
#endif

  /* Register helper functions at global level */
  globalObject = JS_GetGlobalObject(ctx);
  /* SWIG_type: return the type of a variable (as a string) */
  r = JS_SetPropertyStr(ctx, globalObject, "SWIG_type",
      JS_NewCFunction(ctx, _wrap_SWIG_QuickJS_typename, "SWIG_type", 1));
  if (r == -1) { return SWIG_ERROR; }
  JS_FreeValue(ctx, globalObject);

  r = SWIG_module_local_initialize(ctx, m);
  if (r == -1) { return SWIG_ERROR; }

  /* Create objects for namespaces */
  $jscreatenamespaces

  /* Register classes */
  $jsregisterclasses

  /* Register namespaces */
  $jsregisternamespaces

  if(JS_SetModuleExport(ctx, m, "$jsname", DEFAULT_NAMESPACE)) {
    return SWIG_ERROR;
  }
  return SWIG_OK;
}
#ifdef __cplusplus
}
#endif
%}
