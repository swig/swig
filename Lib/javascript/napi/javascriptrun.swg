/* ---------------------------------------------------------------------------
 * Error handling
 *
 * ---------------------------------------------------------------------------*/
using namespace std::string_literals;

#define NAPI_MAKE_EXCEPTION(code, msg)                                      \

#ifdef NAPI_CPP_EXCEPTIONS

#define SWIG_Error(code, msg)                   \
        do {                                    \
          if ((code) == SWIG_TypeError)                                              \
            throw Napi::TypeError::New(env, std::to_string(code) + ": "s + (msg));   \
          throw Napi::Error::New(env, std::to_string(code) + ": "s + (msg));         \
        } while (0)
#define SWIG_exception(code, msg)               SWIG_Error(code, msg)
#define SWIG_fail                               goto fail
#define NAPI_CHECK_MAYBE(maybe)                 (maybe)
#define NAPI_CHECK_RESULT(maybe, result)        (result = maybe)

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, const char *msg) {
  throw Napi::Error::New(env, msg);
}

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj, const char *msg) {
  throw Napi::Error(env, obj);
}

#else

#define SWIG_Error(code, msg)                                                  \
        do {                                                                   \
          if ((code) == SWIG_TypeError) {                                      \
            Napi::TypeError::New(env, std::to_string(code) + ": "s + (msg)).   \
              ThrowAsJavaScriptException();                                    \
            SWIG_fail;                                                         \
          }                                                                    \
          Napi::Error::New(env, std::to_string(code) + ": "s + (msg)).         \
            ThrowAsJavaScriptException();                                      \
          SWIG_fail;                                                           \
        } while (0)
#define SWIG_exception(code, msg) do { SWIG_Error(code, msg); SWIG_fail; } while (0)
#define SWIG_fail                 goto fail
#define NAPI_CHECK_MAYBE(maybe)                   \
        do {                                      \
                if (maybe.IsNothing()) SWIG_fail; \
        } while (0)
#define NAPI_CHECK_RESULT(maybe, result)        \
        do {                                    \
                auto r = maybe;                 \
                if (r.IsNothing()) SWIG_fail;   \
                result = r.Unwrap();            \
        } while (0)

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, const char *msg) {
  Napi::Error::New(env, msg).ThrowAsJavaScriptException();
}

// TODO: Is this a good idea?
// The other JavaScript SWIG implementations serialize the object to a string
// when throwing, while this one actually throws the object itself
SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj, const char *msg) {
  Napi::Error(env, obj).ThrowAsJavaScriptException();
}

#endif

void JS_veto_set_variable(const Napi::CallbackInfo &info) {
  SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
}

struct EnvInstanceData {
  Napi::Env env;
  // Per-environment wrapper constructors, indexed by the number in
  // swig_type->clientdata
  Napi::FunctionReference **ctor;
  swig_module_info *swig_module;
  EnvInstanceData(Napi::Env, swig_module_info *);
  ~EnvInstanceData();
};

typedef size_t SWIGNAPI_ClientData;

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
    SwigNapiObjectWrap_templ(bool, const Napi::CallbackInfo& info) :
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
  SwigNapiObjectWrap_inst *ow;
  Napi::Env env = objRef.Env();
  if(!objRef.IsObject()) return SWIG_ERROR;

  if (!info) {
    return SWIG_ERROR;
  }

  size_t *idx = reinterpret_cast<SWIGNAPI_ClientData *>(info->clientdata);
  if (idx == nullptr) {
    return SWIG_ERROR;
  }
  Napi::FunctionReference *ctor = env.GetInstanceData<EnvInstanceData>()->ctor[*idx];
  if (ctor == nullptr) {
    return SWIG_ERROR;
  }

  bool instanceOf;
  NAPI_CHECK_RESULT(objRef.InstanceOf(ctor->Value()), instanceOf);
  if (!instanceOf) {
    return SWIG_TypeError;
  }
  ow = Napi::ObjectWrap<SwigNapiObjectWrap_inst>::Unwrap(objRef);
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
  goto fail;
fail:
  return SWIG_ERROR;
}


