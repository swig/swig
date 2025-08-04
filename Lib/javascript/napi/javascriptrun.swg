/* ---------------------------------------------------------------------------
 * SWIG Node-API runtime : declarations
 * ---------------------------------------------------------------------------*/

#include <napi.h>
#if NAPI_HAS_THREADS
#include <thread>
#include <queue>
#include <mutex>
#include <condition_variable>
#include <uv.h>
#endif
#include <exception>

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

SWIGRUNTIME Napi::Error SWIG_NAPI_NewError(Napi::Env env, int type, const char *msg);
SWIGRUNTIME inline Napi::Error SWIG_NAPI_NewError(Napi::Env env, const char *msg);
SWIGRUNTIME inline Napi::Error SWIG_NAPI_NewError(Napi::Env env, Napi::Value obj,
        const char *msg = NULL, swig_type_info *info = NULL);
SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, const char *msg);
SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, int type, const char *msg);
SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj,
        const char *msg = NULL, swig_type_info *info = NULL);
SWIGRUNTIME bool SWIG_NAPI_IsWrappedObject(Napi::Env env, Napi::Object v);
SWIGRUNTIME int SWIG_NAPI_ConvertInstancePtr(Napi::Object objRef, void **ptr, swig_type_info *info, int flags);
SWIGRUNTIME int SWIG_NAPI_GetInstancePtr(Napi::Value valRef, void **ptr);
SWIGRUNTIME int SWIG_NAPI_ConvertPtr(Napi::Value valRef, void **ptr, swig_type_info *info, int flags);
SWIGRUNTIME Napi::Value SWIG_NAPI_NewPointerObj(Napi::Env env, void *ptr, swig_type_info *info, int flags);
SWIGRUNTIME
Napi::Value SWIG_NAPI_NewPackedObj(Napi::Env env, void *data, size_t size, swig_type_info *type);
SWIGRUNTIME
int SWIG_NAPI_ConvertPacked(Napi::Value valRef, void *ptr, size_t size, swig_type_info *type);
SWIGRUNTIME
Napi::Value SWIG_NAPI_AppendOutput(Napi::Env env, Napi::Value result, Napi::Value obj);

// Node-API specific features
using SWIG_NAPI_Finalizer = std::function<void()>;
SWIGRUNTIME int SWIG_NAPI_SetFinalizer(Napi::Env env, Napi::Value val, SWIG_NAPI_Finalizer *finalizer);
SWIGRUNTIME void SWIG_NAPI_SetInstanceData(Napi::Env env, void *module_instance_data);
SWIGRUNTIME void *SWIG_NAPI_GetInstanceData(Napi::Env env);

void JS_veto_set_variable(const Napi::CallbackInfo &info);

#define SWIG_exception(code, msg)               SWIG_NAPI_Raise(env, code, msg)

// Used instead of SWIG_NAPI_Raise when rejecting a Promise
// in the main thread (during initialization/parsing)
#define SWIG_NAPI_Reject(env, code, msg)        do {                          \
      SWIG_NAPI_deferred.Reject(SWIG_NAPI_NewError(env, code, msg).Value());  \
      SWIG_NAPI_deferred_finalized = true;                                    \
      return SWIG_NAPI_Status::REJECT;                                        \
    } while (0)

#define SWIG_NAPI_ASSERT_NOTNULL_ENV            assert((napi_env)env != NULL)

// The two methods of handling exceptions
#ifdef NAPI_CPP_EXCEPTIONS

#define SWIG_Error(code, msg)                   SWIG_NAPI_Raise(env, code, msg)
#define NAPI_CHECK_MAYBE(maybe)                 (maybe)
#define NAPI_CHECK_RESULT(maybe, result)        (result = maybe)
#define SWIG_fail

#else // NAPI_CPP_EXCEPTIONS

#define SWIG_Error(code, msg)     do { SWIG_NAPI_Raise(env, code, msg); SWIG_fail; } while (0)
#define NAPI_CHECK_MAYBE(maybe)   do { if (maybe.IsNothing()) SWIG_fail; } while (0)
#define NAPI_CHECK_RESULT(maybe, result)          \
        do {                                      \
                auto r = maybe;                   \
                if (r.IsNothing()) SWIG_fail;     \
                result = r.Unwrap();              \
        } while (0)
#define SWIG_fail                 goto fail

#endif // NAPI_CPP_EXCEPTIONS

/* ---------------------------------------------------------------------------
 * Declarations for the SWIG language-agnostic calls
 * ---------------------------------------------------------------------------*/

#define SWIG_ConvertPtr(obj, ptr, info, flags)          SWIG_NAPI_ConvertPtr(obj, ptr, info, flags)
#define SWIG_NewPointerObj(ptr, info, flags)            SWIG_NAPI_NewPointerObj(env, ptr, info, flags)

#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_NAPI_ConvertInstancePtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(thisvalue, type, flags)     SWIG_NAPI_NewPointerObj(env, thisvalue, type, flags)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_NAPI_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_NAPI_NewPointerObj(env, ptr, type, 0)

