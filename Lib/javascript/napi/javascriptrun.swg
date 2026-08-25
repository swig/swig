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
    case SWIG_NullReferenceError:
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
    case SWIG_NullReferenceError:
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

// The data describing a wrapped object, common to all of them.
//
// This is a class of its own, and not just a part of the class template below,
// because the generated wrapper methods use it too and they are members of a
// single non-template class, SWIG_NAPI_Wrappers, to avoid instantiating them
// once per wrapped class: this is what the virtual inheritance is for, as both
// this class template and SWIG_NAPI_Wrappers are bases of every wrapper class
// and they must share the same data.
class SWIG_NAPI_ObjectWrapBase {
  public:
    void *self = nullptr;
    bool owned = true;
    size_t size = 0;
    swig_type_info *info = nullptr;

    // Note that this class is deliberately not polymorphic: the objects are
    // only ever destroyed via SWIG_NAPI_ObjectWrap_inst, which does have a
    // virtual destructor, and making this a second polymorphic base of it
    // would just make the wrappers use an adjusted "this" for nothing.
};

// The data of each wrapped class, given to DefineClass() as its data and used
// by the single wrapper class to construct and destroy the wrapped objects.
struct SWIG_NAPI_ClassData {
  swig_type_info *type;
  void (*construct)(SWIG_NAPI_ObjectWrapBase *, const Napi::CallbackInfo &);
  void (*destruct)(SWIG_NAPI_ObjectWrapBase *);
};

// The single class wrapping all the objects: it is defined together with the
// wrappers it inherits from, which are only known after processing all the
// classes, and so are these functions using it.
template <typename SWIG_NAPI_Tag> class SWIG_NAPI_ObjectWrap_templ;
using SWIG_NAPI_ObjectWrap_inst = SWIG_NAPI_ObjectWrap_templ<void>;

SWIGRUNTIME int SWIG_NAPI_ConvertInstancePtr(Napi::Object objRef, void **ptr, swig_type_info *info, int flags);
SWIGRUNTIME void SWIG_NAPI_SetPackedSize(Napi::Object objRef, size_t size);
SWIGRUNTIME int SWIG_NAPI_GetInstancePtr(Napi::Value valRef, void **ptr);
SWIGRUNTIME int SWIG_NAPI_ConvertPtr(Napi::Value valRef, void **ptr, swig_type_info *info, int flags);
SWIGRUNTIME Napi::Value SWIG_NAPI_NewPointerObj(Napi::Env env, void *ptr, swig_type_info *info, int flags);

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
  intptr_t result;
  int res1;

  res1 = SWIG_GetInstancePtr(info.This(), &arg1);
  if (!SWIG_IsOK(res1)) {
    SWIG_Error(SWIG_ArgError(res1), " in method '" "getCPtr" "', argument " "1"" of type '" "void *""'");
  }

  result = (intptr_t)arg1;
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
  SWIG_NAPI_SetPackedSize(obj, size);

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
