%insert(header) %{
#include <assert.h>
%}

%insert(init) %{

SWIGRUNTIME void
SWIG_V8_SetModule(v8::Local<v8::Context> context, swig_module_info *swig_module) {
  v8::Isolate* isolate = SWIGV8_GETISOLATE(context);
  v8::Local<v8::Object> global_obj = context->Global();
  v8::Local<v8::External> mod = SWIGV8_EXTERNAL_NEW(swig_module);
  assert(!mod.IsEmpty());
  v8::Local<v8::Private> privateKey = v8::Private::ForApi(isolate, SWIGV8_STRING_NEW("swig_module_info_data"));
  global_obj->SetPrivate(context, privateKey, mod);
}

SWIGRUNTIME swig_module_info *
SWIG_V8_GetModule(v8::Local<v8::Context> context) {
  v8::Isolate* isolate = SWIGV8_GETISOLATE(context);
  v8::Local<v8::Object> global_obj = context->Global();
  v8::Local<v8::Private> privateKey = v8::Private::ForApi(isolate, SWIGV8_STRING_NEW("swig_module_info_data"));
  v8::Local<v8::Value> moduleinfo;
  if (!global_obj->GetPrivate(context, privateKey).ToLocal(&moduleinfo))
    return 0;

  if (moduleinfo.IsEmpty() || moduleinfo->IsNull() || moduleinfo->IsUndefined())
  {
    // It's not yet loaded
    return 0;
  }

  v8::Local<v8::External> moduleinfo_extern = v8::Local<v8::External>::Cast(moduleinfo);

  if (moduleinfo_extern.IsEmpty() || moduleinfo_extern->IsNull() || moduleinfo_extern->IsUndefined())
  {
    // Something's not right
    return 0;
  }

  void *ptr = moduleinfo_extern->Value();
  assert(ptr);
  swig_module_info *retptr = static_cast<swig_module_info *>(ptr);
  assert(retptr);
  return retptr;
}

#define SWIG_GetModule(clientdata)                SWIG_V8_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer)       SWIG_V8_SetModule(clientdata, pointer)
#define SWIG_INIT_CLIENT_DATA_TYPE                v8::Local<v8::Context>

%}

%insert(init) "swiginit.swg"

// Open the initializer function definition here

%fragment ("js_initializer_define", "templates") %{
#define SWIGV8_INIT $jsname_initialize
#define SWIGV8_JSNAME "$jsname"
%}

