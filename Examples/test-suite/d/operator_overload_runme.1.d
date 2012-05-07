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
  // The unary ! operator is not overloadable in D1.
  
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
  {
    Op newOp = j++;
    int newInt = original++;
    assert(j.i == original);
    assert(newOp.i == newInt);
  }
  {
    Op newOp = j--;
    int newInt = original--;
    assert(j.i == original);
    assert(newOp.i == newInt);
  }
  // Prefix increment/decrement operators are lowered to (foo +=/-= 1) in D1,
  // but the test case does not define an integer overload for operator +=
  // respectively -=.
  
  // Implicit casting is not overloadable in D1.
}