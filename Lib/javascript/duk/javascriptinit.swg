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
    //duk_push_global_object(ctx);
    duk_idx_t module_idx = duk_push_object(ctx);

    void *swig_obj_ptr = NULL;
    {
        duk_idx_t swig_obj_idx = duk_push_object(ctx);
        swig_obj_ptr = duk_get_heapptr(ctx, swig_obj_idx);
        duk_put_function_list(ctx, -1, _SwigObject_functions);
        duk_put_prop_string(ctx, module_idx, "SWIG");
    }
    /* Now the global object is at the stack top.*/
    void *exports_ptr = NULL;
    {
        duk_idx_t exports_idx = duk_push_object(ctx);
        exports_ptr = duk_get_heapptr(ctx, exports_idx);
        swig_duk_install_properties(ctx, exports_idx, exports_properties);
        duk_put_function_list(ctx, exports_idx, exports_functions);
        duk_put_prop_string(ctx, module_idx, "exports");
    }
   /*
    * By the time we put the property string here, the stack will be...
    * [parent_obj, namespace_obj] 
    * We want to set the property key $jsname in the parent object.
    */
    /* Create objects for namespaces */
    {
        $jscreatenamespaces
        /* Register classes */
        $jsregisterclasses
    }
    duk_dup(ctx, module_idx); // make sure the module is at the top
    /* Just return the topmost value on the stack, our module. */
    return 1;

    fail:
    duk_throw(ctx);
    return 0;

}
#ifdef __cplusplus
}
#endif
%}
// 