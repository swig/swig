%insert(header) %{
#include <assert.h>
%}

%insert(header) %{
#define SWIG_GetModule(clientdata)                SWIG_NAPI_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer)       SWIG_NAPI_SetModule(clientdata, pointer)
#define SWIG_INIT_CLIENT_DATA_TYPE                Napi::Env

SWIGRUNTIME void
SWIG_NAPI_SetModule(Napi::Env env, swig_module_info *swig_module);
SWIGRUNTIME swig_module_info *
SWIG_NAPI_GetModule(Napi::Env env);

%}

%insert(init) %{

EnvInstanceData::EnvInstanceData(Napi::Env env, swig_module_info *swig_module) :
  env(env), SWIG_NAPI_ObjectWrapCtor(SWIG_NULLPTR), SWIG_NAPI_PackedObjectWrapCtor(SWIG_NULLPTR),
  ctor(SWIG_NULLPTR), swig_module(swig_module), module_instance_data(SWIG_NULLPTR) {
  ctor = new Napi::FunctionReference*[swig_module->size + 1];
  for (size_t i = 0; i <= swig_module->size; i++) {
    ctor[i] = SWIG_NULLPTR;
  }

#if NAPI_HAS_THREADS
  // Init the mechanism for scheduling jobs on the JS main thread
  js_main_thread.main_thread_id = std::this_thread::get_id();
  js_main_thread.handle = new uv_async_t;
  uv_loop_t *event_loop;
  napi_status r = napi_get_uv_event_loop(env, &event_loop);
  assert(r == napi_ok);
  assert(uv_async_init(event_loop, js_main_thread.handle, SWIG_NAPI_RunMainThreadQueue) == 0);
  // The initial status of the async handle is inactive
#ifndef __EMSCRIPTEN__
  uv_unref(reinterpret_cast<uv_handle_t *>(js_main_thread.handle));
#endif
  js_main_thread.handle->data = static_cast<void*>(this);
#endif
}

EnvInstanceData::~EnvInstanceData() {
  for (size_t i = 0; i <= swig_module->size; i++) {
    if (ctor[i] != SWIG_NULLPTR)
      delete ctor[i];
    ctor[i] = SWIG_NULLPTR;
  }
  delete [] ctor;
  delete SWIG_NAPI_ObjectWrapCtor;
  delete SWIG_NAPI_PackedObjectWrapCtor;
}

SWIGRUNTIME void
SWIG_NAPI_SetModule(Napi::Env env, swig_module_info *swig_module) {
  auto data = new EnvInstanceData(env, swig_module);
  env.SetInstanceData(data);
}

SWIGRUNTIME swig_module_info *
SWIG_NAPI_GetModule(Napi::Env env) {
  auto data = env.GetInstanceData<EnvInstanceData>();
  if (data == SWIG_NULLPTR) return SWIG_NULLPTR;
  return data->swig_module;
}
%}

%insert(init) "swiginit.swg"

// Open the initializer function definition here

%fragment ("js_initializer_define", "templates") %{
#define SWIG_NAPI_INIT $jsname_initialize
%}

%insert(header) %{
Napi::Object Init(Napi::Env env, Napi::Object exports);
%}

%insert(init) %{
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  SWIG_InitializeModule(env);
%}

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                     module name
 *   - $jsnapinspaces:              part with code creating namespace objects
 *   - $jsnapiwrappers:             part with code that registers wrapper functions
 *   - $jsnapiinitinheritance:      part with inherit statements
 *   - $jsnapistaticwrappers:       part with code adding static functions to class objects
 *   - $jsnapiregisterclasses:      part with code that registers class objects in namespaces
 *   - $jsnapiregisternspaces:      part with code that registers namespaces in parent namespaces
 * ----------------------------------------------------------------------------- */
%fragment("js_initializer", "templates")
%{
  /* initialize the base SWIG object class */
  Napi::Function SWIG_NAPI_ObjectWrap_ctor = SWIG_NAPI_ObjectWrap_inst::GetClass(env);
  Napi::FunctionReference *SWIG_NAPI_ObjectWrap_ctor_ref = new Napi::FunctionReference();
  *SWIG_NAPI_ObjectWrap_ctor_ref = Napi::Persistent(SWIG_NAPI_ObjectWrap_ctor);
  env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor = SWIG_NAPI_ObjectWrap_ctor_ref;

  /* initialize the SWIG packed object class */
  Napi::Function SWIG_NAPI_PackedObjectWrap_ctor = SWIG_NAPI_PackedObjectWrap_inst::GetClass(env);
  Napi::FunctionReference *SWIG_NAPI_PackedObjectWrap_ctor_ref = new Napi::FunctionReference();
  *SWIG_NAPI_PackedObjectWrap_ctor_ref = Napi::Persistent(SWIG_NAPI_PackedObjectWrap_ctor);
  env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_PackedObjectWrapCtor = SWIG_NAPI_PackedObjectWrap_ctor_ref;

  /* create objects for namespaces */
  $jsnapinspaces

  /* register classes */
  $jsnapiregisterclasses

  /* initialize the inheritance helpers */
  Napi::Value jsObjectValue, jsSetProtoValue;
  Napi::Object jsObject;
  Napi::Function setProto;
  NAPI_CHECK_RESULT(env.Global().Get("Object"), jsObjectValue);
  NAPI_CHECK_RESULT(jsObjectValue.ToObject(), jsObject);
  NAPI_CHECK_RESULT(jsObject.Get("setPrototypeOf"), jsSetProtoValue);
  setProto = jsSetProtoValue.As<Napi::Function>();

  /* setup inheritance between these two */
  do {
    Napi::Value protoBase, protoSub;
    NAPI_CHECK_RESULT(SWIG_NAPI_PackedObjectWrap_ctor.Get("prototype"), protoSub);
    NAPI_CHECK_RESULT(SWIG_NAPI_ObjectWrap_ctor.Get("prototype"), protoBase);
    NAPI_CHECK_MAYBE(setProto.Call({SWIG_NAPI_PackedObjectWrap_ctor, SWIG_NAPI_ObjectWrap_ctor}));
    NAPI_CHECK_MAYBE(setProto.Call({protoSub, protoBase}));
  } while (0);

  /* setup inheritances */
  $jsnapiinitinheritance

  /* create and register namespace objects */
  $jsnapiregisternspaces

  return exports;
  goto fail;
fail:
  return Napi::Object();
}

NODE_API_MODULE($jsname, Init)
%}
