var nspacemove = require("nspacemove");

var color1 = new nspacemove.Ooter.Extra.Inner1.Color();
var color = new nspacemove.Ooter.Extra.Inner1.Color(color1);
delete color1;

// class methods
color.colorInstanceMethod(20.0);
nspacemove.Ooter.Extra.Inner1.Color.colorStaticMethod(20.0);
var created = nspacemove.Ooter.Extra.Inner1.Color.create();

// class enums
var someClass = new nspacemove.Outer.SomeClass();
var channel = someClass.GetInner1ColorChannel();
if (channel != nspacemove.Ooter.Extra.Inner1.Color.Transmission) {
  throw new Error("Failed.");
}

// class anonymous enums
var val1 = nspacemove.Ooter.Extra.Inner1.Color.ColorEnumVal1;
var val2 = nspacemove.Ooter.Extra.Inner1.Color.ColorEnumVal2;
if (val1 !== 0 || val2 !== 0x22) {
  throw new Error("Failed.");
}

// instance member variables
color.instanceMemberVariable = 123;
if (color.instanceMemberVariable !== 123) {
  throw new Error("Failed.");
}

// static member variables
nspacemove.Ooter.Extra.Inner1.Color.staticMemberVariable = 789;
if (nspacemove.Ooter.Extra.Inner1.Color.staticMemberVariable !== 789) {
  throw new Error("Failed.");
}

if (nspacemove.Ooter.Extra.Inner1.Color.staticConstMemberVariable !== 222) {
  throw new Error("Failed.");
}

if (nspacemove.Ooter.Extra.Inner1.Color.staticConstEnumMemberVariable !== nspacemove.Ooter.Extra.Inner1.Color.Transmission) {
  throw new Error("Failed.");
}

// Same class different namespaces
var col1 = new nspacemove.Ooter.Extra.Inner1.Color();
var col2 = nspacemove.Outer.Snner2.Color.create();
col2.colors(col1, col1, col2, col2, col2);

nspacemove.Outer.Inner1.namespaceFunction(color);
nspacemove.Outer.Inner1.namespaceVar = 111;
if (nspacemove.Outer.Inner1.namespaceVar !== 111) {
  throw new Error("Failed.");
}

// global enums
var outerChannel1 = someClass.GetInner1Channel();
// TODO, broken:
if (outerChannel1 != nspacemove.Outer.Inner1.Transmission1) {
  throw new Error("Failed.");
}

var outerChannel2 = someClass.GetInner2Channel();
// TODO, broken:
if (outerChannel2 !== nspacemove.Outer.Inner2.Transmission2) {
  throw new Error("Failed.");
}

// TODO, broken
nspacemove.takeGlobalEnum(nspacemove.bbb);

// global class
var gc = new nspacemove.Additional.GlobalClass();
gc.gmethod();

// turn feature off / ignoring
var ns = new nspacemove.Outer.namespce();
var nons = new nspacemove.NoNSpacePlease();

// Derived class
var blue3 = new nspacemove.Outer.Inner3.Blue();
blue3.blueInstanceMethod();
var blue4 = new nspacemove.Outer.Inner4.Blue();
blue4.blueInstanceMethod();
