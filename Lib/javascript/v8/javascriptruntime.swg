/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * Javascript support code
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <v8.h>
#include <errno.h>
#include <limits.h>
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */   

%insert(runtime) %{
#define SWIG_Error(code, msg)     SWIG_V8_exception(code, msg)
#define SWIG_exception(code, msg) SWIG_V8_exception(code, msg)
#define SWIG_fail                 goto fail
%}

%insert(runtime) %{
typedef struct {
  bool swigCMemOwn;
  void *swigCObject;
  swig_type_info *info;
} SWIG_PRV_DATA; 
%}

%insert(runtime) %{

void SWIG_V8_Raise(const char* type) {
  // TODO: throw v8 exception
}

void SWIG_V8_exception(int code, const char* msg) {
  SWIG_V8_Raise(msg);
}

%}


%insert(runtime) %{
int SWIG_V8_ConvertInstancePtr(v8::Handle<v8::Object> objRef, void** ptr, swig_type_info *info, int flags) {
  
  if(objRef->InternalFieldCount() < 1) {
    return SWIG_ERROR;
  }
  v8::Handle<v8::Value> cdataRef = objRef->GetInternalField(0);
  
  SWIG_PRV_DATA *cdata = (SWIG_PRV_DATA *) v8::External::Unwrap(cdataRef);
  if(cdata == NULL) {
    return SWIG_ERROR;
  }
  
  if(cdata->info != info) {
    bool type_valid = false;
    swig_cast_info *t = info->cast; 
    while(t != NULL) {
      if(t->type == cdata->info) {
        type_valid = true;
        break;
      }
      t = t->next;
    }
    if(!type_valid) {
      return SWIG_TypeError;
    }
  }
  
  *ptr = cdata->swigCObject;
  
  if(flags & SWIG_POINTER_DISOWN) {
    cdata->swigCMemOwn = false;
  }
  
  return SWIG_OK;
}

void SWIG_V8_SetPrivateData(v8::Handle<v8::Object> obj, void* ptr, swig_type_info *info, int flags) {
  SWIG_PRV_DATA* cdata = (SWIG_PRV_DATA*) new SWIG_PRV_DATA;
  cdata->swigCObject = ptr;  
  cdata->swigCMemOwn = (flags & SWIG_POINTER_OWN) ? 1 : 0;
  cdata->info = info;

  obj->SetInternalField(0, v8::External::New(cdata));
}

int SWIG_V8_ConvertPtr(v8::Handle<v8::Value> valRef, void** ptr, swig_type_info *info, int flags) {
  if(!valRef->IsObject()) {
    return SWIG_TypeError;
  }
  
  v8::Handle<v8::Object> objRef = valRef->ToObject();
    
  return SWIG_V8_ConvertInstancePtr(objRef, ptr, info, flags);
}

v8::Handle<v8::Object> SWIG_V8_NewPointerObj(void *ptr, swig_type_info *info, int flags) {
  v8::HandleScope scope;
  
  v8::Local<v8::FunctionTemplate> class_templ;
  v8::Handle<v8::ObjectTemplate> inst_templ;
  if(info->clientdata == NULL) {
    class_templ = v8::FunctionTemplate::New();
    class_templ->SetClassName(v8::String::NewSymbol(info->name));
    inst_templ = class_templ->InstanceTemplate();
    inst_templ->SetInternalFieldCount(1);
  } else {
    class_templ = *((v8::Local<v8::FunctionTemplate>*) info->clientdata);
    inst_templ = class_templ->InstanceTemplate();
  }
  
  v8::Local<v8::Object> result = inst_templ->NewInstance();

  SWIG_V8_SetPrivateData(result, ptr, info, flags);
  
  return scope.Close(result);
}

#define SWIG_ConvertPtr(obj, ptr, info, flags)    SWIG_V8_ConvertPtr(obj, ptr, info, flags)
#define SWIG_NewPointerObj(ptr, info, flags)      SWIG_V8_NewPointerObj(ptr, info, flags)

#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_V8_ConvertInstancePtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(thisvalue, type, flags)     SWIG_V8_NewPointerObj(thisvalue, type, flags)

%}
