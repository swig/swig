module operator_overload_runme;

import operator_overload.Op;

void main() {
  // Invoke the C++ sanity check first.
  Op.sanity_check();

  auto a = new Op();
  auto b = new Op(5);
  auto c = b;
  auto d = new Op(2);
  auto dd = d;
  
  // test equality
  assert(a != b);
  assert(b == c);
  assert(a != d);
  assert(d == dd);
  
  // test <
  assert(a < b);
  assert(a <= b);
  assert(b <= c);
  assert(b >= c);
  assert(b > d);
  assert(b >= d);
  
  // test +=
  auto e = new Op(3);
  e += d;
  assert(e == b);
  e -= c;
  assert(e == a);
  e = new Op(1);
  e *= b;
  assert(e == c);
  e /= d;
  assert(e == d);
  e %= c;
  assert(e == d);
  
  // test +
  auto f = new Op(1);
  auto g = new Op(1);
  assert(f + g == new Op(2));
  assert(f - g == new Op(0));
  assert(f * g == new Op(1));
  assert(f / g == new Op(1));
  assert(f % g == new Op(0));
  
  // test unary operators
  assert(-a == a);
  assert(-b == new Op(-5));
  
  // Unfortunately, there is no way to override conversion to boolean for
  // classes in D, opCast!("bool") is only used for structs. 
  
  // test []
  auto h = new Op(3);
  assert(h[0]==3);
  assert(h[1]==0);
  // Generation of opIndexAssign is not supported yet.
  
  // test ()
  auto i = new Op(3);
  assert(i()==3);
  assert(i(1)==4);
  assert(i(1,2)==6);
  
  // test ++ and --
  auto j = new Op(100);
  int original = j.i;
  // The prefix increment/decrement operators are not directly overloadable in
  // D2, and because the proxy classes are reference types, the lowering
  // yields the same value as the postfix operators.
  {
    Op newOp = ++j;
    int newInt = ++original;
    assert(j.i == original);
    assert(newOp.i == newInt);
  }
  {
    Op newOp = --j;
    int newInt = --original;
    assert(j.i == original);
    assert(newOp.i == newInt);
  }
  
  // Implicit casting via alias this is not supported yet.
}