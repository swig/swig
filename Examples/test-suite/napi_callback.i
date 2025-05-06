%module napi_callback

// Test the SWIG Node-API callback support

%include <std_string.i>

%include <exception.i>

// Rethrow all C++ exceptions as JS exceptions
%exception {
  try {
    $action
  } catch (const std::exception &e) {
    SWIG_Raise(e.what());
    SWIG_fail;
  }
}

// ==========================================================
// This typemap converts a JS callback to a C++ std::function
// ==========================================================


// This is the version that supports both synchronous and asynchronous calling
// and can resolve automatically Promises returned from JS (ie it supports JS async callbacks)
// It uses the rather complex SWIG_NAPI_Callback code fragment that is candidate for inclusion
// in the SWIG JSE standard library
%typemap(in) std::function<std::string(int, const std::string &)> giver {
  if (!$input.IsFunction()) {
    %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
  }
  
  $1 = SWIG_NAPI_Callback<std::string, int, const std::string &>(
    $input,
    std::function<void(Napi::Env, std::vector<napi_value> &, int, const std::string &)>(
        [](Napi::Env env, std::vector<napi_value> &js_args, int passcode, const std::string &name) -> void {
        $typemap(out, int, 1=passcode, result=js_args.at(0), argnum=callback argument 1);
        $typemap(out, std::string, 1=name, result=js_args.at(1), argnum=callback argument 2);
      }
    ),
    [](Napi::Env env, Napi::Value js_ret) -> std::string {
      std::string c_ret;
      $typemap(in, std::string, input=js_ret, 1=c_ret, argnum=JavaScript callback return value)
      return c_ret;
    },
    env.Global()
  );
}

// Same but for void (*)()
%typemap(in) std::function<void()> cb {
  if (!$input.IsFunction()) {
    %argument_fail(SWIG_TypeError, "$type", $symname, $argnum);
  }
  
  $1 = SWIG_NAPI_Callback<void>(
    $input,
    // Empty input typemaps
    std::function<void(Napi::Env, std::vector<napi_value> &)>(
        [](Napi::Env env, std::vector<napi_value> &) -> void {}
    ),
    /// Empty output typemap
    [](Napi::Env env, Napi::Value) -> void {},
    env.Global()
  );
}

// This is the TypeScript type associated
%typemap(ts) std::function<std::string(int, const std::string &)> giver
  "(this: typeof globalThis, pass: number, name: string) => Promise<string> | string";

// The void special case
%typemap(ts) std::function<void()> cb
  "(this: typeof globalThis) => void | Promise<void>";

// Example for wrapping a function that expects a C-style function pointer
// It must support passing a context pointer and it will be replaced by the wrapper
%ignore GiveMeFive_C;
%rename(GiveMeFive_C) GiveMeFive_C_wrapper;
// Declare the function for SWIG
%inline {
std::string GiveMeFive_C_wrapper(std::function<std::string(int, const std::string &)> giver);
}

// This wrapper receives an std::function to be compatible with SWIG_NAPI_Callback
// and calls a C function pointer provided that the C function accepts a context
// that is passed back
%wrapper %{
std::string GiveMeFive_C_wrapper(std::function<std::string(int, const std::string &)> giver) {
  // In this particular example giver should be valid in the lambda
  // But in order to support functions that keep the callback and call it
  // later, we choose to make a copy.
  // This also protects from unexpected return value optimizations by the
  // compiler.
  using cb_t = decltype(giver);
  auto *cb = new cb_t{giver};
  return GiveMeFive_C(
      [](void *data, int arg1, const std::string &arg2) -> std::string {
        // This code supposes that C++ won't keep the function pointer
        // and deletes the std::function after the first call
        // If the function will be called repeatedly, there must be
        // some mechanism to free this object after the last call
        // Transferring the ownership to a unique_ptr allows to handle
        // the exception case
        auto giver_ = std::unique_ptr<cb_t>(reinterpret_cast<cb_t*>(data));
        auto result = (*giver_)(arg1, arg2);
        return result;
      },
      cb);
}
%}

// The function declarations -> goes to the header and SWIG
%inline %{
#include <functional>
#include <string>

std::string GiveMeFive(std::function<std::string(int, const std::string &)> giver);
std::string GiveMeFiveRepeats(std::function<std::string(int, const std::string &)> giver);
std::string GiveMeFive_C(std::string (*giver)(void *, int, const std::string &), void *context);
void JustCall(std::function<void()> cb);
%}

// The function definitions -> goes to the code
%insert("wrapper") %{
std::string GiveMeFive(std::function<std::string(int, const std::string &)> giver) {
  return "received from JS: " + giver(420, "with cheese");
}

std::string GiveMeFive_C(std::string (*giver)(void *, int, const std::string &), void *context) {
  return "received from JS: " + giver(context, 420, "with extra cheese");
}

void JustCall(std::function<void()> cb) {
  cb();
}

std::string GiveMeFiveRepeats(std::function<std::string(int, const std::string &)> giver) {
  std::string r = "";
  for (size_t i = 0; i < 10; i++)
    r += giver(i, ".");
  return r;
}
%}
