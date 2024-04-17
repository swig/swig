%module napi_async_reject

// This test is specific to Node-API
%feature("async", "Async");
%feature("sync", "Sync");

%typemap(check) int positive {
  if ($1 <= 0) SWIG_exception_fail(SWIG_ValueError, "must be positive");
}

// https://github.com/mmomtchev/swig/issues/52
// Guard against double free
%feature("async", "0") FreeCounter::reset;
%feature("sync", "1") FreeCounter::reset;
%typemap(freearg) FreeCounter &dummy {
  $1->freearg_calls++;
}

%catches(CustomError) throws;
%immutable;

%inline %{
  struct CustomError {
    const char *msg;
    CustomError(const char *_msg): msg(_msg) {};
  };

  struct FreeCounter {
    int freearg_calls;
    FreeCounter() : freearg_calls(0) {}
    void reset() { freearg_calls = 0; }
  };

  int fn(int positive, FreeCounter &dummy) {
    return positive + 1;
  }

  void throws() {
    throw CustomError("expected error");
  }
%}
