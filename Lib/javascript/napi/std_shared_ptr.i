/* -----------------------------------------------------------------------------
 * std_shared_ptr.i
 *
 * SWIG library file for handling std::shared_ptr.
 *
 * It implements a JS proxy wrapper around shared pointers, that allows
 * to use them as they were plain objects of the base type:
 * - to call the methods of the base type object
 * - to use it in place of a plain object as a function input argument 
 * - to use a plain object where a shared pointer is expected
 *
 * Additionally, shared_ptr to JS created objects passed to C++
 * are counted as references to the JS objects protecting them
 * from the GC. This means that C++ can keep a copy of a passed
 * shared_ptr.
 *
 * ----------------------------------------------------------------------------- */

#define SWIG_SHARED_PTR_NAMESPACE std
%include <shared_ptr.i>

%define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE)

// These typemaps obtain a JS persistent reference
// that is freed when the shared_ptr is destroyed,
// signaling the GC that C++ has released the value
%typemap(in) std::shared_ptr<CONST TYPE> {
  TYPE *plain_ptr;
  int res = SWIG_ConvertPtr($input, reinterpret_cast<void**>(&plain_ptr), $descriptor(TYPE *), %convertptr_flags);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "TYPE", $symname, $argnum);
  }
  Napi::Reference<Napi::Value> *persistent = new Napi::Reference<Napi::Value>;
  if (!$input.IsNull()) {
    *persistent = Napi::Persistent($input);
  }
  auto env_data = env.GetInstanceData<EnvInstanceData>();
  $1 = std::shared_ptr<CONST TYPE>(plain_ptr, [persistent, env_data](void *){
    SWIG_NAPI_RunOnJSMainThread(env_data, [persistent](){
#ifdef SWIGRUNTIME_DEBUG
      printf("Releasing persistent reference for shared_ptr\n");
#endif
      delete persistent;
    });
  });
}

%typemap(in) std::shared_ptr<CONST TYPE> *, std::shared_ptr<CONST TYPE> & {
  TYPE *plain_ptr;
  int res = SWIG_ConvertPtr($input, reinterpret_cast<void**>(&plain_ptr), $descriptor(TYPE *), %convertptr_flags);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "TYPE", $symname, $argnum);
  }
  Napi::Reference<Napi::Value> *persistent = new Napi::Reference<Napi::Value>;
  if (!$input.IsNull()) {
    *persistent = Napi::Persistent($input);
  }
  auto env_data = env.GetInstanceData<EnvInstanceData>();
  $1 = new std::shared_ptr<CONST TYPE>(plain_ptr, [persistent, env_data](void *){
    SWIG_NAPI_RunOnJSMainThread(env_data, [persistent](){
#ifdef SWIGRUNTIME_DEBUG
      printf("Releasing persistent reference for shared_ptr\n");
#endif
      delete persistent;
    });
  });
}
%typemap(freearg) std::shared_ptr<CONST TYPE> *, std::shared_ptr<CONST TYPE> & {
  delete $1;
}

// When importing a shared_ptr in JS, the underlying value is wrapped as if it was
// a plain pointer and the owning shared_ptr is saved in a finalizer lambda that
// will be called and freed when the JS proxy object is destroyed
// (the *& trick is needed because $1 is a SwigValueWrapper)
%typemap(out) std::shared_ptr<CONST TYPE> {
  %set_output(SWIG_NewPointerObj(const_cast<TYPE *>($1.get()), $descriptor(TYPE *), SWIG_POINTER_OWN | %newpointer_flags));
  if (!$result.IsNull()) {
    auto *owner = new std::shared_ptr<CONST TYPE>(*&$1);
    auto finalizer = new SWIG_NAPI_Finalizer([owner](){
      delete owner;
    });
    SWIG_NAPI_SetFinalizer(env, $result, finalizer);
  }
}

%typemap(out) std::shared_ptr<CONST TYPE> & {
  %set_output(SWIG_NewPointerObj(const_cast<TYPE *>($1->get()), $descriptor(TYPE *), $owner | %newpointer_flags));
  if (!$result.IsNull()) {
    auto owner = new std::shared_ptr<CONST TYPE>(*$1);
    auto finalizer = new SWIG_NAPI_Finalizer([owner](){
      delete owner;
    });
    SWIG_NAPI_SetFinalizer(env, $result, finalizer);
  }
}

%typemap(in, numinputs=0) std::shared_ptr<CONST TYPE> &OUTPUT {
  $1 = new std::shared_ptr<CONST TYPE>;
}
// owner is shared_ptr that exists only when the C++ method succeeded
// $1 exists on both the nominal and the exception path
%typemap(argout) std::shared_ptr<CONST TYPE> &OUTPUT {
  %set_output(SWIG_NewPointerObj(const_cast<TYPE *>($1->get()), $descriptor(TYPE *), SWIG_POINTER_OWN | %newpointer_flags));
  auto owner = new std::shared_ptr<CONST TYPE>(*$1);
  auto finalizer = new SWIG_NAPI_Finalizer([owner](){
    delete owner;
  });
  SWIG_NAPI_SetFinalizer(env, $result, finalizer);
}
%typemap(freearg) std::shared_ptr<CONST TYPE> &OUTPUT {
  delete $1;
}

%template() std::shared_ptr<CONST TYPE>;

#ifdef SWIGTYPESCRIPT
%typemap(ts) std::shared_ptr<CONST TYPE>, std::shared_ptr<CONST TYPE> &
    "$typemap(ts, TYPE)"
%typemap(tsout) std::shared_ptr<CONST TYPE> &OUTPUT
    "$typemap(ts, TYPE)"
#endif

%enddef