%insert(init) %{
#if __cplusplus >= 201103L || (defined(_MSVC_LANG) && _MSVC_LANG >= 201103L)
#include <mutex>
#endif

#if !defined(NODE_MODULE_VERSION) || (NODE_MODULE_VERSION < 12)
// Note: 'extern "C"'' disables name mangling which makes it easier to load the symbol manually
extern "C" void SWIGV8_INIT (SWIGV8_OBJECT exports_obj)
#elif (NODE_MODULE_VERSION < 64)
void SWIGV8_INIT (SWIGV8_OBJECT exports_obj, SWIGV8_VALUE /*module*/, void*)
#else
void SWIGV8_INIT (SWIGV8_OBJECT exports_obj, SWIGV8_VALUE /*module*/, v8::Local<v8::Context> context, void*)
#endif
{
#if !defined(NODE_MODULE_VERSION) || NODE_MODULE_VERSION < 64
  v8::Local<v8::Context> context = SWIGV8_CURRENT_CONTEXT();
#endif
  v8::Isolate* isolate = SWIGV8_GETISOLATE(context);
  SWIGV8_HANDLESCOPE();

#if __cplusplus >= 201103L || (defined(_MSVC_LANG) && _MSVC_LANG >= 201103L)
  static std::mutex guard;
  const std::lock_guard<std::mutex> lock(guard);
#endif

  SWIG_InitializeModule(context);

  // Formally speaking SWIGV8_INIT has
  //
  // - things to do just once, initialize global variables;
  // - things to do in each |isolate|, create Persistent<Template>-s;
  // - things to do in each |context|, instantiate |export_obj|;
  //
  // However, if you examine the generated code below, you'll notice that all
  // the things-to-do are executed always on each invocation. As for globals,
  // the arrangement is such that the assignments are constant and hence can be
  // executed multiple times without side effects. And as for templates, it's
  // reckoned that cases when multiple contexts get created per isolate are
  // rare, and occasional template duplicates are tolerable. Just in case for
  // reference, each Node.js Worker thread is executed in own |isolate|, which
  // is the most common case when SWIGV8_INIT would be called multiple times.

  // Per-context array that holds Persistent<Template>-s
  size_t sz = sizeof(v8::Persistent<v8::FunctionTemplate>)
            * (sizeof(swig_types)/sizeof(swig_types[0]) + 1);
  v8::Local<v8::ArrayBuffer> v8_swig_types_as_data = v8::ArrayBuffer::New(isolate, sz);
  v8::Persistent<v8::FunctionTemplate>* v8_swig_types =
#if SWIG_V8_VERSION >= 0x800
    static_cast<v8::Persistent<v8::FunctionTemplate>*>(v8_swig_types_as_data->GetBackingStore()->Data());
#else
    static_cast<v8::Persistent<v8::FunctionTemplate>*>(v8_swig_types_as_data->GetContents().Data());
#endif

  // Anchor the array, so that it won't be garbage-collected
  v8::Local<v8::Private> priv = v8::Private::ForApi(isolate,
                                                    SWIGV8_SYMBOL_NEW("__swig_types__" SWIGV8_JSNAME));
  exports_obj->SetPrivate(context, priv, v8_swig_types_as_data);
%}


/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                   module name
 *   - $jsv8nspaces:              part with code creating namespace objects
 *   - $jsv8classtemplates:       part with code creating class templates
 *   - $jsv8wrappers:             part with code that registers wrapper functions
 *   - $jsv8inheritance:          part with inherit statements
 *   - $jsv8classinstances:       part with code creating class objects
 *   - $jsv8staticwrappers:       part with code adding static functions to class objects
 *   - $jsv8registerclasses:      part with code that registers class objects in namespaces
 *   - $jsv8registernspaces:      part with code that registers namespaces in parent namespaces
 * ----------------------------------------------------------------------------- */
%fragment("js_initializer", "templates")
%{
  // a class template for creating proxies of undefined types
  SWIGV8_SWIGTYPE_Proxy.SetType(SWIGV8_CreateClassTemplate("SwigProxy", isolate, v8_swig_types_as_data),
                                isolate, v8_swig_types);

  /* create objects for namespaces */
  $jsv8nspaces

  /* create class templates */
  $jsv8classtemplates

  /* register wrapper functions */
  $jsv8wrappers

  /* setup inheritances */
  $jsv8inheritance

  /* class instances */
  $jsv8classinstances

  /* add static class functions and variables */
  $jsv8staticwrappers

  /* register classes */
  $jsv8registerclasses

  /* create and register namespace objects */
  $jsv8registernspaces
}

#if defined(BUILDING_NODE_EXTENSION)
#if (NODE_MODULE_VERSION < 64)
NODE_MODULE($jsname, $jsname_initialize)
#else
#ifndef NODE_GYP_MODULE_NAME
# define NODE_GYP_MODULE_NAME $jsname
#endif
#if defined(__GNUC__) && __GNUC__>=8
// NODE_MODULE_INIT is self-inconsistent in all supported Node.js versions :-(
# pragma GCC diagnostic push
# pragma GCC diagnostic ignored "-Wcast-function-type"
#endif
NODE_MODULE_INIT() { $jsname_initialize(exports, module, context, NULL); }
#if defined(__GNUC__) && __GNUC__>=8
# pragma GCC diagnostic pop
#endif
#endif
#endif
%}
