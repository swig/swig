/* ------------------------------------------------------------
 *  Async Typemaps for Javascript
 * ------------------------------------------------------------ */

/*
 * Async mode wrappers use three additional typemaps that are
 * unique to Javascript async mode:
 *
 * - async_in
 *   It is applied on the main thread after the check typemap
 *   It is allowed access to V8
 *   Its main use is to create persistent references to prevent GC
 *   With multiple arguments, this typemap is applied in the usual order
 *
 * - async_pre
 *   It is applied in the worker thread immediately before the action
 *   It is not allowed to access V8 and must support concurrent execution
 *   Its main use is to lock objects that need to be locked
 *   With mutliple arguments, this typemap is always applied by order of
 *   of the pointer value - to avoid deadlocks
 *
 * - async_post
 *   It is applied in the worker thread immediately after the action
 *   It is not allowed to access V8 and must support concurrent execution
 *   Its main use is to unlock the locked objects
 *   With mutliple arguments, this typemap is always applied by order of
 *   of the pointer value - to avoid deadlocks
 */

/* 
 * With NAPI, all pointers and references have a
 * SWIG_NAPI_ObjectWrap_inst wrapper
 * By default, all of them are locked during async operations
 * If an object type supports concurrent access - because it
 * is read-only or because it has its own locking - you should
 * replace these typemaps with empty ones
 */

%typemap(async_in)
    SWIGTYPE * (SWIG_NAPI_ObjectWrap_inst *ow),
    SWIGTYPE & (SWIG_NAPI_ObjectWrap_inst *ow) {
  Napi::Object obj;
  NAPI_CHECK_RESULT($input.ToObject(), obj);
  ow = Napi::ObjectWrap<SWIG_NAPI_ObjectWrap_inst>::Unwrap(obj);
  persistent.push_back(ow);
}

%typemap(async_pre) SWIGTYPE *, SWIGTYPE & {
  ow$argnum->lock();
}

%typemap(async_post) SWIGTYPE *, SWIGTYPE & {
  ow$argnum->unlock();
}
