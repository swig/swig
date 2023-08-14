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

SWIGINTERN Napi::Error SWIG_NAPI_NewError(Napi::Env env, int type, const char *msg) {
  switch(type) {
    default:
    case SWIG_IOError:
    case SWIG_MemoryError:
    case SWIG_SystemError:
    case SWIG_RuntimeError:
    case SWIG_DivisionByZero:
    case SWIG_SyntaxError:
      return Napi::Error::New(env, msg);
    case SWIG_OverflowError:
    case SWIG_IndexError:
      return Napi::RangeError::New(env, msg);
    case SWIG_ValueError:
    case SWIG_TypeError:
      return Napi::TypeError::New(env, msg);
  }
}

#define SWIG_exception(code, msg)               SWIG_NAPI_Raise(env, code, msg)
#define SWIG_fail                               goto fail

// Used instead of SWIG_NAPI_Raise when rejecting a Promise
// in the main thread (during initialization/parsing)
#define SWIG_NAPI_Reject(env, code, msg)        do {                          \
      SWIG_NAPI_deferred.Reject(SWIG_NAPI_NewError(env, code, msg).Value());  \
      SWIG_NAPI_deferred_finalized = true;                                    \
      return Status::REJECT;                                                  \
    } while (0)

#define SWIG_NAPI_ASSERT_NOTNULL_ENV            assert((napi_env)env != SWIG_NULLPTR)

#ifdef NAPI_CPP_EXCEPTIONS

// Used instead of SWIG_NAPI_Raise when rejecting a Promise
// in the background thread (for handling %catches)
// This implements macro overloading based on the number of provided arguments
// It is inspired by a famous stackoverflow answer:
// https://stackoverflow.com/questions/3046889/optional-parameters-with-c-macros
#define SWIG_NAPI_GET_5TH(arg1, arg2, arg3, arg4, arg5,... ) arg5
#define SWIG_NAPI_AsyncThrow_1(env, obj)        throw SWIG_NAPI_AsyncError([_e](Napi::Env env) { return obj; })
#define SWIG_NAPI_AsyncThrow_2(env, type, msg)  throw SWIG_NAPI_AsyncError(type, msg)
#define SWIG_NAPI_AsyncThrow_3(env, obj, type, desc) throw SWIG_NAPI_AsyncError([_e](Napi::Env env) { return obj; })
#define SWIG_NAPI_AsyncThrow_SELECT(...)        SWIG_NAPI_GET_5TH(__VA_ARGS__, SWIG_NAPI_AsyncThrow_3, SWIG_NAPI_AsyncThrow_2, SWIG_NAPI_AsyncThrow_1)                 
#define SWIG_NAPI_AsyncThrow(...)               SWIG_NAPI_AsyncThrow_SELECT(__VA_ARGS__)(__VA_ARGS__)

#define SWIG_Error(code, msg)                   SWIG_NAPI_Raise(env, code, msg)
#define NAPI_CHECK_MAYBE(maybe)                 (maybe)
#define NAPI_CHECK_RESULT(maybe, result)        (result = maybe)

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, const char *msg) {
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  throw Napi::Error::New(env, msg);
}

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, int type, const char *msg) {
  if ((napi_env)env == SWIG_NULLPTR) {
    // Async throw from a worker thread without access to V8
    // Throw a C++ exception, the async worker will handle it
    switch(type) {
      default:
      case SWIG_IOError:
      case SWIG_MemoryError:
      case SWIG_SystemError:
      case SWIG_RuntimeError:
      case SWIG_DivisionByZero:
      case SWIG_SyntaxError:
        throw std::runtime_error(msg);
      case SWIG_OverflowError:
      case SWIG_IndexError:
        throw std::range_error(msg);
      case SWIG_ValueError:
      case SWIG_TypeError:
        throw std::invalid_argument(msg);
    }
  }

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
        const char *msg = SWIG_NULLPTR, swig_type_info *info = SWIG_NULLPTR) {
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  throw Napi::Error(env, obj);
}

#else // NAPI_CPP_EXCEPTIONS

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
  SWIG_NAPI_NewError(env, type, msg).ThrowAsJavaScriptException();
}

