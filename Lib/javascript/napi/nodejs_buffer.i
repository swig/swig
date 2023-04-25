/*
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
    $1 = reinterpret_cast<void *>(buf.Data());
    $2 = buf.ByteLength();
  } else {
    SWIG_exception_fail(SWIG_TypeError, "in method '$symname', argument is not a Buffer");
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_VOIDPTR) (const void* buffer_data, const size_t buffer_len) {
  $1 = $input.IsBuffer();
}

%typemap(argout) (const void* buffer_data, const size_t buffer_len) {
  if ($1 != nullptr) {
    $result = Napi::Buffer<char>::New(env, reinterpret_cast<char *>($1), $2);
  } else {
    $result = env.Null();
  }
}
