%module napi_async_locking

%typemap(async_pre) UnlockedInteger, UnlockedInteger &, UnlockedInteger * "";
%typemap(async_post) UnlockedInteger, UnlockedInteger &, UnlockedInteger * "";

%inline %{
struct Integer {
  int val;

  Integer(int v) : val(v) {}

  void compute(const Integer &b) {
    // The result of this operation should be val
    for (int i = 0; i < 1000; i++) {
      val += b.val;
      val *= 2;
      val -= b.val;
      val -= b.val;
      val /= 2;
    }
  }
};

struct UnlockedInteger {
  int val;

  UnlockedInteger(int v) : val(v) {}

  void compute(const UnlockedInteger &b) {
    // The result of this operation should be val
    for (int i = 0; i < 1000; i++) {
      val += b.val;
      val *= 2;
      val -= b.val;
      val -= b.val;
      val /= 2;
    }
  }
};
%}
