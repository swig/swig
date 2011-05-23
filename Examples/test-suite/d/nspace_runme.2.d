module nspace_runme;

import std.exception;
import nspace.nspace;
static import nspace.NoNSpacePlease;
static import nspace.Outer.namespce;
static import nspace.Outer.Inner1.Channel;
static import oi1c = nspace.Outer.Inner1.Color;
static import nspace.Outer.Inner2.Channel;
static import nspace.Outer.Inner2.Color;
static import nspace.Outer.Inner3.Blue;
static import nspace.Outer.Inner4.Blue;
static import nspace.Outer.SomeClass;

void main() {
  // constructors and destructors
  auto color1 = new oi1c.Color();
  auto color = new oi1c.Color(color1);

  // class methods
  color.colorInstanceMethod(20.0);
  oi1c.Color.colorStaticMethod(20.0);
  auto created = oi1c.Color.create();

  // class enums
  auto someClass = new nspace.Outer.SomeClass.SomeClass();
  auto channel = someClass.GetInner1ColorChannel();
  enforce(channel == oi1c.Color.Channel.Transmission,
    "Transmission wrong");

  // class anonymous enums
  int val1 = oi1c.Color.ColorEnumVal1;
  int val2 = oi1c.Color.ColorEnumVal2;
  enforce(val1 == 0 && val2 == 0x22, "ColorEnumVal wrong");

  // instance member variables
  color.instanceMemberVariable = 123;
  enforce(color.instanceMemberVariable == 123,
    "instance member variable failed");

  // static member variables
  oi1c.Color.staticMemberVariable = 789;
  enforce(oi1c.Color.staticMemberVariable == 789,
    "static member variable failed");
  enforce(oi1c.Color.staticConstMemberVariable == 222,
    "static const member variable failed");
  enforce(oi1c.Color.staticConstEnumMemberVariable == oi1c.Color.Channel.Transmission,
    "static const enum member variable failed");

  // check globals in a namespace don't get mangled with the nspace option
  nspace.nspace.namespaceFunction(color);
  nspace.nspace.namespaceVar = 111;
  enforce(nspace.nspace.namespaceVar == 111, "global var failed");

  // Same class different namespaces
  auto col1 = new oi1c.Color();
  auto col2 = nspace.Outer.Inner2.Color.Color.create();
  col2.colors(col1, col1, col2, col2, col2);

  // global enums
  auto outerChannel1 = someClass.GetInner1Channel();
  enforce(outerChannel1 == nspace.Outer.Inner1.Channel.Channel.Transmission1,
      "Transmission1 wrong");
  auto outerChannel2 = someClass.GetInner2Channel();
  enforce(outerChannel2 == nspace.Outer.Inner2.Channel.Channel.Transmission2,
      "Transmission2 wrong");

  // turn feature off / ignoring
  auto ns = new nspace.Outer.namespce.namespce();
  auto nons = new nspace.NoNSpacePlease.NoNSpacePlease();

  // Derived class
  auto blue3 = new nspace.Outer.Inner3.Blue.Blue();
  blue3.blueInstanceMethod();
  auto blue4 = new nspace.Outer.Inner4.Blue.Blue();
  blue4.blueInstanceMethod();
}