SWIGRUNTIME int SWIG_Napi_GetInstancePtr(Napi::Value valRef, void **ptr) {
  SwigNapiObjectWrap_inst *ow;
  if(!valRef.IsObject()) {
    return SWIG_TypeError;
  }
  Napi::Object objRef;
  NAPI_CHECK_RESULT(valRef.ToObject(), objRef);
  ow = Napi::ObjectWrap<SwigNapiObjectWrap_inst>::Unwrap(objRef);

  if(ow->self == nullptr) {
    return SWIG_ERROR;
  }

  *ptr = ow->self;
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}


SWIGRUNTIME int SWIG_Napi_ConvertPtr(Napi::Value valRef, void **ptr, swig_type_info *info, int flags) {
  // special case: JavaScript null => C NULL pointer
  if (valRef.IsNull()) {
    *ptr=0;
    return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }

  // special case: Uknown type encapsulated w/o wrapper by the next function
  if (valRef.IsExternal()) {
   *ptr = valRef.As<Napi::External<void>>().Data();
   return SWIG_OK;
  }

  if (!valRef.IsObject()) {
    return SWIG_TypeError;
  }

  Napi::Object objRef;
  NAPI_CHECK_RESULT(valRef.ToObject(), objRef);
  return SWIG_Napi_ConvertInstancePtr(objRef, ptr, info, flags);
  goto fail;
fail:
  return SWIG_ERROR;
}

SWIGRUNTIME Napi::Value SWIG_Napi_NewPointerObj(Napi::Env env, void *ptr, swig_type_info *info, int flags) {
  Napi::External<void> native;

  if (ptr == nullptr) {
    return env.Null();
  }
  native = Napi::External<void>::New(env, ptr);

  size_t *idx = reinterpret_cast<SWIGNAPI_ClientData *>(info->clientdata);
  if (idx == nullptr) {
    // This type is not known to SWIG and does not have a wrapper
    return native;
  }

  Napi::FunctionReference *ctor = env.GetInstanceData<EnvInstanceData>()->ctor[*idx];

  Napi::Value wrapped;
  NAPI_CHECK_RESULT(ctor->New({native}), wrapped);
  return wrapped;
  goto fail;
fail:
  return Napi::Value();
}

#define SWIG_ConvertPtr(obj, ptr, info, flags)    SWIG_Napi_ConvertPtr(obj, ptr, info, flags)
#define SWIG_NewPointerObj(ptr, info, flags)      SWIG_Napi_NewPointerObj(env, ptr, info, flags)

#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_Napi_ConvertInstancePtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(thisvalue, type, flags)     SWIG_Napi_NewPointerObj(env, thisvalue, type, flags)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_Napi_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_Napi_NewPointerObj(env, ptr, type, 0)

#define SWIG_GetInstancePtr(obj, ptr)    SWIG_Napi_GetInstancePtr(obj, ptr)

SWIGRUNTIME Napi::Value _SWIGNapi_wrap_equals(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  void *arg1 = (void *) 0 ;
  void *arg2 = (void *) 0 ;
  bool result;
  int res1;
  int res2;

  if(info.Length() != 1) SWIG_Error(SWIG_ERROR, "Illegal number of arguments for equals.");

  res1 = SWIG_GetInstancePtr(info.This(), &arg1);
  if (!SWIG_IsOK(res1)) {
    SWIG_Error(SWIG_ERROR, "Could not get pointer from 'this' object for equals.");
  }
  res2 = SWIG_GetInstancePtr(info[0], &arg2);
  if (!SWIG_IsOK(res2)) {
    SWIG_Error(SWIG_ArgError(res2), " in method '" "equals" "', argument " "1"" of type '" "void *""'");
  }

  result = (bool)(arg1 == arg2);
  jsresult = Napi::Boolean::New(env, result);

  return jsresult;
  goto fail;
fail:
  return Napi::Value();
}

SWIGRUNTIME Napi::Value _wrap_getCPtr(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Value jsresult;
  void *arg1 = (void *) 0 ;
  long result;
  int res1;

  res1 = SWIG_GetInstancePtr(info.This(), &arg1);
  if (!SWIG_IsOK(res1)) {
    SWIG_Error(SWIG_ArgError(res1), " in method '" "getCPtr" "', argument " "1"" of type '" "void *""'");
  }

  result = (long)arg1;
  jsresult = Napi::Number::New(env, result);

  return jsresult;
  goto fail;
fail:
  return Napi::Value();
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
