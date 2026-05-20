%module li_std_iadd

#if defined(SWIGPYTHON)

%inline %{
class Counter {
public:
  int val;
  Counter(int v = 0) : val(v) {}
  int get() const { return val; }
  Counter &operator+=(const Counter &o) { val += o.val; return *this; }
  Counter &operator-=(const Counter &o) { val -= o.val; return *this; }
  Counter &renamed_add_assign(const Counter &o) { val += o.val; return *this; }
};
%}

#endif