#define SWIG_GetInstancePtr(obj, ptr)                   SWIG_NAPI_GetInstancePtr(obj, ptr)

#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_NAPI_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_NAPI_NewPackedObj(env, ptr, sz, type)

// Helpers to avoid declaring void variables
template <typename T> struct SWIG_remove_void { using type = T; };
template <> struct SWIG_remove_void<void> { using type = int; };

template <typename RET, typename ...ARGS> inline void SWIG_novoid_assignment_call(const std::function<RET(ARGS...)> &fn, RET &ret, const ARGS & ...args) {
  ret = fn(args...);
}
template <typename ...ARGS> inline void SWIG_novoid_assignment_call(const std::function<void(ARGS...)> &fn, int &, const ARGS & ...args) {
  fn(args...);
}

/* ---------------------------------------------------------------------------
 * Module data per V8 isolate
 * ---------------------------------------------------------------------------*/

/* ---------------------------------------------------------------------------
 * Module data per V8 isolate
 * ---------------------------------------------------------------------------*/

struct EnvInstanceData {
  Napi::Env env;
  // Base class per-environment constructor, used to check
  // if a JS object is a SWIG wrapper
  Napi::FunctionReference *SWIG_NAPI_ObjectWrapCtor;
  Napi::FunctionReference *SWIG_NAPI_PackedObjectWrapCtor;
  // Per-environment wrapper constructors, indexed by the number in
  // swig_type->clientdata
  Napi::FunctionReference **ctor;
  swig_module_info *swig_module;
  void *module_instance_data;
#if NAPI_HAS_THREADS
  // Queue for running jobs on the JS main thread from
  // background threads
  struct {
    uv_async_t *handle;
    std::thread::id main_thread_id;
    std::queue<std::function<void()>> jobs;
    std::mutex lock;
  } js_main_thread;
#endif
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
  SWIG_Guard(SWIG_Locks_List &_list);
  virtual ~SWIG_Guard();
  inline void lock() {
    for (auto const &lock : list) {
      lock.second.first();
    }
    locked = true;
  }
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
    std::function<void()> *finalizer; 
    SWIG_NAPI_ObjectWrap_templ(const Napi::CallbackInfo &info);
    SWIG_NAPI_ObjectWrap_templ(bool, const Napi::CallbackInfo &info) :
        Napi::ObjectWrap<SWIG_OBJ_WRAP>(info),
        self(NULL),
        owned(true),
        size(0),
        info(NULL),
        finalizer(nullptr),
        _lock() {}
    virtual ~SWIG_NAPI_ObjectWrap_templ() = default;

    static void JS_veto_set_static_variable(const Napi::CallbackInfo &, const Napi::Value &);
    void JS_veto_set_variable(const Napi::CallbackInfo &, const Napi::Value &);

    inline void lock() { _lock.lock(); };
    inline void unlock() { _lock.unlock(); };

    Napi::Value ToString(const Napi::CallbackInfo &info);

  protected:
    void SWIG_Finalize();

  private:
    // Every wrapped object has an associated async lock
    std::mutex _lock;
};

template <typename SWIG_OBJ_WRAP>
SWIG_NAPI_ObjectWrap_templ<SWIG_OBJ_WRAP>::SWIG_NAPI_ObjectWrap_templ(const Napi::CallbackInfo &info) :
        Napi::ObjectWrap<SWIG_OBJ_WRAP>(info), size(0), info(NULL), finalizer(NULL), _lock() { 
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
#ifndef NAPI_CPP_EXCEPTIONS
  goto fail;
fail:
  return;
#endif
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

template <typename SWIG_OBJ_WRAP>
void SWIG_NAPI_ObjectWrap_templ<SWIG_OBJ_WRAP>::SWIG_Finalize() {
  if (this->finalizer) {
    (*this->finalizer)();
    delete this->finalizer;
    this->finalizer = NULL;
    this->owned = false;
    this->self = NULL;
  }
}

// Instantiated version of the above CRTP class
class SWIG_NAPI_ObjectWrap_inst : public SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_ObjectWrap_inst> {
public:
  using SWIG_NAPI_ObjectWrap_templ::SWIG_NAPI_ObjectWrap_templ;
  ~SWIG_NAPI_ObjectWrap_inst();
  static Napi::Function GetClass(Napi::Env);
  static void GetMembers(
    Napi::Env,
    std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &,
    std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &
  );
};

// Special class used for packed (opaque) objects, has a special destructor
class SWIG_NAPI_PackedObjectWrap_inst : public SWIG_NAPI_ObjectWrap_templ<SWIG_NAPI_PackedObjectWrap_inst> {
public:
  using SWIG_NAPI_ObjectWrap_templ::SWIG_NAPI_ObjectWrap_templ;
  ~SWIG_NAPI_PackedObjectWrap_inst();
  static Napi::Function GetClass(Napi::Env);
  static void GetMembers(
    Napi::Env,
    std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &,
    std::map<std::string, SWIG_NAPI_ObjectWrap_templ::PropertyDescriptor> &
  );
};
