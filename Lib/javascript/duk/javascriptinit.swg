%insert(init) %{
SWIGRUNTIME void
SWIG_duk_SetModule(duk_context *ctx, swig_module_info *swig_module) {
  duk_push_global_stash(ctx);
  duk_push_pointer(ctx, (void *)swig_module);
  duk_put_prop_string(
    ctx,
    -2,
    "swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME
  );
  duk_pop_n(ctx, 1); /* Tidy the stack. */
}

SWIGRUNTIME swig_module_info *
SWIG_duk_GetModule(duk_context *ctx) {
  swig_module_info *ret = NULL;
  duk_push_global_stash(ctx);
  duk_get_prop_string(
    ctx,
    -1,
    "swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME
  );
  if (duk_is_pointer(ctx,-1))
    ret=(swig_module_info*)duk_get_pointer(ctx,-1);
  duk_pop_n(ctx, 2); /* Tidy the stack. */
  return ret;
}

#define SWIG_GetModule(clientdata)          SWIG_duk_GetModule((duk_context *)clientdata)
#define SWIG_SetModule(clientdata, pointer) SWIG_duk_SetModule((duk_context *)clientdata, pointer)
%}

%insert(init) "swiginit.swg"

%fragment ("js_initializer_define", "templates") %{
#define SWIG_duk_INIT $jsname_initialize
#define dukopen_$jsname SWIG_duk_init
%}

// Open the initializer function
%insert(init)
%{

#ifdef __cplusplus
extern "C" {
#endif

/* FIXME: return type? */
duk_ret_t swig_duk_init(duk_context *ctx) {
  /* SWIG's internal initialisation */
  SWIG_InitializeModule((void*)ctx);
  SWIG_PropagateClientData();  
%}

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                   module name
 *   - $jscreatenamespaces:       part with code for creating namespace objects
 *   - $jscreateclasses:          part with code for creating classes
 *   - $jsregisternamespaces:     part with code for registration of namespaces
 * ----------------------------------------------------------------------------- */
%fragment ("js_initializer", "templates") %{
    // FIXME: Fix by convention in module loader by pushing parent object
    duk_push_global_object(ctx);
    /* Initialize the base swig type object FIXME */
    duk_push_object(ctx);
    duk_put_function_list(ctx, -1, _SwigObject_functions);
    duk_put_prop_string(ctx, -2, "SWIG");
    void *swig_obj_ptr = duk_get_heapptr(ctx, -1);
    /* Now the global object is at the stack top.*/
    duk_idx_t exports_idx = duk_push_object(ctx);
    void *exports_ptr = duk_get_heapptr(ctx, -1);
    swig_duk_install_properties(ctx, exports_idx, exports_properties);
    duk_put_function_list(ctx, exports_idx, exports_functions);
   /*
    * By the time we put the property string here, the stack will be...
    * [parent_obj, namespace_obj] 
    * We want to set the property key $jsname in the parent object.
    */
    duk_put_prop_string(ctx, -2, "$jsname");
    /* Create objects for namespaces */
    $jscreatenamespaces
    /* Register classes */
    $jsregisterclasses

    /* Just return the topmost value on the stack, our module. */
    return 1;
    
    /* Initialize the base swig type object */
    //_SwigObject_objectDefinition.staticFunctions = _SwigObject_functions;
    //_SwigObject_objectDefinition.staticValues = _SwigObject_values;
    //_SwigObject_classRef = JSClassCreate(&_SwigObject_objectDefinition);

    /* Initialize the PackedData class */
    //_SwigPackedData_objectDefinition.staticFunctions = _SwigPackedData_functions;
    //_SwigPackedData_objectDefinition.staticValues = _SwigPackedData_values;
    //_SwigPackedData_objectDefinition.finalize = _wrap_SwigPackedData_delete;
    //_SwigPackedData_classRef = JSClassCreate(&_SwigPackedData_objectDefinition);
}
#ifdef __cplusplus
}
#endif
%}
// 