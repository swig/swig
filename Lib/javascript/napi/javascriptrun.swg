/* ---------------------------------------------------------------------------
 * Error handling
 *
 * ---------------------------------------------------------------------------*/

/*
 * We support several forms:
 *
 * SWIG_Raise("Error message")
 * which creates an Error object with the error message
 *
 * SWIG_Raise(SWIG_TypeError, "Type error")
 * which creates the specified error type with the message
 *
 * SWIG_Raise(obj)
 * which throws the object itself
 *
 * SWIG_Raise(obj, "Exception const &", SWIGType_p_Exception)
 * which also throws the object itself and discards the unneeded extra type info
 *
 * These must be functions instead of macros to use the C++ overloading to
 * resolve the arguments
 */
#define SWIG_exception(code, msg)               SWIG_Error(code, msg)
#define SWIG_fail                               goto fail

#ifdef NAPI_CPP_EXCEPTIONS

#define SWIG_Error(code, msg)                   SWIG_NAPI_Raise(env, code, msg)
#define NAPI_CHECK_MAYBE(maybe)                 (maybe)
#define NAPI_CHECK_RESULT(maybe, result)        (result = maybe)

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, const char *msg) {
  throw Napi::Error::New(env, msg);
}

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, int type, const char *msg) {
  switch(type) {
    default:
    case SWIG_IOError:
    case SWIG_MemoryError:
    case SWIG_SystemError:
    case SWIG_RuntimeError:
    case SWIG_DivisionByZero:
    case SWIG_SyntaxError:
      throw Napi::Error::New(env, msg);
    case SWIG_OverflowError:
    case SWIG_IndexError:
      throw Napi::RangeError::New(env, msg);
    case SWIG_ValueError:
    case SWIG_TypeError:
      throw Napi::TypeError::New(env, msg);
  }
}

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj,
        const char *msg = nullptr, swig_type_info *info = nullptr) {
  throw Napi::Error(env, obj);
}

#else

#define SWIG_Error(code, msg)     do { SWIG_NAPI_Raise(env, code, msg); SWIG_fail; } while (0)
#define NAPI_CHECK_MAYBE(maybe)   do { if (maybe.IsNothing()) SWIG_fail; } while (0)
#define NAPI_CHECK_RESULT(maybe, result)          \
        do {                                      \
                auto r = maybe;                   \
                if (r.IsNothing()) SWIG_fail;     \
                result = r.Unwrap();              \
        } while (0)

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, const char *msg) {
  Napi::Error::New(env, msg).ThrowAsJavaScriptException();
}

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, int type, const char *msg) {
  switch(type) {
    default:
    case SWIG_IOError:
    case SWIG_MemoryError:
    case SWIG_SystemError:
    case SWIG_RuntimeError:
    case SWIG_DivisionByZero:
    case SWIG_SyntaxError:
      Napi::Error::New(env, msg).ThrowAsJavaScriptException();
      return;
    case SWIG_OverflowError:
    case SWIG_IndexError:
      Napi::RangeError::New(env, msg).ThrowAsJavaScriptException();
      return;
    case SWIG_ValueError:
    case SWIG_TypeError:
      Napi::TypeError::New(env, msg).ThrowAsJavaScriptException();
      return;
  }
}

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj,
        const char *msg = nullptr, swig_type_info *info = nullptr) {
  Napi::Error(env, obj).ThrowAsJavaScriptException();
}

#endif

void JS_veto_set_variable(const Napi::CallbackInfo &info) {
  SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
}

struct EnvInstanceData {
  Napi::Env env;
  // Base class per-environment constructor, used to check
  // if a JS object is a SWIG wrapper
  Napi::FunctionReference *SWIG_NAPI_ObjectWrapCtor;
  // Per-environment wrapper constructors, indexed by the number in
  // swig_type->clientdata
  Napi::FunctionReference **ctor;
  swig_module_info *swig_module;
  EnvInstanceData(Napi::Env, swig_module_info *);
  ~EnvInstanceData();
};

typedef size_t SWIG_NAPI_ClientData;

// Base class for all wrapped objects,
// used mostly when unwrapping unknown objects
template <typename SWIG_OBJ_WRAP>
class SWIG_NAPI_ObjectWrap_templ : public Napi::ObjectWrap<SWIG_OBJ_WRAP> {
  public:
    void *self;
    bool owned;
    size_t size;
    swig_type_info *info;
    SWIG_NAPI_ObjectWrap_templ(const Napi::CallbackInfo &info);
    SWIG_NAPI_ObjectWrap_templ(bool, const Napi::CallbackInfo &info) :
        Napi::ObjectWrap<SWIG_OBJ_WRAP>(info),
        self(nullptr),
        owned(true),
        size(0),
        info(nullptr)
        {}
    virtual ~SWIG_NAPI_ObjectWrap_templ() {};

