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
        const char *msg = SWIG_NULLPTR, swig_type_info *info = SWIG_NULLPTR);
SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, const char *msg);
SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, int type, const char *msg);
SWIGRUNTIME void SWIG_NAPI_Raise(Napi::Env env, Napi::Value obj,
        const char *msg = SWIG_NULLPTR, swig_type_info *info = SWIG_NULLPTR);
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

#define SWIG_NAPI_ASSERT_NOTNULL_ENV            assert((napi_env)env != SWIG_NULLPTR)

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

// Execute the jobs on the queue on the main thread
void SWIG_NAPI_RunOnJSMainThread(EnvInstanceData *, std::function<void()> &&);
#if NAPI_HAS_THREADS
// Schedule a job to run on the main thread
void SWIG_NAPI_RunMainThreadQueue(uv_async_t *);
#endif

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
        self(SWIG_NULLPTR),
        owned(true),
        size(0),
        info(SWIG_NULLPTR),
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
        Napi::ObjectWrap<SWIG_OBJ_WRAP>(info), size(0), info(SWIG_NULLPTR), finalizer(SWIG_NULLPTR), _lock() { 
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
    this->finalizer = SWIG_NULLPTR;
    this->owned = false;
    this->self = SWIG_NULLPTR;
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

/**
 * This is an implementation of a generic std::function factory that can produce
 * C++ functions from JS functions.
 *
 * It is used by the function pointer typemaps.
 *
 * The C++ functions support being called both synchronously and asynchronously.
 *
 * When called asynchronously, they support automatically resolving Promises returned from
 * JavaScript async callbacks.
 *
 * A SWIG_NAPI_Callback_Context is the context of a JS function transformed
 *   std::function
 *
 * A SWIG_NAPI_Callback_Call_Context is the context of an invocation of this
 *   function
 *
 * Callbacks require exceptions!
 */
#ifdef NAPI_CPP_EXCEPTIONS

template <typename RET>
struct SWIG_NAPI_Callback_Call_Context;

template <typename RET>
struct SWIG_NAPI_Callback_Context;
template <typename RET>
void SWIG_NAPI_Callback_CallJS(Napi::Env, Napi::Function, Napi::Reference<Napi::Value> *, SWIG_NAPI_Callback_Call_Context<RET> *);

// The NAPI context can be created and destroyed only
// in the main JS thread
template <typename RET>
struct SWIG_NAPI_Callback_Context {
#if NAPI_HAS_THREADS
  // Used when calling from a background thread
  Napi::TypedThreadSafeFunction<Napi::Reference<Napi::Value>, SWIG_NAPI_Callback_Call_Context<RET>, SWIG_NAPI_Callback_CallJS<RET>> tsfn;
#endif
  // Used when calling from the JS thread
  Napi::Reference<Napi::Function> jsfn_ref;
  // The this value inside the JS callback
  Napi::Reference<Napi::Value> this_value_ref;
  // The async context
#if NAPI_HAS_THREADS && !defined(__EMSCRIPTEN__)
  Napi::AsyncContext js_async_context;
#endif

  EnvInstanceData *env_data;

  // The out typemap
  std::function<RET(Napi::Env, Napi::Value)> tmap_out;

  SWIG_NAPI_Callback_Context(Napi::Env env):
#if NAPI_HAS_THREADS && !defined(__EMSCRIPTEN__)
    js_async_context(env, "SWIG_NAPI_Callback_Task"),
#endif
    env_data(env.GetInstanceData<EnvInstanceData>()) {}
};

template <typename RET>
struct SWIG_NAPI_Callback_Call_Context {
  SWIG_NAPI_Callback_Context<RET> *context;

#if NAPI_HAS_THREADS
  std::thread::id calling_thread_id;
#endif

  // The value returned to C++ and its barrier
  typename SWIG_remove_void<RET>::type c_ret;
  std::string error_msg;
  std::mutex m;
  std::condition_variable cv;
  bool ready;
  bool error;

  // The in typemaps
  std::function<std::vector<napi_value>(Napi::Env)> tmaps_in;

  SWIG_NAPI_Callback_Call_Context(SWIG_NAPI_Callback_Context<RET> *fn):
    context(fn), ready(false), error(false) {}
};

// This is the actual trampoline, it
// * always runs on the main thread
//   - called synchronously
//   - or called via a ThreadSafeFunction
// * converts the arguments to JS
// * calls into JS
// * resolves the returned promise if the
//   js callback is async
template <typename RET>
void SWIG_NAPI_Callback_CallJS(Napi::Env env,
  Napi::Function js_callback,
  Napi::Reference<Napi::Value> *js_context,
  SWIG_NAPI_Callback_Call_Context<RET> *call_context) {
  // Here we are back in the main V8 thread, potentially from an async context
  Napi::HandleScope store{env};

  // Convert the C++ arguments to JS
  std::vector<napi_value> js_args = call_context->tmaps_in(env);

  // Call the JS callback
  try {
#if NAPI_HAS_THREADS && !defined(__EMSCRIPTEN__)
    Napi::Value js_ret = js_callback.MakeCallback(call_context->context->this_value_ref.Value(),
      js_args, call_context->context->js_async_context);
#else
    Napi::Value js_ret = js_callback.Call(call_context->context->this_value_ref.Value(), js_args);
#endif

    // Handle the Promise in case the function was async
    if (js_ret.IsPromise()) {
#if NAPI_HAS_THREADS
      if (call_context->context->env_data->js_main_thread.main_thread_id ==
          call_context->calling_thread_id) {
        throw std::runtime_error{"Can't resolve a Promise when called synchronously"};
      }
      napi_value on_resolve = Napi::Function::New(env, [env, call_context]
          (const Napi::CallbackInfo &info) -> void {
          // Handle the JS return value
          try {
            SWIG_novoid_assignment_call(call_context->context->tmap_out,
              call_context->c_ret, env, info[0]);
          } catch (const std::exception &e) {
            call_context->error = true;
            call_context->error_msg = e.what();
          }

          // Unblock the C++ thread
          // This is very tricky and it is not the officially recommended
          // C++ locking sequence.  As soon as we unblock the main
          // thread, napi_context can potentially disappear.
          // Keep the mutex until the last possible moment.
          std::lock_guard<std::mutex> lock{call_context->m};
          call_context->ready = true;
          call_context->cv.notify_one();
        });
      napi_value on_reject = Napi::Function::New(env, [call_context]
          (const Napi::CallbackInfo &info) -> void {
          // Handle exceptions
          call_context->error = true;
          call_context->error_msg = info[0].ToString();

          // Unblock the C++ thread (same thing as above)
          std::lock_guard<std::mutex> lock{call_context->m};
          call_context->ready = true;
          call_context->cv.notify_one();
        });
#if NAPI_HAS_THREADS && !defined(__EMSCRIPTEN__)
      js_ret.ToObject().Get("then").As<Napi::Function>().MakeCallback(js_ret, 1, &on_resolve,
        call_context->context->js_async_context);
      js_ret.ToObject().Get("catch").As<Napi::Function>().MakeCallback(js_ret, 1, &on_reject,
        call_context->context->js_async_context);
#else
      js_ret.ToObject().Get("then").As<Napi::Function>().Call(js_ret, 1, &on_resolve);
      js_ret.ToObject().Get("catch").As<Napi::Function>().Call(js_ret, 1, &on_reject);
#endif
      return;
#else
      throw std::runtime_error{"No multithreading support"};
#endif
    }

    // Handle the JS return value
    SWIG_novoid_assignment_call(call_context->context->tmap_out, call_context->c_ret, env, js_ret);
  } catch (const std::exception &err) {
    // Handle exceptions
    call_context->error = true;
    call_context->error_msg = err.what();
  }

  // Unblock the C++ thread (same thing as above)
  std::lock_guard<std::mutex> lock{call_context->m};
  call_context->ready = true;
  call_context->cv.notify_one();
}

// A JS trampoline is an std::function with a custom destructor
// implemented a custom deleter of a std::unique_ptr.
// It can be kept on the C++ side, can be called and destroyed both
// from the JS thread (sync) and the background threads (async).
// It must be constructed on the JS thread.
// It does not support reentrancy, the C++ code must
// make multiple parallel calls. The object is trivially
// copy-constructible but it will always keep the same V8 context
// which will be destroyed when the last copy is destroyed.
//
// Sync mode sequence, everything runs in the JS thread:
//   * The lambda is constructed from JS context
//   * JS runs and calls the C++ code which needs the callback
//   * C++ calls operator() which calls the lambda to enter JS, then
//     processes the returned value, then lifts the barrier
//   * The barrier is already open when the outer lambda reaches the end
//
// Async mode sequence:
//   * [JS thread] The lambda is constructed from JS context
//   * [JS thread] JS runs and calls the C++ code which needs the callback
//   * [Background thread] C++ calls operator() which schedules
//     CallJS via TSFN to run on the main thread and stops on the barrier
//   * [JS thread] CallJS runs, calls JS and handles the returned value
//     If the JS callback is not async, it unblocks the barrier
//     If the JS callback is async, CallJS schedules the two reject/resolve
//     lambdas to run on .then() and on .catch()
//     These lambdas process the values and unblock the outer
//     lambda
//   * [Background thread] C++ is unblocked, everything else must have
//     finished running and destructing, the outer lambda that contains
//     the local variables is destroyed
//
template <typename RET, typename ...ARGS>
// TODO: Update the SWIG build process with the new node-addon-api
// gyp files, they define now the default visibility
std::function<RET(ARGS...)> SWIG_NAPI_Callback(
  Napi::Value js_callback,
  // These perform argument and return value conversions and
  // can be called only on the JS thread
  std::function<void(Napi::Env, std::vector<napi_value> &, ARGS...)> tmaps_in,
  std::function<RET(Napi::Env, Napi::Value)> tmap_out,
  Napi::Value this_value
) {
  Napi::Env env{js_callback.Env()};
  if (!js_callback.IsFunction())
    throw Napi::Error::New(js_callback.Env(), "Passed argument is not a function");

  // The custom shared_ptr deleter for the function context
  // This releases the resources when the last copy
  // of the returned std::function is destroyed
  static const auto destroy_context = [](SWIG_NAPI_Callback_Context<RET> *context) {
#if NAPI_HAS_THREADS
    if (std::this_thread::get_id() == context->env_data->js_main_thread.main_thread_id) {
#ifdef SWIGRUNTIME_DEBUG
      printf("SWIG_NAPI_Callback: sync deletion %p\n", context);
#endif
      // Sync deletion - actually delete
      context->tsfn.Release();
      delete context;
    } else {
#ifdef SWIGRUNTIME_DEBUG
      printf("SWIG_NAPI_Callback: async deletion %p\n", context);
#endif
      // Async deletion - reschedule on the JS thread
      SWIG_NAPI_RunOnJSMainThread(context->env_data, [context]() {
#ifdef SWIGRUNTIME_DEBUG
        printf("SWIG_NAPI_Callback: async deletion bottom half %p\n", context);
#endif
        context->tsfn.Release();
        delete context;
      });
    }
#else // NAPI_HAS_THREADS
#ifdef SWIGRUNTIME_DEBUG
      printf("SWIG_NAPI_Callback: deletion %p\n", context);
#endif
      delete context;
#endif // NAPI_HAS_THREADS
  };

  // This is what allows to have a custom destructor for the lambda which
  // is otherwise trivially copy-constructible, this uniq_ptr is
  // moved to the std::function lambda
  // (use a shared_ptr to preserve the copy-constructible nature of the std::function)
  auto napi_context = std::shared_ptr<SWIG_NAPI_Callback_Context<RET>>(new SWIG_NAPI_Callback_Context<RET>(env), destroy_context);
#if NAPI_HAS_THREADS
  napi_context->tsfn = Napi::TypedThreadSafeFunction<Napi::Reference<Napi::Value>, SWIG_NAPI_Callback_Call_Context<RET>, SWIG_NAPI_Callback_CallJS<RET>>::New(env,
    js_callback.As<Napi::Function>(),
    Napi::Object::New(env),
    "SWIG_NAPI_Callback_Task",
    0,
    1
  );
#endif
  napi_context->jsfn_ref = Napi::Persistent(js_callback.As<Napi::Function>());
  napi_context->this_value_ref = Napi::Persistent(this_value);
#ifdef SWIGRUNTIME_DEBUG
  printf("SWIG_NAPI_Callback: create context %p\n", napi_context);
#endif

  napi_context->tmap_out = tmap_out;
  napi_context->this_value_ref = Napi::Reference<Napi::Value>::New(this_value);

   // This is the function that will be returned to the C++ code
  return [tmaps_in, napi_context](ARGS&&... args) -> RET {
    // Start by allocating a new call context
    auto call_context = std::unique_ptr<SWIG_NAPI_Callback_Call_Context<RET>>(new SWIG_NAPI_Callback_Call_Context<RET>(napi_context.get()));
    // Here we are called by the C++ code - we might be in a the main thread (synchronous call)
    // or a background thread (asynchronous call).
#if NAPI_HAS_THREADS
    call_context->calling_thread_id = std::this_thread::get_id();
#endif

    // The typemaps, saving in a lambda avoids std::tuple
    call_context->tmaps_in = [tmaps_in, &args...](Napi::Env env) -> std::vector<napi_value> {
        std::vector<napi_value> js_args(sizeof...(args));
        tmaps_in(env, js_args, args...);
        return js_args;
    };

    // Are we in the thread pool background thread (V8 is not accessible) or not?
    // (this is what allows this typemap to work in both sync and async mode)
#if NAPI_HAS_THREADS
    if (call_context->calling_thread_id == napi_context->env_data->js_main_thread.main_thread_id) {
      // Synchronous call
      Napi::Function js_cb = napi_context->jsfn_ref.Value();
      SWIG_NAPI_Callback_CallJS(js_cb.Env(), js_cb, &napi_context->this_value_ref, call_context.get());
    } else {
      // Asynchronous call
      napi_context->tsfn.BlockingCall(call_context.get());
    }
#else // NAPI_HAS_THREADS
    // Only synchronous call
    Napi::Function js_cb = napi_context->jsfn_ref.Value();
    SWIG_NAPI_Callback_CallJS(js_cb.Env(), js_cb, &napi_context->this_value_ref, call_context.get());
#endif // NAPI_HAS_THREADS

    // This is the main thread barrier
    std::unique_lock<std::mutex> lock{call_context->m};
    call_context->cv.wait(lock, [&call_context]{ return call_context->ready; });

    if (call_context->error) throw std::runtime_error{call_context->error_msg};

    // This trick allows to handle void as a return type without constexpr
    // https://stackoverflow.com/questions/3305876/using-template-for-return-value-how-to-handle-void-return
    return static_cast<RET>(call_context->c_ret);
  };
};
#endif
