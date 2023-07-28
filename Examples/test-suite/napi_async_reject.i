%module napi_async_reject

// This test is specific to Node-API
%feature("async", "Async");
%feature("sync", "Sync");

%typemap(check) int positive {
  if ($1 <= 0) SWIG_Throw_or_Reject(SWIG_ValueError, "must be positive");
}

%inline %{
  int fn(int positive) {
    return positive + 1;
  }
%}