    Napi::Value ToString(const Napi::CallbackInfo &info);
};

template <typename SWIG_OBJ_WRAP>
SWIG_NAPI_ObjectWrap_templ<SWIG_OBJ_WRAP>::SWIG_NAPI_ObjectWrap_templ(const Napi::CallbackInfo &info) :
        Napi::ObjectWrap<SWIG_OBJ_WRAP>(info), size(0), info(nullptr) { 
  Napi::Env env = info.Env();
  if (info.Length() == 1 && info[0].IsExternal()) {
    // This constructor has been called internally from C++/SWIG
    // to wrap an already existing C++ object of unknown type in JS
    this->self = info[0].As<Napi::External<void>>().Data();
    this->owned = false;
  } else {
    SWIG_Error(SWIG_ERROR, "This constructor is not accessible from JS");
  }
  return;
  goto fail;
fail:
  return;
}

template <typename SWIG_OBJ_WRAP>
Napi::Value SWIG_NAPI_ObjectWrap_templ<SWIG_OBJ_WRAP>::ToString(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  static char repr[128];
  const char *name = SWIG_TypePrettyName(this->info);
  snprintf(repr, sizeof(repr), "{SwigObject %s (%s) at %p %s}",
    this->info ? this->info->name : "unknown",
    name ? name : "unknown",
    this->self,
    this->owned ? "[owned]" : "[copy]");
  return Napi::String::New(env, repr);
}

class SWIG_NAPI_ObjectWrap_inst : public SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_ObjectWrap_inst> {
public:
  using SWIG_NAPI_ObjectWrap_templ::SWIG_NAPI_ObjectWrap_templ;
  static Napi::Function GetClass(Napi::Env);
  static void GetMembers(
    Napi::Env,
    std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &,
    std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &
  );
};

void SWIG_NAPI_ObjectWrap_inst::GetMembers(
        Napi::Env env,
        std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &members,
        std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &
) {
  members.erase("toString");
  members.insert({"toString", SWIG_NAPI_ObjectWrap_templ::InstanceMethod("toString", &SWIG_NAPI_ObjectWrap_templ::ToString)});
}

Napi::Function SWIG_NAPI_ObjectWrap_inst::GetClass(Napi::Env env) {
  return Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::DefineClass(env, "SwigObject", {});
}

SWIGRUNTIME int SWIG_NAPI_ConvertInstancePtr(Napi::Object objRef, void **ptr, swig_type_info *info, int flags) {
  SWIG_NAPI_ObjectWrap_inst *ow;
  Napi::Env env = objRef.Env();
  if(!objRef.IsObject()) return SWIG_ERROR;

  // Check if this is a SWIG wrapper
  Napi::FunctionReference *ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor;
  bool instanceOf;
  NAPI_CHECK_RESULT(objRef.InstanceOf(ctor->Value()), instanceOf);
  if (!instanceOf) {
    return SWIG_TypeError;
  }

  ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(objRef);

  // Now check if the SWIG type is compatible unless the types match exactly or the type is unknown
  if(info && ow->info != info && ow->info != nullptr) {
    swig_cast_info *tc = SWIG_TypeCheckStruct(ow->info, info);
    if (!tc && ow->info->name) {
      tc = SWIG_TypeCheck(ow->info->name, info);
    }
    bool type_valid = tc != 0;
    if(!type_valid) {
      return SWIG_TypeError;
    }
    int newmemory = 0;
    *ptr = SWIG_TypeCast(tc, ow->self, &newmemory);
    assert(!newmemory); /* newmemory handling not yet implemented */
  } else {
    *ptr = ow->self;
  }

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


SWIGRUNTIME int SWIG_NAPI_GetInstancePtr(Napi::Value valRef, void **ptr) {
  SWIG_NAPI_ObjectWrap_inst *ow;
  if(!valRef.IsObject()) {
    return SWIG_TypeError;
  }
  Napi::Object objRef;
  NAPI_CHECK_RESULT(valRef.ToObject(), objRef);
  ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(objRef);

  if(ow->self == nullptr) {
    return SWIG_ERROR;
  }

  *ptr = ow->self;
  return SWIG_OK;
  goto fail;
fail:
  return SWIG_ERROR;
}


SWIGRUNTIME int SWIG_NAPI_ConvertPtr(Napi::Value valRef, void **ptr, swig_type_info *info, int flags) {
  // special case: JavaScript null => C NULL pointer
  if (valRef.IsNull()) {
    *ptr=0;
    return (flags & SWIG_POINTER_NO_NULL) ? SWIG_NullReferenceError : SWIG_OK;
  }

  if (!valRef.IsObject()) {
    return SWIG_TypeError;
  }

  Napi::Object objRef;
  NAPI_CHECK_RESULT(valRef.ToObject(), objRef);
  return SWIG_NAPI_ConvertInstancePtr(objRef, ptr, info, flags);
  goto fail;
fail:
  return SWIG_ERROR;
}

SWIGRUNTIME Napi::Value SWIG_NAPI_NewPointerObj(Napi::Env env, void *ptr, swig_type_info *info, int flags) {
  Napi::External<void> native;
  Napi::FunctionReference *ctor;

  if (ptr == nullptr) {
    return env.Null();
  }
  native = Napi::External<void>::New(env, ptr);

  size_t *idx = info != nullptr ?
        reinterpret_cast<SWIG_NAPI_ClientData *>(info->clientdata) :
        nullptr;
  if (idx == nullptr) {
    // This type does not have a dedicated wrapper
    ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor;
  } else {
    ctor = env.GetInstanceData<EnvInstanceData>()->ctor[*idx];
  }

  Napi::Value wrapped;
  NAPI_CHECK_RESULT(ctor->New({native}), wrapped);

  // Preserve the type even if using the generic wrapper
  if (idx == nullptr && info != nullptr) {
    Napi::Object obj;
    NAPI_CHECK_RESULT(wrapped.ToObject(), obj);
    Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj)->info = info;
  }

  if ((flags & SWIG_POINTER_OWN) == SWIG_POINTER_OWN) {
    Napi::Object obj;
    NAPI_CHECK_RESULT(wrapped.ToObject(), obj);
    Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj)->owned = true;
  }

  return wrapped;
  goto fail;
