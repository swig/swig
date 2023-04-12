/* ---------------------------------------------------------------------------
 * Error handling
 *
 * ---------------------------------------------------------------------------*/


SWIGINTERN void SWIG_NAPI_Raise(const char *msg) {
  //SWIGNapi_THROW_EXCEPTION(Napi::Exception::Error(SWIGNAPI_STRING_NEW(msg)));
}

SWIGINTERN void SWIG_NAPI_Raise(Napi::Value obj, const char *msg) {
  //SWIGNapi_THROW_EXCEPTION(Napi::Exception::Error(SWIGNAPI_TO_STRING(obj)));
}

typedef Napi::FunctionReference* SWIGNAPI_ClientData;

template <class T>
class SwigNapiObjectWrap_templ : public Napi::ObjectWrap<T> {
  public:
    void *self;
    bool owned;
    SwigNapiObjectWrap_templ(const Napi::CallbackInfo& info) :
        Napi::ObjectWrap<T>(info),
        self(nullptr),
        owned(true) 
        {}
    virtual ~SwigNapiObjectWrap_templ() {};
};

class SwigNapiObjectWrap_inst : public SwigNapiObjectWrap_templ<SwigNapiObjectWrap_inst> {
  using SwigNapiObjectWrap_templ::SwigNapiObjectWrap_templ;
  virtual ~SwigNapiObjectWrap_inst();
};

SWIGRUNTIME int SWIG_Napi_ConvertInstancePtr(Napi::Object objRef, void **ptr, swig_type_info *info, int flags) {
  if(!objRef.IsObject()) return SWIG_ERROR;

  if (!info) {
    return SWIG_ERROR;
  }
  Napi::FunctionReference *ctor = reinterpret_cast<SWIGNAPI_ClientData>(info->clientdata);
  if (ctor->IsEmpty()) {
    return SWIG_ERROR;
  }

  if (!objRef.InstanceOf(ctor->Value())) {
    return SWIG_TypeError;
  }
  SwigNapiObjectWrap_inst *ow = Napi::ObjectWrap<SwigNapiObjectWrap_inst>::Unwrap(objRef);
  *ptr = ow->self;

  if (((flags & SWIG_POINTER_RELEASE) == SWIG_POINTER_RELEASE) && !ow->owned) {
    return SWIG_ERROR_RELEASE_NOT_OWNED;
  } else {
    if (flags & SWIG_POINTER_DISOWN) {
      ow->owned = false;
    }
    if (flags & SWIG_POINTER_CLEAR) {
      ow->self = nullptr;
    }
  }
  return SWIG_OK;
}


SWIGRUNTIME int SWIG_Napi_GetInstancePtr(Napi::Value valRef, void **ptr) {
  if(!valRef.IsObject()) {
    return SWIG_TypeError;
  }
  Napi::Object objRef = valRef.ToObject();
  SwigNapiObjectWrap_inst *ow = Napi::ObjectWrap<SwigNapiObjectWrap_inst>::Unwrap(objRef);

  if(ow->self == nullptr) {
    return SWIG_ERROR;
  }

  *ptr = ow->self;
  return SWIG_OK;
}


SWIGRUNTIME int SWIG_Napi_ConvertPtr(Napi::Value valRef, void **ptr, swig_type_info *info, int flags) {
  /* special case: JavaScript null => C NULL pointer */
  if(valRef.IsNull()) {
    *ptr=0;
    return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }
  if(!valRef.IsObject()) {
    return SWIG_TypeError;
  }
  Napi::Object objRef = valRef.ToObject();
  return SWIG_Napi_ConvertInstancePtr(objRef, ptr, info, flags);
}

SWIGRUNTIME Napi::Value SWIG_Napi_NewPointerObj(void *ptr, swig_type_info *info, int flags) {
  Napi::FunctionReference *ctor = reinterpret_cast<SWIGNAPI_ClientData>(info->clientdata);
  Napi::Env env = ctor->Env();

  if (ptr == nullptr) {
    return env.Null();
  }

  Napi::External<void> native = Napi::External<void>::New(env, ptr);
  Napi::Value wrapped = ctor->New({native});
  return wrapped;
}

#define SWIG_ConvertPtr(obj, ptr, info, flags)    SWIG_Napi_ConvertPtr(obj, ptr, info, flags)
#define SWIG_NewPointerObj(ptr, info, flags)      SWIG_Napi_NewPointerObj(ptr, info, flags)

#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_Napi_ConvertInstancePtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(thisvalue, type, flags)     SWIG_Napi_NewPointerObj(thisvalue, type, flags)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_Napi_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_Napi_NewPointerObj(ptr, type, 0)

#define SWIG_GetInstancePtr(obj, ptr)    SWIG_Napi_GetInstancePtr(obj, ptr)

SWIGRUNTIME Napi::Value _SWIGNapi_wrap_equals(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  void *arg1 = (void *) 0 ;
  void *arg2 = (void *) 0 ;
  bool result;
  int res1;
  int res2;

  if(info.Length() != 1) throw Napi::Error::New(env, "Illegal number of arguments for equals.");

  res1 = SWIG_GetInstancePtr(info.This(), &arg1);
  if (!SWIG_IsOK(res1)) {
    throw Napi::Error::New(env, "Could not get pointer from 'this' object for equals.");
  }
  res2 = SWIG_GetInstancePtr(info[0], &arg2);
  if (!SWIG_IsOK(res2)) {
    throw Napi::Error::New(env, SWIG_ArgError(res2) + " in method '" "equals" "', argument " "1"" of type '" "void *""'");
  }

  result = (bool)(arg1 == arg2);
  jsresult = Napi::Boolean::New(env, result);

  return jsresult;
  goto fail;
fail:
  return env.Undefined();
}

SWIGRUNTIME Napi::Value _wrap_getCPtr(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  void *arg1 = (void *) 0 ;
  long result;
  int res1;

  res1 = SWIG_GetInstancePtr(info.This(), &arg1);
  if (!SWIG_IsOK(res1)) {
    throw Napi::Error::New(env, SWIG_ArgError(res1) + " in method '" "getCPtr" "', argument " "1"" of type '" "void *""'");
  }

  result = (long)arg1;
  jsresult = Napi::Number::New(env, result);

  return jsresult;
  goto fail;
fail:
  return env.Undefined();
}


#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIGNapi_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIGNapi_NewPackedObj(ptr, sz, type)


/* ---------------------------------------------------------------------------
 * Support for IN/OUTPUT typemaps (see Lib/typemaps/inoutlist.swg)
 *
 * ---------------------------------------------------------------------------*/

SWIGRUNTIME

Napi::Value SWIGNapi_AppendOutput(Napi::Value result, Napi::Value obj) {
  if (result.IsUndefined()) {
    result = Napi::Array::New(0);
  } else if (!result.IsArray()) {
    Napi::Array tmparr = Napi::Array::New(0);
    tmparr.Set(static_cast<uint32_t>(0), result);
    result = tmparr;
  }

  Napi::Array arr = result.As<Napi::Array>();
  arr.Set(arr.Length(), obj);
  return arr;
}