SWIGINTERN void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj,
        const char *msg = SWIG_NULLPTR, swig_type_info *info = SWIG_NULLPTR) {
  Napi::Error(env, obj).ThrowAsJavaScriptException();
}

#endif // NAPI_CPP_EXCEPTIONS

void JS_veto_set_variable(const Napi::CallbackInfo &info) {
  SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
}

/* ---------------------------------------------------------------------------
 * Module data per V8 isolate
 * ---------------------------------------------------------------------------*/

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

// A lock is a pair of two lambdas for locking and unlocking
typedef std::function<void()> SWIG_Async_Lock_Func;
typedef std::pair<SWIG_Async_Lock_Func, SWIG_Async_Lock_Func> SWIG_Lock;
// An ordered list of locks
typedef std::map<void *, SWIG_Lock> SWIG_Locks_List;

// RAII guard, uses a reference to an allocated lock list
class SWIG_Guard {
private:
  SWIG_Locks_List &list;
  bool locked;
public:
  SWIG_Guard(SWIG_Locks_List &_list) : list(_list), locked(false) {}
  virtual ~SWIG_Guard() {
    if (locked) {
      for (auto const &lock : list) {
        lock.second.second();
      }
    }
  }
  void lock() {
    for (auto const &lock : list) {
      lock.second.first();
    }
    locked = true;
  }
};

/*
 * This class carries an asynchronous error from a
 * background thread
 * It takes a lambda that can generate the Napi::Value
 * from the Napi::Env once back to the main thread
 *
 * Its constructors match the different forms of SWIG_NAPI_Raise
 */
class SWIG_NAPI_AsyncError : public std::exception {
  std::function<Napi::Value(Napi::Env)> object;
public:
  // SWIG_NAPI_Raise(obj)
  // The second and third argument are optional and not used
  SWIG_NAPI_AsyncError(
    const std::function<Napi::Value(Napi::Env)> _obj,
    const char *msg = SWIG_NULLPTR,
    swig_type_info *info = SWIG_NULLPTR): object(_obj) {}
  // SWIG_NAPI_Raise(msg)
  SWIG_NAPI_AsyncError(const std::function<const char *(Napi::Env)> err):
    object([err](Napi::Env env) {
      return SWIG_NAPI_NewError(env, SWIG_RuntimeError, err(env)).Value();
    }) {}
  // SWIG_NAPI_Raise(type, msg)
  SWIG_NAPI_AsyncError(const int type, const char *msg):
    object([type, msg](Napi::Env env) {
      return SWIG_NAPI_NewError(env, type, msg).Value();
    }) {}
  Napi::Value Value(Napi::Env env) { return object(env); }
};

/* ---------------------------------------------------------------------------
 * Base class for all wrapped objects,
 * used directly when unwrapping unknown objects
 * ---------------------------------------------------------------------------*/
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
        self(SWIG_NULLPTR),
        owned(true),
        size(0),
        info(SWIG_NULLPTR) {
      uv_mutex_init(&_lock);
    }
    virtual ~SWIG_NAPI_ObjectWrap_templ() {};

    static void JS_veto_set_static_variable(const Napi::CallbackInfo &, const Napi::Value &);
    void JS_veto_set_variable(const Napi::CallbackInfo &, const Napi::Value &);

    inline void lock() { uv_mutex_lock(&_lock); };
    inline void unlock() { uv_mutex_unlock(&_lock); };

    Napi::Value ToString(const Napi::CallbackInfo &info);

  private:
    // Every wrapped object has an associated async lock
    uv_mutex_t _lock;
};