fail:
  return Napi::Value();
}

#define SWIG_ConvertPtr(obj, ptr, info, flags)          SWIG_NAPI_ConvertPtr(obj, ptr, info, flags)
#define SWIG_NewPointerObj(ptr, info, flags)            SWIG_NAPI_NewPointerObj(env, ptr, info, flags)

#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_NAPI_ConvertInstancePtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(thisvalue, type, flags)     SWIG_NAPI_NewPointerObj(env, thisvalue, type, flags)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_NAPI_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_NAPI_NewPointerObj(env, ptr, type, 0)

#define SWIG_GetInstancePtr(obj, ptr)                   SWIG_NAPI_GetInstancePtr(obj, ptr)

SWIGRUNTIME Napi::Value _SWIG_NAPI_wrap_equals(const Napi::CallbackInfo &info) {
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


/* ---------------------------------------------------------------------------
 * PackedData object
 * (objects visible to JS that do not have a dedicated wrapper but must preserve type)
 * ---------------------------------------------------------------------------*/

SWIGRUNTIME
Napi::Value SWIG_NAPI_NewPackedObj(Napi::Env env, void *data, size_t size, swig_type_info *type) {
  void *data_copy = new uint8_t[size];
  memcpy(data_copy, data, size);
  Napi::Value val = SWIG_NAPI_NewPointerObj(env, data_copy, type, SWIG_POINTER_OWN);
  Napi::Object obj;
  if (val.IsEmpty()) goto fail;

  NAPI_CHECK_RESULT(val.ToObject(), obj);
  Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj)->size = size;

fail:
  return val;
}

SWIGRUNTIME
int SWIG_NAPI_ConvertPacked(Napi::Value valRef, void *ptr, size_t size, swig_type_info *type) {
  void *tmp;
  if (!SWIG_IsOK(SWIG_NAPI_ConvertPtr(valRef, &tmp, type, 0))) {
    return SWIG_ERROR;
  }
  memcpy(ptr, tmp, size);
  return SWIG_OK;
}

#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_NAPI_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_NAPI_NewPackedObj(env, ptr, sz, type)


/* ---------------------------------------------------------------------------
 * Support for IN/OUTPUT typemaps (see Lib/typemaps/inoutlist.swg)
 *
 * ---------------------------------------------------------------------------*/

SWIGRUNTIME

Napi::Value SWIG_NAPI_AppendOutput(Napi::Env env, Napi::Value result, Napi::Value obj) {
  if (result.IsUndefined()) {
    result = Napi::Array::New(env);
  } else if (!result.IsArray()) {
    Napi::Array tmparr = Napi::Array::New(env);
    tmparr.Set(static_cast<uint32_t>(0), result);
    result = tmparr;
  }

  Napi::Array arr = result.As<Napi::Array>();
  arr.Set(arr.Length(), obj);
  return arr;
}
