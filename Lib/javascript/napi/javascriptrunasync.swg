/* ---------------------------------------------------------------------------
 * Async execution
 *
 * Pulled in when the code contains asynchronous methods
 *
 * Not compatible with WASM target
 *
 * ---------------------------------------------------------------------------*/
%fragment("AsyncWorker", "header", fragment="run_AsyncWorker") %{
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
  SWIG_NAPI_AsyncContext(Napi::Env);
  virtual ~SWIG_NAPI_AsyncContext();
  // All methods are prefixed to avoid symbol pollution
  // Alternatively, inheriting through a template
  // allows to not import any member definitions from the base class
  // https://stackoverflow.com/questions/76703197/unshadow-global-identifier-in-a-class
  virtual Status SWIG_NAPI_Init(const Napi::CallbackInfo &) = 0;
  virtual void SWIG_NAPI_Execute() = 0;
  virtual void SWIG_NAPI_Resolve() = 0;
  virtual bool SWIG_NAPI_Cleanup() = 0;
#ifdef NAPI_CPP_EXCEPTIONS
  virtual void SWIG_NAPI_Fail(const Napi::Error &);
  virtual void SWIG_NAPI_Rethrow(const std::exception_ptr &) = 0;
#endif
  inline Napi::Promise SWIG_NAPI_Promise() { return SWIG_NAPI_deferred.Promise(); }
};

// This is the async worker, this class deletes itself (NAPI does this)
// as well as its context when the async operation completes
class SWIG_NAPI_AsyncWorker : public Napi::AsyncWorker {
  SWIG_NAPI_AsyncContext *context;
  // This vector holds persistent references to all JS objects
  // involved in the asynchronous operation - it protects them
  // from being garbage-collected
  std::vector<Napi::ObjectReference *> persistent;
  std::exception_ptr saved_exception;

public:
  SWIG_NAPI_AsyncWorker(Napi::Env, const char *, SWIG_NAPI_AsyncContext *);
  virtual ~SWIG_NAPI_AsyncWorker();

  virtual void OnOK() override;
  virtual void OnError(const Napi::Error &error) override;
  virtual void Execute() override;
  Napi::Value Run(const Napi::CallbackInfo &info);

  inline void Persist(const Napi::Value &v) {
    if (v.IsObject()) {
      Napi::Object obj;
      NAPI_CHECK_RESULT(v.ToObject(), obj);
      Napi::ObjectReference *ref = new Napi::ObjectReference();
      *ref = Napi::Persistent(obj);
      persistent.push_back(ref);
    }
    return;
#ifndef NAPI_CPP_EXCEPTIONS
    goto fail;
  fail:
    return;
#endif
  }
};
%}

%fragment("run_AsyncWorker", "wrapper") %{

SWIG_NAPI_AsyncContext::SWIG_NAPI_AsyncContext(Napi::Env _env) : 
    env(_env),
    SWIG_NAPI_deferred(Napi::Promise::Deferred(_env)),
    SWIG_NAPI_deferred_finalized(false) {}

SWIG_NAPI_AsyncContext::~SWIG_NAPI_AsyncContext() {
  if (!SWIG_NAPI_deferred_finalized) {
    // This fixes a very vicious leak
    // Once a Deferred has been created, it won't be destroyed
    // unless it is resolved or rejected - its destructor is a no-op
    // This code is triggered when synchronously throwing while parsing the args
    SWIG_NAPI_deferred.Resolve(env.Undefined());
    SWIG_NAPI_deferred_finalized = true;
  }
}

#ifdef NAPI_CPP_EXCEPTIONS
void SWIG_NAPI_AsyncContext::SWIG_NAPI_Fail(const Napi::Error &error) {
  if (!SWIG_NAPI_Cleanup()) goto fail;
  SWIG_NAPI_deferred_finalized = true;
  SWIG_NAPI_deferred.Reject(error.Value());
  goto fail;
fail:
  return;
}
#endif

SWIG_NAPI_AsyncWorker::SWIG_NAPI_AsyncWorker(
      Napi::Env _env,
      const char *name,
      SWIG_NAPI_AsyncContext *_context) :
    Napi::AsyncWorker(_env, name),
    context(_context),
    persistent(),
    saved_exception(nullptr) {}

SWIG_NAPI_AsyncWorker::~SWIG_NAPI_AsyncWorker() {
  // Release the persistent references
  for (Napi::ObjectReference *ref : persistent) {
    delete ref;
  }
  persistent.clear();
}

void SWIG_NAPI_AsyncWorker::OnOK() {
  Napi::Env env(Env());
  Napi::HandleScope scope(env);
#ifdef NAPI_CPP_EXCEPTIONS
  try {
    context->SWIG_NAPI_Rethrow(saved_exception);
  } catch (Napi::Error &error) {
    context->SWIG_NAPI_Fail(error);
    delete context;
    return;
  } catch (std::exception &ex) {
    Napi::Error error = Napi::Error::New(env, ex.what());
    context->SWIG_NAPI_Fail(error);
    delete context;
    return;
  }
#endif
  context->SWIG_NAPI_Resolve();
  delete context;
}

void SWIG_NAPI_AsyncWorker::OnError(const Napi::Error &error) {
  // This should never happen, we catch all errors now
  abort();
}

void SWIG_NAPI_AsyncWorker::Execute() {
#ifdef NAPI_CPP_EXCEPTIONS
  try {
    context->SWIG_NAPI_Execute();
  } catch (...) {
    saved_exception = std::current_exception();
  }
#else
  context->SWIG_NAPI_Execute();
#endif
}

Napi::Value SWIG_NAPI_AsyncWorker::Run(const Napi::CallbackInfo &info) {
  SWIG_NAPI_AsyncContext::Status rc;

#ifdef NAPI_CPP_EXCEPTIONS
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
    Napi::Value r = context->SWIG_NAPI_Promise();
    context->SWIG_NAPI_Cleanup();
    delete context;
    delete this;
    return r;
  } else if (rc == SWIG_NAPI_AsyncContext::Status::THROW) {
    context->SWIG_NAPI_Cleanup();
    delete context;
    delete this;
    return Napi::Value();
  }

  Persist(info.This());
  for (size_t i = 0; i < info.Length(); i++) Persist(info[i]);
  Queue();
  return context->SWIG_NAPI_Promise();
}
%}
