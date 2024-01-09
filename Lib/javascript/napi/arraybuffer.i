/*
 * To include generic versions of the in typemaps, add:
 *
 * %typemap(in)        (void *, size_t) = (const void* arraybuffer_data, const size_t arraybuffer_len);
 * %typemap(typecheck) (void *, size_t) = (const void* arraybuffer_data, const size_t arraybuffer_len);
 *
 * or to discriminate by argument names:
 * %typemap(in)        (void *data, size_t length) = (const void* arraybuffer_data, const size_t arraybuffer_len);
 * %typemap(typecheck) (void *data, size_t length) = (const void* arraybuffer_data, const size_t arraybuffer_len);
 */

%typemap(in) (const void *arraybuffer_data, const size_t arraybuffer_len) {
  if ($input.IsArrayBuffer()) {
    Napi::ArrayBuffer buf = $input.As<Napi::ArrayBuffer>();
    $1 = reinterpret_cast<void *>(buf.Data());
    $2 = buf.ByteLength();
  } else {
    SWIG_exception_fail(SWIG_TypeError, "in method '$symname', argument is not a Buffer");
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VOIDPTR) (const void* arraybuffer_data, const size_t arraybuffer_len) {
  $1 = $input.IsArrayBuffer();
}


/*
 * In order to use the argout typemap, the function must have the following signature:
 *
 * void buffer(void **arraybuffer_data, size_t *arraybuffer_len)
 *
 * In this case, this function will be wrapped by a JS function that takes
 * no arguments (because of numinputs=0) and returns a Buffer
 */

%typemap(in, numinputs=0) (void **arraybuffer_data, size_t *arraybuffer_len) (void *temp_data, size_t temp_len) {
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
