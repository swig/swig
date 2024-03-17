%insert(header) %{
#include <assert.h>
%}

%insert(init) %{

EnvInstanceData::EnvInstanceData(Napi::Env env, swig_module_info *swig_module) :
env(env), SWIG_NAPI_ObjectWrapCtor(nullptr), ctor(nullptr), swig_module(swig_module) {
  ctor = new Napi::FunctionReference*[swig_module->size + 1];
  for (size_t i = 0; i <= swig_module->size; i++) {
    ctor[i] = nullptr;
  }
}

EnvInstanceData::~EnvInstanceData() {
  for (size_t i = 0; i <= swig_module->size; i++) {
    if (ctor[i] != nullptr)
      delete ctor[i];
    ctor[i] = nullptr;
  }
  delete [] ctor;
  delete SWIG_NAPI_ObjectWrapCtor;
}

SWIGRUNTIME void
SWIG_NAPI_SetModule(Napi::Env env, swig_module_info *swig_module) {
  auto data = new EnvInstanceData(env, swig_module);
  env.SetInstanceData(data);
}

SWIGRUNTIME swig_module_info *
SWIG_NAPI_GetModule(Napi::Env env) {
  auto data = env.GetInstanceData<EnvInstanceData>();
  if (data == nullptr) return nullptr;
  return data->swig_module;
}

#define SWIG_GetModule(clientdata)                SWIG_NAPI_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer)       SWIG_NAPI_SetModule(clientdata, pointer)
#define SWIG_INIT_CLIENT_DATA_TYPE                Napi::Env

%}

%insert(init) "swiginit.swg"

// Open the initializer function definition here

%fragment ("js_initializer_define", "templates") %{
#define SWIG_NAPI_INIT $jsname_initialize
%}

%insert(init) %{
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  SWIG_InitializeModule(env);
%}

/* -----------------------------------------------------------------------------
 * js_init_inheritance:  template for enabling the inheritance
 * ----------------------------------------------------------------------------- */
%fragment("js_init_inheritance", "templates")
%{
  Napi::Value jsObjectValue, jsSetProtoValue;
  Napi::Object jsObject;
  Napi::Function setProto;
  NAPI_CHECK_RESULT(env.Global().Get("Object"), jsObjectValue);
  NAPI_CHECK_RESULT(jsObjectValue.ToObject(), jsObject);
  NAPI_CHECK_RESULT(jsObject.Get("setPrototypeOf"), jsSetProtoValue);
  setProto = jsSetProtoValue.As<Napi::Function>();
%}

/* -----------------------------------------------------------------------------
 * js_initializer:  template for the module initializer function
 *   - $jsname:                     module name
 *   - $jsnapipreinheritance:       the previous template
 *   - $jsnapinspaces:              part with code creating namespace objects
 *   - $jsnapiwrappers:             part with code that registers wrapper functions
 *   - $jsnapiinitinheritance:      part with inherit statements
 *   - $jsnapistaticwrappers:       part with code adding static functions to class objects
 *   - $jsnapiregisterclasses:      part with code that registers class objects in namespaces
 *   - $jsnapiregisternspaces:      part with code that registers namespaces in parent namespaces
 * ----------------------------------------------------------------------------- */
%fragment("js_initializer", "templates")
%{
  Napi::Function SWIG_NAPI_ObjectWrap_ctor = SWIG_NAPI_ObjectWrap_inst::GetClass(env);
  Napi::FunctionReference *SWIG_NAPI_ObjectWrap_ctor_ref = new Napi::FunctionReference();
  *SWIG_NAPI_ObjectWrap_ctor_ref = Napi::Persistent(SWIG_NAPI_ObjectWrap_ctor);
  env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor = SWIG_NAPI_ObjectWrap_ctor_ref;

  /* create objects for namespaces */
  $jsnapinspaces

  /* register classes */
  $jsnapiregisterclasses

  /* enable inheritance */
  $jsnapipreinheritance

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
