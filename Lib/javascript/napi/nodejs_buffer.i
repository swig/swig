/**
 * Node.js Buffer maps
 *
 * Avoid using these if you plan to use WASM
 */

/**
 * Read-only Buffer in arguments.
 *
 * To include generic versions of the in typemaps, add:
 *
 * %typemap(in)        (void *, size_t) = (const void* buffer_data, const size_t buffer_len);
 * %typemap(typecheck) (void *, size_t) = (const void* buffer_data, const size_t buffer_len);
 *
 * or to discriminate by argument names:
 * %typemap(in)        (void *data, size_t length) = (const void* buffer_data, const size_t buffer_len);
 * %typemap(typecheck) (void *data, size_t length) = (const void* buffer_data, const size_t buffer_len);
 */

%typemap(in) (const void* buffer_data, const size_t buffer_len) {
  if ($input.IsBuffer()) {
    Napi::Buffer<char> buf = $input.As<Napi::Buffer<char>>();
    $1 = static_cast<$1_ltype>(buf.Data());
    $2 = buf.ByteLength();
  } else {
    SWIG_exception_fail(SWIG_TypeError, "in method '$symname', argument is not a Buffer");
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VOIDPTR) (const void* buffer_data, const size_t buffer_len) {
  $1 = $input.IsBuffer();
}


/**
 * New Buffer returned in arguments from the C++ side -> Buffer as return value from the JS side.
 *
 * In order to use the argout typemap, the function must have the following signature:
 *
 * void buffer(void **buffer_data, size_t *buffer_len)
 *
 * In this case, this function will be wrapped by a JS function that takes
 * no arguments (because of numinputs=0) and returns a Buffer.
 *
 * This typemap copies the data and does not free the original buffer.
 */

%typemap(in, numinputs=0) (void **buffer_data, size_t *buffer_len) ($*1_ltype temp_data, size_t temp_len) {
  $1 = &temp_data;
  $2 = &temp_len;
}
%typemap(argout) (void **buffer_data, size_t *buffer_len) {
  if (*$1 != SWIG_NULLPTR) {
    Napi::Buffer<char> buf = Napi::Buffer<char>::Copy(env, static_cast<char *>(*$1), *$2);
    NAPI_CHECK_RESULT(buf.As<Napi::Value>(), $result);
  } else {
    $result = env.Null();
  }
}
