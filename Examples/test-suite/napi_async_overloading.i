%module napi_async_overloading

// This test is specific to Node-API
%feature("async", "Async");
%feature("sync", "Sync");
%feature("sync", "1") global_overload_2;
%feature("sync", "1") Klass::overload_2;

%inline %{
int global_overload_1(int a) {
  return a + 2;
}
const char *global_overload_1(const char *a) {
  return a;
}


int global_overload_2(int a) {
  return a + 2;
}
const char *global_overload_2(const char *a) {
  return a;
}

struct Klass {
  int overload_1(int a) {
    return a + 2;
  }
  const char *overload_1(const char *a) {
    return a;
  }

  int overload_2(int a) {
    return a + 2;
  }
  const char *overload_2(const char *a) {
    return a;
  }
};
%}
