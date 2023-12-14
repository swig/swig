%native(piAsync) void piAsync();

// placeholder() used to help SWIG generate "SWIG_From_double" call
%{
    double placeholder();
%}
double placeholder() { return 0; }

%wrapper %{
static Napi::Value piAsync(const Napi::CallbackInfo &info) {
  Napi::Env env(info.Env());

  class Tasklet : public Napi::AsyncWorker {
    Napi::Env env;
  public:
    Napi::Promise::Deferred deferred;
  private:
    double result;
    Pi *arg1;
    // This is needed to access the lock in the async handler without going through V8
    SWIG_NAPI_ObjectWrap_inst *ow;
    // This will keep a persistent reference to the underlying object
    // while the async handler is running to prevent the GC from collecting it
    Napi::ObjectReference *ref;

  public:
    Tasklet(Napi::Env _env) :
      Napi::AsyncWorker(_env, "SWIG_Example_Async_Wrapper_Task"),
      env(_env),
      deferred(Napi::Promise::Deferred::New(_env)),
      ow(nullptr),
      ref(nullptr)
      {}

    virtual ~Tasklet() {
      if (ref) delete ref;
    }

    virtual void OnOK() override {
      Napi::HandleScope scope(env);
      Napi::Value jsresult;
      jsresult = SWIG_From_double(env, result);
      deferred.Resolve(jsresult);
      goto fail;
    fail:
      return;
    }

    virtual void OnError(const Napi::Error &error) override {
      Napi::HandleScope scope(env);
      deferred.Reject(error.Value());
    }

    virtual void Execute() override {
      Napi::Env env(nullptr);
      if (ow) ow->lock();
#ifdef NAPI_CPP_EXCEPTIONS
      try {
        result = arg1->approx();
      } catch (const std::exception &e) {
        SetError(e.what());
      }
#else
      result = (int)arg1->approx();
#endif
      if (ow) ow->unlock();
#ifndef NAPI_CPP_EXCEPTIONS
      goto fail;
    fail:
      returrn;
#endif
    }

    virtual void Init(const Napi::CallbackInfo &info) {
      Napi::Object obj;
      int res1 = SWIG_ConvertPtr(info[0], reinterpret_cast<void**>(&arg1), SWIGTYPE_p_Pi, 0 |  0 );
      if (!SWIG_IsOK(res1)) {
        SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "piAsync" "', argument " "1"" of type '" "Pi *""'"); 
      }
      NAPI_CHECK_RESULT(info[0].ToObject(), obj);
      if (SWIG_NAPI_IsWrappedObject(env, obj)) {
        // Extract the pointer to the underlying C++ structure
        ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj);
      }

      // Create a persistent reference
      ref = new Napi::ObjectReference();
      *ref = Napi::Persistent(obj);
    
      goto fail;
    fail:
      return;
    }
  };

  Tasklet *self;
  if (info.Length() != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for piAsync.");
  self = new Tasklet(env);
  self->Init(info);
  self->Queue();
  return self->deferred.Promise();
#ifndef NAPI_CPP_EXCEPTIONS
fail:
  return Napi::Value();
#endif
}
%}
