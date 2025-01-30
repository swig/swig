%module napi_async_locking

// This test is specific to Node-API
%feature("async", "Async");
%feature("sync", "Sync");
%feature("async:locking", "1");
%feature("async:locking", "0") Integer::computeUnlocked;
%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE) Integer::computeUnlocked;

%apply SWIGTYPE LOCK  {Integer};
%apply SWIGTYPE *LOCK {Integer *};
%apply SWIGTYPE &LOCK {Integer &};

%{
void inline compute(int &a, const int b) {
  char buf[16];

  // The result of this operation should be a
  for (int i = 0; i < 1000; i++) {
    a += b;
    a *= 2;
    a -= b;
    // break the static expression optimization
    sprintf(buf, "%d", a);
    a -= b;
    a /= 2;
  }
}
%}

%inline %{
struct Integer {
  int val;

  Integer(int v) : val(v) {}

  void compute(Integer &b) {
    ::compute(val, b.val);
  }

  void computeUnlocked(Integer &b) {
    ::compute(val, b.val);
  }
};
%}
