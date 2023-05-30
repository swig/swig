var operator_overload = require("operator_overload");
var { Op } = operator_overload;

// first check all the operators are implemented correctly from pure C++ code
Op.sanity_check();

pop = (new Op(6)).Divide(new Op(3));

// test routine
a = new Op();
b = new Op(5);
c = new Op(b); // copy construct
d = new Op(2);
dd = new Op();
dd.Equal(d); // assignment operator

// test equality
if (!a.NotEqual(b)) {
  throw new Error("a!=b");
}
if (!b.EqualEqual(c)) {
  throw new Error("b==c");
}
if (!a.NotEqual(d)) {
  throw new Error("a!=d");
}
if (!d.EqualEqual(dd)) {
  throw new Error("d==dd");
}

// test <
if (!a.LessThan(b)) {
  throw new Error("a<b");
}
if (!a.LessThanEqual(b)) {
  throw new Error("a<=b");
}
if (!b.LessThanEqual(c)) {
  throw new Error("b<=c");
}
if (!b.GreaterThanEqual(c)) {
  throw new Error("b>=c");
}
if (!b.GreaterThan(d)) {
  throw new Error("b>d");
}
if (!b.GreaterThanEqual(d)) {
  throw new Error("b>=d");
}

// test +=
e = new Op(3);
e.PlusEqual(d);
if (!e.EqualEqual(b)) {
  throw new Error(`e==b (${e.i}==${b.i})`);
}
e.MinusEqual(c);
if (!e.EqualEqual(a)) {
  throw new Error("e==a");
}
e = new Op(1);
e.MultiplyEqual(b);
if (!e.EqualEqual(c)) {
  throw new Error("e==c");
}
e.DivideEqual(d);
if (!e.EqualEqual(d)) {
  throw new Error("e==d");
}
e.PercentEqual(c);
if (!e.EqualEqual(d)) {
  throw new Error("e==d");
}

// test +
f = new Op(1);
g = new Op(1);
if (!f.Plus(g).EqualEqual(new Op(2))) {
  throw new Error("f+g==Op(2)");
}
if (!f.Minus(g).EqualEqual(new Op(0))) {
  throw new Error("f-g==Op(0)");
}
if (!f.Multiply(g).EqualEqual(new Op(1))) {
  throw new Error("f*g==Op(1)");
}
if (!f.Divide(g).EqualEqual(new Op(1))) {
  throw new Error("f/g==Op(1)");
}
if (!f.Percent(g).EqualEqual(new Op(0))) {
  throw new Error("f%g==Op(0)");
}

// test unary operators
if (!a.Minus().EqualEqual(a)) {
  throw new Error("-a==a");
}
if (!b.Minus().EqualEqual(new Op(-5))) {
  throw new Error("-b==Op(-5)");
}

// test functors
if (!b.Functor() == 5) {
  throw new Error("functor");
}
if (!b.Functor(1) == 6) {
  throw new Error("functor");
}
if (!b.Functor(1, 2) == 8) {
  throw new Error("functor");
}