template <typename SWIG_OBJ_WRAP>
SWIG_NAPI_ObjectWrap_templ<SWIG_OBJ_WRAP>::SWIG_NAPI_ObjectWrap_templ(const Napi::CallbackInfo &info) :
        Napi::ObjectWrap<SWIG_OBJ_WRAP>(info), size(0), info(SWIG_NULLPTR) { 
  uv_mutex_init(&_lock);
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

template <typename SWIG_OBJ_WRAP>
void SWIG_NAPI_ObjectWrap_templ<SWIG_OBJ_WRAP>::JS_veto_set_static_variable(const Napi::CallbackInfo &info, const Napi::Value &value) {
  SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
}

template <typename SWIG_OBJ_WRAP>
void SWIG_NAPI_ObjectWrap_templ<SWIG_OBJ_WRAP>::JS_veto_set_variable(const Napi::CallbackInfo &info, const Napi::Value &value) {
  SWIG_NAPI_Raise(info.Env(), "Tried to write read-only variable.");
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

bool SWIG_NAPI_IsWrappedObject(Napi::Env env, Napi::Object v) {
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  // Check if this is a SWIG wrapper
  Napi::FunctionReference *ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor;
  bool instanceOf;
  NAPI_CHECK_RESULT(v.InstanceOf(ctor->Value()), instanceOf);
  return instanceOf;
  goto fail;
fail:
  return false;
}

SWIGRUNTIME int SWIG_NAPI_ConvertInstancePtr(Napi::Object objRef, void **ptr, swig_type_info *info, int flags) {
  SWIG_NAPI_ObjectWrap_inst *ow;
  Napi::Env env = objRef.Env();
  if(!objRef.IsObject()) return SWIG_ERROR;

  if (!SWIG_NAPI_IsWrappedObject(env, objRef)) {
    return SWIG_TypeError;
  }

  ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(objRef);

  // Now check if the SWIG type is compatible unless the types match exactly or the type is unknown
  if(info && ow->info != info && ow->info != SWIG_NULLPTR) {
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
      ow->self = SWIG_NULLPTR;
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

  if(ow->self == SWIG_NULLPTR) {
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
  SWIG_NAPI_ASSERT_NOTNULL_ENV;
  Napi::External<void> native;
  Napi::FunctionReference *ctor;

  if (ptr == SWIG_NULLPTR) {
    return env.Null();
  }
  native = Napi::External<void>::New(env, ptr);

  size_t *idx = info != SWIG_NULLPTR ?
        reinterpret_cast<SWIG_NAPI_ClientData *>(info->clientdata) :
        SWIG_NULLPTR;
  if (idx == SWIG_NULLPTR) {
    // This type does not have a dedicated wrapper
    ctor = env.GetInstanceData<EnvInstanceData>()->SWIG_NAPI_ObjectWrapCtor;
  } else {
    ctor = env.GetInstanceData<EnvInstanceData>()->ctor[*idx];
  }

  Napi::Value wrapped;
  NAPI_CHECK_RESULT(ctor->New({native}), wrapped);

  // Preserve the type even if using the generic wrapper
  if (idx == SWIG_NULLPTR && info != SWIG_NULLPTR) {
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
 * Async execution
 * ---------------------------------------------------------------------------*/

// This class is essentially a functor with multiple entry points
// Its main purpose is to keep the context - the wrapper local variables -
// as class members between those calls in different threads
// Init() is called on the main thread with V8 access and deals with in typemaps
// Execute() is called on a worker thread without V8 access and does the work
// OnOK()/Cleanup() are called on the main thread with V8 access and deal with
//   the out typemaps
class SWIG_NAPI_AsyncContext {
protected:
  Napi::Env env;
  Napi::Promise::Deferred SWIG_NAPI_deferred;
  bool SWIG_NAPI_deferred_finalized;
public:
  enum Status { OK, REJECT, THROW };
  SWIG_NAPI_AsyncContext(
    Napi::Env _env
  ) : 
    env(_env),
    SWIG_NAPI_deferred(Napi::Promise::Deferred(_env)),
    SWIG_NAPI_deferred_finalized(false) {}
  virtual ~SWIG_NAPI_AsyncContext() {
    if (!SWIG_NAPI_deferred_finalized) {
      // This fixes a very vicious leak
      // Once a Deferred has been created, it won't be destroyed
      // unless it is resolved or rejected - its destructor is a no-op
      // This code is triggered when synchronously throwing while parsing the args
      SWIG_NAPI_deferred.Resolve(env.Undefined());
      SWIG_NAPI_deferred_finalized = true;
    }
  }
  // All methods are prefixed to avoid symbol pollution
  // Alternatively, inheriting through a template
  // allows to not import any member definitions from the base class
  // https://stackoverflow.com/questions/76703197/unshadow-global-identifier-in-a-class
  virtual Status SWIG_NAPI_Init(const Napi::CallbackInfo &) = 0;
  virtual void SWIG_NAPI_Execute() = 0;
  virtual void SWIG_NAPI_Resolve() = 0;
  virtual void SWIG_NAPI_Fail(const Napi::Error &);
  virtual bool SWIG_NAPI_Cleanup() = 0;
  inline Napi::Promise SWIG_NAPI_Promise() { return SWIG_NAPI_deferred.Promise(); }
};

void SWIG_NAPI_AsyncContext::SWIG_NAPI_Fail(const Napi::Error &SWIG_NAPI_error) {
  if (!SWIG_NAPI_Cleanup()) goto fail;
  SWIG_NAPI_deferred_finalized = true;
  SWIG_NAPI_deferred.Reject(SWIG_NAPI_error.Value());
  goto fail;
fail:
  return;
}

// This is the async worker, this class deletes itself (NAPI does this)
// as well as its context when the async operation completes
class SWIG_NAPI_AsyncWorker : public Napi::AsyncWorker {
  SWIG_NAPI_AsyncContext *context;
  // This vector holds persistent references to all JS objects
  // involved in the asynchronous operation - it protects them
  // from being garbage-collected
  std::vector<Napi::ObjectReference *> persistent;
  SWIG_NAPI_AsyncError *error_object;

public:
  SWIG_NAPI_AsyncWorker(
      Napi::Env _env,
      const char *name,
      SWIG_NAPI_AsyncContext *_context) :
    Napi::AsyncWorker(_env, name),
    context(_context),
    persistent(),
    error_object(nullptr) {}

  virtual ~SWIG_NAPI_AsyncWorker() {
    // Release the persistent references
    for (Napi::ObjectReference *ref : persistent) {
      delete ref;
    }
    persistent.clear();
  }

  virtual void OnOK() override {
    Napi::HandleScope scope(Env());
    context->SWIG_NAPI_Resolve();
    delete context;
  }

  virtual void OnError(const Napi::Error &error) override {
    Napi::Env env(Env());
    Napi::HandleScope scope(env);
    if (error_object) {
      context->SWIG_NAPI_Fail(Napi::Error(env, error_object->Value(env)));
      delete error_object;
      error_object = SWIG_NULLPTR;
    } else {
      context->SWIG_NAPI_Fail(error);
    }
    delete context;
  }

  virtual void SetErrorObj(const SWIG_NAPI_AsyncError &err) {
    error_object = new SWIG_NAPI_AsyncError(err);
    SetError("SWIG Asynchronous Error");
  }

  virtual void Execute() override {
#if defined(_CPPUNWIND) || defined(__EXCEPTIONS)
    try {
      context->SWIG_NAPI_Execute();
    } catch (const SWIG_NAPI_AsyncError &e) {
      SetErrorObj(e);
    } catch (const std::exception &e) {
      SetError(e.what());
    }
#else
    context->SWIG_NAPI_Execute();
#endif
  }

  inline void Persist(const Napi::Value &v) {
    if (v.IsObject()) {
      Napi::Object obj;
      NAPI_CHECK_RESULT(v.ToObject(), obj);
      Napi::ObjectReference *ref = new Napi::ObjectReference();
      *ref = Napi::Persistent(obj);
      persistent.push_back(ref);
    }
    return;
    goto fail;
  fail:
    return;
  }

  Napi::Value Run(const Napi::CallbackInfo &info) {
    SWIG_NAPI_AsyncContext::Status rc;

#if defined(_CPPUNWIND) || defined(__EXCEPTIONS)
    try {
      rc = context->SWIG_NAPI_Init(info);
    } catch (...) {
      delete context;
      delete this;
      throw;
    }
#else
    rc = context->SWIG_NAPI_Init(info);
#endif
    if (rc == SWIG_NAPI_AsyncContext::Status::REJECT) {
      Napi::EscapableHandleScope scope(info.Env());
      Napi::Value r = context->SWIG_NAPI_Promise();
      delete context;
      delete this;
      return scope.Escape(r);
    } else if (rc == SWIG_NAPI_AsyncContext::Status::THROW) {
      delete context;
      delete this;
      return Napi::Value();
    }

    Persist(info.This());
    for (size_t i = 0; i < info.Length(); i++) Persist(info[i]);
    Queue();
    return context->SWIG_NAPI_Promise();
  }
};

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
