var nspace = require("nspace");

var color1 = new nspace.Outer.Inner1.Color();
var color = new nspace.Outer.Inner1.Color(color1);

// class methods
/* await */(color.colorInstanceMethod(20.0));
/* await */(nspace.Outer.Inner1.Color.colorStaticMethod(20.0));
var created = /* await */(nspace.Outer.Inner1.Color.create());

// class enums
var someClass = new nspace.Outer.SomeClass();
var channel = /* await */(someClass.GetInner1ColorChannel());
if (channel != nspace.Outer.Inner1.Color.Transmission) {
  throw new Error("Failed.");
}

// class anonymous enums
var val1 = nspace.Outer.Inner1.Color.ColorEnumVal1;
var val2 = nspace.Outer.Inner1.Color.ColorEnumVal2;
if (val1 !== 0 || val2 !== 0x22) {
  throw new Error("Failed.");
}

// instance member variables
color.instanceMemberVariable = 123;
if (color.instanceMemberVariable !== 123) {
  throw new Error("Failed.");
}

// static member variables
nspace.Outer.Inner1.Color.staticMemberVariable = 789;
if (nspace.Outer.Inner1.Color.staticMemberVariable !== 789) {
  throw new Error("Failed.");
}

if (nspace.Outer.Inner1.Color.staticConstMemberVariable !== 222) {
  throw new Error("Failed.");
}

if (nspace.Outer.Inner1.Color.staticConstEnumMemberVariable !== nspace.Outer.Inner1.Color.Transmission) {
  throw new Error("Failed.");
}

// Same class different namespaces
var col1 = new nspace.Outer.Inner1.Color();
var col2 = /* await */(nspace.Outer.Inner2.Color.create());
/* await */(col2.colors(col1, col1, col2, col2, col2));

/* await */(nspace.Outer.Inner1.namespaceFunction(color));
nspace.Outer.Inner1.namespaceVar = 111;
if (nspace.Outer.Inner1.namespaceVar !== 111) {
  throw new Error("Failed.");
}

// global enums
var outerChannel1 = /* await */(someClass.GetInner1Channel());
if (outerChannel1 != nspace.Outer.Inner1.Transmission1) {
  throw new Error("Failed.");
}

var outerChannel2 = /* await */(someClass.GetInner2Channel());
if (outerChannel2 !== nspace.Outer.Inner2.Transmission2) {
  throw new Error("Failed.");
}

// turn feature off / ignoring
var ns = new nspace.Outer.namespce();
var nons = new nspace.NoNSpacePlease();

// Derived class
var blue3 = new nspace.Outer.Inner3.Blue();
/* await */(blue3.blueInstanceMethod());
var blue4 = new nspace.Outer.Inner4.Blue();
/* await */(blue4.blueInstanceMethod());
