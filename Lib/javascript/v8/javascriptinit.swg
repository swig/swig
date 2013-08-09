%insert(init) %{

#include <assert.h>

SWIGRUNTIME void
SWIG_V8_SetModule(void *, swig_module_info *swig_module) {
  v8::Local<v8::Object> global_obj = v8::Context::GetCurrent()->Global();
  v8::Local<v8::External> mod = v8::External::New(swig_module);
  assert(!mod.IsEmpty());
  global_obj->SetHiddenValue(v8::String::New("swig_module_info_data"), mod);
}

SWIGRUNTIME swig_module_info *
SWIG_V8_GetModule(void *) {
  v8::Local<v8::Object> global_obj = v8::Context::GetCurrent()->Global();
  v8::Local<v8::Value> moduleinfo = global_obj->GetHiddenValue(v8::String::New("swig_module_info_data"));

  if (moduleinfo.IsEmpty())
  {
    // It's not yet loaded
    return 0;
  }

  v8::Local<v8::External> moduleinfo_extern = v8::Local<v8::External>::Cast(moduleinfo);
 
  if (moduleinfo_extern.IsEmpty())
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

%}

%insert(init) %{/************  BEGIN: "swiginit.swg" *******************/ %}
%insert(init) "swiginit.swg"
%insert(init) %{/************  END:   "swiginit.swg" *******************/ %}
