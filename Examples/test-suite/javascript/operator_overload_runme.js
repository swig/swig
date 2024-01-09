var operator_overload = require("operator_overload");
var { Op } = operator_overload;

// first check all the operators are implemented correctly from pure C++ code
/* await */(Op.sanity_check());

var pop = /* await */((new Op(6)).Divide(new Op(3)));

// test routine
var a = new Op();
var b = new Op(5);
var c = new Op(b); // copy construct
var d = new Op(2);
var dd = new Op();
/* await */(dd.Equal(d)); // assignment operator

// test equality
if (! /* await */(a.NotEqual(b))) {
  throw new Error("a!=b");
}
if (! /* await */(b.EqualEqual(c))) {
  throw new Error("b==c");
}
if (! /* await */(a.NotEqual(d))) {
  throw new Error("a!=d");
}
if (! /* await */(d.EqualEqual(dd))) {
  throw new Error("d==dd");
}

// test <
if (! /* await */(a.LessThan(b))) {
  throw new Error("a<b");
}
if (! /* await */(a.LessThanEqual(b))) {
  throw new Error("a<=b");
}
if (! /* await */(b.LessThanEqual(c))) {
  throw new Error("b<=c");
}
if (! /* await */(b.GreaterThanEqual(c))) {
  throw new Error("b>=c");
}
if (! /* await */(b.GreaterThan(d))) {
  throw new Error("b>d");
}
if (! /* await */(b.GreaterThanEqual(d))) {
  throw new Error("b>=d");
}

// test +=
var e = new Op(3);
/* await */(e.PlusEqual(d));
if (! /* await */(e.EqualEqual(b))) {
  throw new Error(`e==b (${e.i}==${b.i})`);
}
/* await */(e.MinusEqual(c));
if (! /* await */(e.EqualEqual(a))) {
  throw new Error("e==a");
}
e = new Op(1);
/* await */(e.MultiplyEqual(b));
if (! /* await */(e.EqualEqual(c))) {
  throw new Error("e==c");
}
/* await */(e.DivideEqual(d));
if (! /* await */(e.EqualEqual(d))) {
  throw new Error("e==d");
}
/* await */(e.PercentEqual(c));
if (! /* await */(e.EqualEqual(d))) {
  throw new Error("e==d");
}

// test +
var f = new Op(1);
var g = new Op(1);
if (! /* await */((/* await */(f.Plus(g))).EqualEqual(new Op(2)))) {
  throw new Error("f+g==Op(2)");
}
if (! /* await */((/* await */(f.Minus(g))).EqualEqual(new Op(0)))) {
  throw new Error("f-g==Op(0)");
}
if (! /* await */((/* await */(f.Multiply(g))).EqualEqual(new Op(1)))) {
  throw new Error("f*g==Op(1)");
}
if (! /* await */((/* await */(f.Divide(g))).EqualEqual(new Op(1)))) {
  throw new Error("f/g==Op(1)");
}
if (! /* await */((/* await */(f.Percent(g))).EqualEqual(new Op(0)))) {
  throw new Error("f%g==Op(0)");
}

// test unary operators
if (! /* await */((/* await */(a.Minus())).EqualEqual(a))) {
  throw new Error("-a==a");
}
if (! /* await */((/* await */(b.Minus())).EqualEqual(new Op(-5)))) {
  throw new Error("-b==Op(-5)");
}

// test functors
if (! /* await */(b.Functor()) == 5) {
  throw new Error("functor");
}
if (! /* await */(b.Functor(1)) == 6) {
  throw new Error("functor");
}
if (! /* await */(b.Functor(1, 2)) == 8) {
  throw new Error("functor");
}
