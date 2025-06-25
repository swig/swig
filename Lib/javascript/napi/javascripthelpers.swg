/* -----------------------------------------------------------------------------
 * javascripthelpers.swg
 *
 * Common fragments
 * ----------------------------------------------------------------------------- */

%fragment("SWIG_NAPI_RunOnJSMainThread_def", "header") %{
// Execute the jobs on the queue on the main thread
void SWIG_NAPI_RunOnJSMainThread(EnvInstanceData *, std::function<void()> &&);
#if NAPI_HAS_THREADS
// Schedule a job to run on the main thread
void SWIG_NAPI_RunMainThreadQueue(uv_async_t *);
#endif
%} // SWIG_NAPI_RunOnJSMainThread_def fragment

%fragment("SWIG_NAPI_RunOnJSMainThread_init", "init") %{
#if NAPI_HAS_THREADS
  auto env_data = env.GetInstanceData<EnvInstanceData>();
  auto &js_main_thread = env_data->js_main_thread;

  // Init the mechanism for scheduling jobs on the JS main thread
  js_main_thread.main_thread_id = std::this_thread::get_id();
  js_main_thread.handle = new uv_async_t;
  uv_loop_t *event_loop;
  if (napi_get_uv_event_loop(env, &event_loop) != napi_ok)
    std::abort();
  if (uv_async_init(event_loop, js_main_thread.handle, SWIG_NAPI_RunMainThreadQueue) != 0)
    std::abort();
  // The initial status of the async handle is inactive
#ifndef __EMSCRIPTEN__
  uv_unref(reinterpret_cast<uv_handle_t *>(js_main_thread.handle));
#endif
  js_main_thread.handle->data = static_cast<void*>(env_data);
#endif
%}


%fragment("SWIG_NAPI_RunOnJSMainThread", "wrapper", fragment="SWIG_NAPI_RunOnJSMainThread_def", fragment="SWIG_NAPI_RunOnJSMainThread_init") %{
/* ---------------------------------------------------------------------------
 * Execute the jobs on the queue on the main thread
 * ---------------------------------------------------------------------------*/
#if NAPI_HAS_THREADS
void SWIG_NAPI_RunMainThreadQueue(uv_async_t *async) {
#ifdef SWIGRUNTIME_DEBUG
  printf("Running scheduled tasks on main thread\n");
#endif
  auto env_data = reinterpret_cast<EnvInstanceData *>(async->data);

  // As the lambdas are very light, it is better to not release the lock at all
  std::lock_guard<std::mutex> lock(env_data->js_main_thread.lock);
  while (!env_data->js_main_thread.jobs.empty()) {
    env_data->js_main_thread.jobs.front()();
    env_data->js_main_thread.jobs.pop();
  }
  // Disable the async because the queue is empty
  // (we do not want to block Node from exiting)
#ifndef __EMSCRIPTEN__
  uv_unref(reinterpret_cast<uv_handle_t *>(env_data->js_main_thread.handle));
#endif
}
#endif


/* ---------------------------------------------------------------------------
 * Schedule a job to run on the main thread
 * ---------------------------------------------------------------------------*/
void SWIG_NAPI_RunOnJSMainThread(EnvInstanceData *env_data, std::function<void()> &&job) {
#if NAPI_HAS_THREADS
  if (env_data->js_main_thread.main_thread_id == std::this_thread::get_id()) {
#ifdef SWIGRUNTIME_DEBUG
    printf("Running scheduled task synchronously on the main thread\n");
#endif
    job();
  } else {
#ifdef SWIGRUNTIME_DEBUG
    printf("Scheduling a task on the main thread\n");
#endif
    std::lock_guard<std::mutex> lock(env_data->js_main_thread.lock);
    env_data->js_main_thread.jobs.emplace(std::move(job));
    if (uv_async_send(env_data->js_main_thread.handle) != 0)
      std::abort();
#ifndef __EMSCRIPTEN__
    uv_ref(reinterpret_cast<uv_handle_t *>(env_data->js_main_thread.handle));
#endif
  }
#else
#ifdef SWIGRUNTIME_DEBUG
  printf("Running a task on the main thread w/o thread support\n");
#endif
  job();
#endif
}
%} // SWIG_NAPI_RunOnJSMainThread fragment

%fragment("SWIG_NAPI_Callback", "header", fragment="SWIG_NAPI_RunOnJSMainThread") %{
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
      napi_value args[] = {on_resolve, on_reject};
      // This is the correct way of handling a Promise
      // from C++
      // https://github.com/nodejs/node-addon-api/issues/1658
#if NAPI_HAS_THREADS && !defined(__EMSCRIPTEN__)
      js_ret.ToObject().Get("then").As<Napi::Function>().MakeCallback(js_ret, 2, args,
        call_context->context->js_async_context);
#else
      js_ret.ToObject().Get("then").As<Napi::Function>().Call(js_ret, 2, args);
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

%} // SWIG_NAPI_Callback fragment
