/**
 * JavaScript ArrayBuffer maps
 */

// Read-only ArrayBuffer in arguments
#define READONLY_BUFFER_SIGNATURE (const void *arraybuffer_data, const size_t arraybuffer_len)

// Writable ArrayBuffer in arguments
#define WRITABLE_BUFFER_SIGNATURE (void *arraybuffer_data, size_t arraybuffer_len)

// New ArrayBuffer returned in arguments from the C++ side -> ArrayBuffer as return value from the JS side
#define RETURN_NEW_BUFFER_SIGNATURE (void **arraybuffer_data, size_t *arraybuffer_len)

/**
 * Read-only ArrayBuffer in argument.
 *
 * To include generic versions of the in typemaps, add:
 *
 * %typemap(in)        (void *, size_t) = (const void* arraybuffer_data, const size_t arraybuffer_len);
 * %typemap(typecheck) (void *, size_t) = (const void* arraybuffer_data, const size_t arraybuffer_len);
 *
 * or to discriminate by argument names:
 * %typemap(in)        (void *data, size_t length) = (const void* arraybuffer_data, const size_t arraybuffer_len);
 * %typemap(typecheck) (void *data, size_t length) = (const void* arraybuffer_data, const size_t arraybuffer_len);
 */

%typemap(in) READONLY_BUFFER_SIGNATURE {
  if ($input.IsArrayBuffer()) {
    Napi::ArrayBuffer buf = $input.As<Napi::ArrayBuffer>();
    $1 = static_cast<$1_ltype>(buf.Data());
    $2 = buf.ByteLength();
  } else {
    SWIG_exception_fail(SWIG_TypeError, "in method '$symname', argument is not a Buffer");
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VOIDPTR) (const void* arraybuffer_data, const size_t arraybuffer_len) {
  $1 = $input.IsArrayBuffer();
}


/**
 * New ArrayBuffer returned in arguments from the C++ side -> ArrayBuffer as return value from the JS side.
 *
 * In order to use the argout typemap, the function must have the following signature:
 *
 * void buffer(void **arraybuffer_data, size_t *arraybuffer_len)
 *
 * In this case, this function will be wrapped by a JS function that takes
 * no arguments (because of numinputs=0) and returns an ArrayBuffer
 */
%typemap(in, numinputs=0) RETURN_NEW_BUFFER_SIGNATURE ($*1_ltype temp_data, size_t temp_len) {
  $1 = &temp_data;
  $2 = &temp_len;
}
%typemap(argout) (void **arraybuffer_data, size_t *arraybuffer_len) {
  if (*$1 != SWIG_NULLPTR) {
    Napi::ArrayBuffer buf = Napi::ArrayBuffer::New(env, *$1, *$2);
    NAPI_CHECK_RESULT(buf.As<Napi::Value>(), $result);
  } else {
    $result = env.Null();
  }
}

/**
 * Writable ArrayBuffer in arguments.
 *
 * This typemap allows to pass a writable ArrayBuffer:
 *
 * void buffer(void *arraybuffer_data, size_t arraybuffer_len)
 *
 * In this case, this function will be wrapped by a JS function that takes
 * a Buffer argument in which the C++ code is expected to write
 *
 * This typemap includes a provision for the memory sync problem in WASM
 *
 * It is one of the few examples of a difference between the Node.js and the WASM
 * environment mentioned in the manual
 */
#ifdef SWIG_NO_WASM

// Node.js-only version
%typemap(in) WRITABLE_BUFFER_SIGNATURE {
  if ($input.IsArrayBuffer()) {
    Napi::ArrayBuffer buf = $input.As<Napi::ArrayBuffer>();
    $1 = static_cast<$1_ltype>(buf.Data());
    $2 = buf.ByteLength();
  } else {
    SWIG_exception_fail(SWIG_TypeError, "in method '$symname', argument is not a Buffer");
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VOIDPTR) WRITABLE_BUFFER_SIGNATURE {
  $1 = $input.IsArrayBuffer();
}

#else

// Node.js + WASM version
%typemap(in) WRITABLE_BUFFER_SIGNATURE (Napi::ArrayBuffer _global_ab, Napi::Reference<Napi::Value> _global_ab_ref) %{
  if ($input.IsArrayBuffer()) {
    _global_ab = $input.As<Napi::ArrayBuffer>();
    $1 = static_cast<$1_ltype>(_global_ab.Data());
    $2 = _global_ab.ByteLength();
  } else {
    SWIG_exception_fail(SWIG_TypeError, "in method '$symname', argument is not a Buffer");
  }
#ifdef __EMSCRIPTEN__
  _global_ab_ref = Napi::Persistent(_global_ab.As<Napi::Value>());
#endif
%}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VOIDPTR) WRITABLE_BUFFER_SIGNATURE {
  $1 = $input.IsArrayBuffer();
}

%typemap(argout, fragment="emnapi.h") WRITABLE_BUFFER_SIGNATURE
%{
#ifdef __EMSCRIPTEN__
napi_value ab_value = _global_ab_ref.Value();
emnapi_sync_memory(env, false, &ab_value, 0, NAPI_AUTO_LENGTH);
#endif
%}

#endif
