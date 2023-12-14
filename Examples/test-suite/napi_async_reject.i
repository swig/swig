%module napi_async_reject


// This test is specific to Node-API
%feature("async", "Async");
%feature("sync", "Sync");

%typemap(check) int positive {
  if ($1 <= 0) SWIG_exception_fail(SWIG_ValueError, "must be positive");
}

%catches(CustomError) throws;
%immutable;

%inline %{
  struct CustomError {
    const char *msg;
    CustomError(const char *_msg): msg(_msg) {};
  };

  int fn(int positive) {
    return positive + 1;
  }

  void throws() {
    throw CustomError("expected error");
  }
%}
