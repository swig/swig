/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * Javascript support code
 * ----------------------------------------------------------------------------- */

%define %swig_v8_define_version(version)
%begin %{
#ifndef SWIG_V8_VERSION
#define SWIG_V8_VERSION version
#endif
%}
%enddef

#ifdef SWIG_V8_VERSION
%swig_v8_define_version(SWIG_V8_VERSION)
#else
// HACK: defining a default version
%swig_v8_define_version(SWIG_V8_VERSION)
#endif

#ifdef BUILDING_NODE_EXTENSION
%insert("runtime") %{
#include <node.h>
%}
#endif

%insert(runtime) %{
#include <v8.h>

#include <errno.h>
#include <limits.h>
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */

%insert(runtime) %{
#define SWIG_Error(code, msg)     SWIGV8_ErrorHandler.error(code, msg)
#define SWIG_exception(code, msg) SWIGV8_ErrorHandler.error(code, msg)
#define SWIG_fail                 goto fail
#define SWIGV8_OVERLOAD false

void SWIG_V8_Raise(const char* msg) {
  v8::ThrowException(v8::Exception::Error(v8::String::New(msg)));
}

/*
  Note: There are two contexts for handling errors.
  A static V8ErrorHandler is used in not overloaded methods.
  For overloaded methods the throwing type checking mechanism is used
  during dispatching. As V8 exceptions can not be resetted properly
  the trick is to use a dynamic ErrorHandler with same local name as the global
  one.

  - See defintion of SWIG_Error above.
  - See code templates 'JS_function_dispatcher', 'JS_functionwrapper_overload',
    and 'JS_function_dispatch_case' in javascriptcode.swg

*/
class V8ErrorHandler {
public:
  virtual ~V8ErrorHandler() {}
  virtual void error(int code, const char* msg) {
    SWIG_V8_Raise(msg);
  }
};
// this is used in usually
V8ErrorHandler SWIGV8_ErrorHandler;

// instances of this are used in overloaded functions
class OverloadErrorHandler: public V8ErrorHandler {
public:
  virtual void error(int code, const char* msg) {
    err = v8::Exception::Error(v8::String::New(msg));
    if(code != SWIG_TypeError) {
      v8::ThrowException(err);
    }
  }
  v8::Handle<v8::Value> err;
};
%}

%insert(runtime) %{

// Note: to trigger the v8 gc more often one can tell v8 about the memory consumption
// TODO: we could add a v8 specific parameter to control this value
#define SWIGV8_AVG_OBJ_SIZE 1000

class SWIGV8_Proxy {
public:
  SWIGV8_Proxy(): swigCMemOwn(false), swigCObject(0), info(0) {
    v8::V8::AdjustAmountOfExternalAllocatedMemory(SWIGV8_AVG_OBJ_SIZE);
  };

  ~SWIGV8_Proxy() {
#if (SWIG_V8_VERSION < 0x031900)
    handle.ClearWeak();
    handle.Dispose();
#else
    handle.ClearWeak(v8::Isolate::GetCurrent());
    handle.Dispose(v8::Isolate::GetCurrent());
#endif

    handle.Clear();
    v8::V8::AdjustAmountOfExternalAllocatedMemory(-SWIGV8_AVG_OBJ_SIZE);
  }

  bool swigCMemOwn;
  void *swigCObject;
  swig_type_info *info;
  v8::Persistent<v8::Object> handle;
};

class SWIGV8_ClientData {
public:
  v8::Persistent<v8::FunctionTemplate> class_templ;

#if (SWIG_V8_VERSION < 0x031900)
  void (*dtor) (v8::Persistent< v8::Value> object, void *parameter);
#else
  void (*dtor) (v8::Isolate *isolate, v8::Persistent< v8::Object > *object, SWIGV8_Proxy *proxy);
#endif
};

v8::Persistent<v8::FunctionTemplate> SWIGV8_SWIGTYPE_Proxy_class_templ;

int SWIG_V8_ConvertInstancePtr(v8::Handle<v8::Object> objRef, void** ptr, swig_type_info *info, int flags) {
  v8::HandleScope scope;

  if(objRef->InternalFieldCount() < 1) return SWIG_ERROR;

#if (SWIG_V8_VERSION < 0x031900)
  v8::Handle<v8::Value> cdataRef = objRef->GetInternalField(0);
  SWIGV8_Proxy *cdata = static_cast<SWIGV8_Proxy *>(v8::External::Unwrap(cdataRef));
#else
  SWIGV8_Proxy *cdata = static_cast<SWIGV8_Proxy *>(objRef->GetAlignedPointerFromInternalField(0));
#endif

  if(cdata == NULL) {
    return SWIG_ERROR;
  }
  if(cdata->info != info) {
    swig_cast_info *tc = SWIG_TypeCheckStruct(cdata->info, info);
    if (!tc && cdata->info->name) {
      tc = SWIG_TypeCheck(cdata->info->name, info);
    }
    bool type_valid = tc != 0;
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

#if (SWIG_V8_VERSION < 0x031900)
void SWIGV8_Proxy_DefaultDtor(v8::Persistent< v8::Value > object, void *parameter)
#else
void SWIGV8_Proxy_DefaultDtor(v8::Isolate *, v8::Persistent< v8::Object > *object, SWIGV8_Proxy *proxy)
#endif
{
#if (SWIG_V8_VERSION < 0x031900)
  SWIGV8_Proxy *proxy = static_cast<SWIGV8_Proxy *>(parameter);
#endif

  delete proxy;
}

int SWIG_V8_GetInstancePtr(v8::Handle<v8::Value> valRef, void** ptr) {
  if(!valRef->IsObject()) {
    return SWIG_TypeError;
  }
  v8::Handle<v8::Object> objRef = valRef->ToObject();

  if(objRef->InternalFieldCount() < 1) return SWIG_ERROR;

#if (SWIG_V8_VERSION < 0x031900)
  v8::Handle<v8::Value> cdataRef = objRef->GetInternalField(0);
  SWIGV8_Proxy *cdata = static_cast<SWIGV8_Proxy *>(v8::External::Unwrap(cdataRef));
#else
  SWIGV8_Proxy *cdata = static_cast<SWIGV8_Proxy *>(objRef->GetAlignedPointerFromInternalField(0));
#endif

  if(cdata == NULL) {
    return SWIG_ERROR;
  }

  *ptr = cdata->swigCObject;

  return SWIG_OK;
}

void SWIGV8_SetPrivateData(v8::Handle<v8::Object> obj, void* ptr, swig_type_info *info, int flags) {
  SWIGV8_Proxy* cdata = new SWIGV8_Proxy();
  cdata->swigCObject = ptr;
  cdata->swigCMemOwn = (flags & SWIG_POINTER_OWN) ? 1 : 0;
  cdata->info = info;

#if (SWIG_V8_VERSION < 0x031900)
  obj->SetPointerInInternalField(0, cdata);
  cdata->handle = v8::Persistent<v8::Object>::New(obj);
#else
  obj->SetAlignedPointerInInternalField(0, cdata);
  cdata->handle.Reset(v8::Isolate::GetCurrent(), obj);
#endif

#if (SWIG_V8_VERSION < 0x031900)
  // clientdata must be set for owned data as we need to register the dtor
  if(cdata->swigCMemOwn && (SWIGV8_ClientData*)info->clientdata) {
    cdata->handle.MakeWeak(cdata, ((SWIGV8_ClientData*)info->clientdata)->dtor);
  } else {
    cdata->handle.MakeWeak(cdata, SWIGV8_Proxy_DefaultDtor);
  }
  cdata->handle.MarkIndependent();
#else
  if(cdata->swigCMemOwn && (SWIGV8_ClientData*)info->clientdata) {
    cdata->handle.MakeWeak(v8::Isolate::GetCurrent(), cdata, ((SWIGV8_ClientData*)info->clientdata)->dtor);
  } else {
    cdata->handle.MakeWeak(v8::Isolate::GetCurrent(), cdata, SWIGV8_Proxy_DefaultDtor);
  }
  cdata->handle.MarkIndependent(v8::Isolate::GetCurrent());
#endif
}

int SWIG_V8_ConvertPtr(v8::Handle<v8::Value> valRef, void** ptr, swig_type_info *info, int flags) {
  v8::HandleScope scope;

  if(!valRef->IsObject()) {
    return SWIG_TypeError;
  }
  v8::Handle<v8::Object> objRef = valRef->ToObject();
  return SWIG_V8_ConvertInstancePtr(objRef, ptr, info, flags);
}

v8::Handle<v8::Object> SWIG_V8_NewPointerObj(void *ptr, swig_type_info *info, int flags) {
  v8::HandleScope scope;
  v8::Handle<v8::FunctionTemplate> class_templ;


#if (SWIG_V8_VERSION < 0x031900)
  if(info->clientdata != 0) {
    class_templ = ((SWIGV8_ClientData*) info->clientdata)->class_templ;
  } else {
    class_templ = SWIGV8_SWIGTYPE_Proxy_class_templ;
  }
#else
  v8::Isolate *iso = v8::Isolate::GetCurrent();

  if(info->clientdata != 0) {
    class_templ = v8::Handle<v8::FunctionTemplate>::New(iso, ((SWIGV8_ClientData*) info->clientdata)->class_templ);
  } else {
    class_templ = v8::Handle<v8::FunctionTemplate>::New(iso, SWIGV8_SWIGTYPE_Proxy_class_templ);
  }
#endif

  v8::Handle<v8::Object> result = class_templ->InstanceTemplate()->NewInstance();
  SWIGV8_SetPrivateData(result, ptr, info, flags);

  return scope.Close(result);
}

#define SWIG_ConvertPtr(obj, ptr, info, flags)    SWIG_V8_ConvertPtr(obj, ptr, info, flags)
#define SWIG_NewPointerObj(ptr, info, flags)      SWIG_V8_NewPointerObj(ptr, info, flags)

#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_V8_ConvertInstancePtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(thisvalue, type, flags)     SWIG_V8_NewPointerObj(thisvalue, type, flags)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_V8_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_V8_NewPointerObj(ptr, type, 0)

#define SWIG_GetInstancePtr(obj, ptr)    SWIG_V8_GetInstancePtr(obj, ptr)

v8::Handle<v8::Value> _wrap_equals(const v8::Arguments &args) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> jsresult;
  void *arg1 = (void *) 0 ;
  void *arg2 = (void *) 0 ;
  bool result;
  int res1;
  int res2;

  if(args.Length() != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for _wrap_equals.");

  res1 = SWIG_GetInstancePtr(args.Holder(), &arg1);
  if (!SWIG_IsOK(res1)) {
    SWIG_exception_fail(SWIG_ERROR, "Could not get pointer from 'this' object for _wrap_equals.");
  }
  res2 = SWIG_GetInstancePtr(args[0], &arg2);
  if (!SWIG_IsOK(res2)) {
    SWIG_exception_fail(SWIG_ArgError(res2), "in method '" "equals" "', argument " "1"" of type '" "void *""'");
  }

  result = (bool)(arg1 == arg2);
  jsresult =  v8::Boolean::New(result);

  return scope.Close(jsresult);
  goto fail;
fail:
  return scope.Close(v8::Undefined());
}

v8::Handle<v8::Value> _wrap_getCPtr(const v8::Arguments &args) {
  v8::HandleScope scope;
  v8::Handle<v8::Value> jsresult;
  void *arg1 = (void *) 0 ;
  long result;
  int res1;

  res1 = SWIG_GetInstancePtr(args.Holder(), &arg1);
  if (!SWIG_IsOK(res1)) {
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "getCPtr" "', argument " "1"" of type '" "void *""'");
  }

  result = (long)arg1;
  jsresult = v8::Number::New(result);

  return scope.Close(jsresult);
  goto fail;
fail:
  return scope.Close(v8::Undefined());
}
%}
