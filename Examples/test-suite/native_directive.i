%module native_directive

%{
#include <ctype.h>
int alpha_count(const char *instring) {
  int count = 0;
  const char *s = instring;
  while (s && *s) {
    if (isalpha((int)*s))
      count++;
    s++;
  };
  return count;
}
%}

%inline %{
int CountAlphas(const char *instring) {
  return alpha_count(instring);
}
%}

// Languages that support %native should code up language specific implementations below

#if defined(SWIGJAVA)
%native(CountAlphaCharacters) int alpha_count(const char *inputString);
%{
extern "C" JNIEXPORT jint JNICALL Java_native_1directive_native_1directiveJNI_CountAlphaCharacters(JNIEnv *jenv, jclass jcls, jstring instring) {
  jint jresult = 0 ;
  (void)jcls;

  if (instring) {
    const char *s = (char *)jenv->GetStringUTFChars(instring, 0);
    if (s) {
      jresult = (jint)alpha_count(s);
      jenv->ReleaseStringUTFChars(instring, s);
    }
  }
  return jresult;
}
%}
#endif


// TODO: C#
// TODO: Python


#ifdef SWIGJAVASCRIPT
%feature("async", 0) JavaScript_alpha_count;
%feature("sync", 1) JavaScript_alpha_count;
%native(CountAlphaCharacters) void JavaScript_alpha_count();
#if defined(SWIG_JAVASCRIPT_NAPI)      /* engine = napi */
%native(asyncCountAlphaCharacters) void JavaScript_alpha_count_Async();
%{

// NAPI sync version
static Napi::Value JavaScript_alpha_count(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::EscapableHandleScope scope(env);

  Napi::Value jsresult;
  char *arg1 = (char *)0;
  int res1;
  char *buf1 = 0;
  int alloc1 = 0;
  int result;
  if (info.Length() != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for _wrap_alpha_count.");
  res1 = SWIG_AsCharPtrAndSize(info[0], &buf1, NULL, &alloc1);
  if (!SWIG_IsOK(res1))
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "alpha_count" "', argument " "1"" of type '" "char const *""'");
  arg1 = reinterpret_cast< char * >(buf1);
  result = (int)alpha_count((char const *)arg1);
  jsresult = SWIG_From_int(env, static_cast< int >(result));
  if (alloc1 == SWIG_NEWOBJ) delete[] buf1;
  return scope.Escape(jsresult);
#ifndef NAPI_CPP_EXCEPTIONS
fail:
  return Napi::Value();
#endif
}

// NAPI async version
static Napi::Value JavaScript_alpha_count_Async(const Napi::CallbackInfo &info) {
  Napi::Env env(info.Env());

  class Tasklet : public Napi::AsyncWorker {
    Napi::Env env;
  public:
    Napi::Promise::Deferred deferred;
  private:
    char *arg1 = (char *)0;
    int res1;
    char *buf1 = 0;
    int alloc1 = 0;
    int result;
  public:
    Tasklet(Napi::Env _env) :
      Napi::AsyncWorker(_env, "SWIG_alpha_count_Async_Worker"),
      env(_env),
      deferred(Napi::Promise::Deferred::New(_env))
      {}

    virtual void OnOK() override {
      Napi::HandleScope scope(env);
      Napi::Value jsresult;
      jsresult = SWIG_From_int(env, static_cast< int >(result));
      if (alloc1 == SWIG_NEWOBJ) delete[] buf1;
      deferred.Resolve(jsresult);
#ifndef NAPI_CPP_EXCEPTIONS
      goto fail;
    fail:
      return;
#endif
    }

    virtual void OnError(const Napi::Error &error) override {
      Napi::HandleScope scope(env);
      deferred.Reject(error.Value());
    }

    virtual void Execute() override {
      Napi::Env env(nullptr);
#ifdef NAPI_CPP_EXCEPTIONS
      try {
        result = (int)alpha_count((char const *)arg1);
      } catch (const std::exception &e) {
        SetError(e.what());
      }
#else
      result = (int)alpha_count((char const *)arg1);
      goto fail;
    fail:
      return;
#endif
    }

    virtual void Init(const Napi::CallbackInfo &info) {
      res1 = SWIG_AsCharPtrAndSize(info[0], &buf1, NULL, &alloc1);
      if (!SWIG_IsOK(res1))
        SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "alpha_count" "', argument " "1"" of type '" "char const *""'");
      arg1 = reinterpret_cast< char * >(buf1);
      goto fail;
    fail:
      return;
    }
  };
  Tasklet *self;
  if (info.Length() != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for _wrap_alpha_count.");
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
#elif defined(SWIG_JAVASCRIPT_V8) /* engine = node || v8 */
%{

static SwigV8ReturnValue JavaScript_alpha_count(const SwigV8Arguments &args) {
  SWIGV8_HANDLESCOPE();
  SWIGV8_VALUE jsresult;
  char *arg1 = (char *)0;
  int res1;
  char *buf1 = 0;
  int alloc1 = 0;
  int result;
  if(args.Length() != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments for _wrap_alpha_count.");
  res1 = SWIG_AsCharPtrAndSize(args[0], &buf1, NULL, &alloc1);
  if (!SWIG_IsOK(res1))
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "alpha_count" "', argument " "1"" of type '" "char const *""'");
  arg1 = reinterpret_cast< char * >(buf1);
  result = (int)alpha_count((char const *)arg1);
  jsresult = SWIG_From_int(static_cast< int >(result));
  if (alloc1 == SWIG_NEWOBJ) delete[] buf1;
  SWIGV8_RETURN(jsresult);
fail:
  SWIGV8_RETURN(SWIGV8_UNDEFINED());
}

%}
#elif defined(SWIG_JAVASCRIPT_JSC) /* engine = jsc */
%{

static JSValueRef JavaScript_alpha_count(JSContextRef context, JSObjectRef function,
  JSObjectRef thisObject, size_t argc, const JSValueRef argv[], JSValueRef* exception)
{
  char *arg1 = (char *)0;
  int res1;
  char *buf1 = 0;
  int alloc1 = 0;
  int result;
  JSValueRef jsresult;
  if (argc != 1) SWIG_exception_fail(SWIG_ERROR, "Illegal number of arguments.");
  res1 = SWIG_JSC_AsCharPtrAndSize(context, argv[0], &buf1, NULL, &alloc1);
  if (!SWIG_IsOK(res1))
    SWIG_exception_fail(SWIG_ArgError(res1), "in method '" "alpha_count" "', argument " "1"" of type '" "char const *""'");
  arg1 = reinterpret_cast< char * >(buf1);
  result = (int)alpha_count((char const *)arg1);
  jsresult = SWIG_From_int  SWIG_JSC_FROM_CALL_ARGS(static_cast< int >(result));
  if (alloc1 == SWIG_NEWOBJ) delete[] buf1;
  return jsresult;
fail:
  return JSValueMakeUndefined(context);
}

%}
#else
%{
#error No valid JS engine configured
%}
#endif /* engine */
#endif /* SWIGJAVASCRIPT */

