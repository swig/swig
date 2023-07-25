%module napi_async_locking

%typemap(lock) UnlockedInteger, UnlockedInteger &, UnlockedInteger * "";

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
};

struct UnlockedInteger {
  int val;

  UnlockedInteger(int v) : val(v) {}

  void compute(UnlockedInteger &b) {
    ::compute(val, b.val);
  }
};
%}
