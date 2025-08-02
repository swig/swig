class X {
  int val;
public:

  X(int val = 0) : val(val) {}
  int xmethod(int a) {
    return -a;
  }
  int call_xmethod(int a) {
    return xmethod(a);
  }
};

extern "C" int go_for_it_x(int a, X x, int (X::*pf)(int a)) {
  return (x.*pf)(a) + 11;
}
