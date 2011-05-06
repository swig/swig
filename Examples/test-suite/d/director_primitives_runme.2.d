/**
 * This test program shows a D class DDerived inheriting from Base.
 *
 * Three types of classes are created and the virtual methods called to
 * demonstrate:
 *  - Wide variety of primitive types
 *  - Calling methods with zero, one or more parameters
 *  - Director methods that are not overridden in D
 *  - Director classes that are not overridden at all in D, i.e. non-director
 *    behaviour is as expected for director classes
 *  - Inheritance hierarchy using director methods
 *  - Return types working as well as parameters
 *
 * The Caller class is a tester class which calls the virtual functions from C++.
 */
module director_primitives_runme;

import std.exception;
import std.stdio;
import director_primitives.director_primitives;
import director_primitives.Base;
import director_primitives.Caller;
import director_primitives.Derived;
import director_primitives.HShadowMode;

void main() {
  PrintDebug = false;
  if (PrintDebug) writeln("------------ Start ------------ ");

  auto myCaller = new Caller();

  // Test C++ base class.
  {
    scope myBase = new Base(100.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) writeln("--------------------------------");

  // Test vanilla C++ wrapped derived class.
  {
    scope Base myBase = new Derived(100.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) writeln("--------------------------------");

  // Test director/D derived class.
  {
    scope Base myBase = new DDerived(300.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) writeln("------------ Finish ------------ ");
}

void makeCalls(Caller myCaller, Base myBase) {
  myCaller.set(myBase);

  myCaller.NoParmsMethodCall();
  enforce(myCaller.BoolMethodCall(true) == true, "failed");
  enforce(myCaller.BoolMethodCall(false) == false, "failed");
  enforce(myCaller.IntMethodCall(-123) == -123, "failed");
  enforce(myCaller.UIntMethodCall(123) == 123, "failed");
  enforce(myCaller.FloatMethodCall(-123.456f) == -123.456f, "failed");
  enforce(myCaller.CharPtrMethodCall("test string") == "test string", "failed");
  enforce(myCaller.ConstCharPtrMethodCall("another string") == "another string", "failed");
  enforce(myCaller.EnumMethodCall(HShadowMode.HShadowHard) == HShadowMode.HShadowHard, "failed");
  myCaller.ManyParmsMethodCall(true, -123, 123, 123.456f, "test string", "another string", HShadowMode.HShadowHard);
  myCaller.NotOverriddenMethodCall();

  myCaller.reset();
}

class DDerived : Base {
public:
  this(double dd) {
    super(dd);
  }

  override void NoParmsMethod() {
    if (PrintDebug) writeln("DDerived - NoParmsMethod()");
  }

  override bool BoolMethod(bool x) {
    if (PrintDebug) writefln("DDerived - BoolMethod(%s)", x);
    return x;
  }

  override int IntMethod(int x) {
    if (PrintDebug) writefln("DDerived - IntMethod(%s)", x);
    return x;
  }

  override uint UIntMethod(uint x) {
    if (PrintDebug) writefln("DDerived - UIntMethod(%s)", x);
    return x;
  }

  override float FloatMethod(float x) {
    if (PrintDebug) writefln("DDerived - FloatMethod(%s)", x);
    return x;
  }

  override string CharPtrMethod(string x) {
    if (PrintDebug) writefln("DDerived - CharPtrMethod(%s)", x);
    return x;
  }

  override string ConstCharPtrMethod(string x) {
    if (PrintDebug) writefln("DDerived - ConstCharPtrMethod(%s)", x);
    return x;
  }

  override HShadowMode EnumMethod(HShadowMode x) {
    if (PrintDebug) writefln("DDerived - EnumMethod(%s)", x);
    return x;
  }

  override void ManyParmsMethod(bool b, int i, uint u, float f, string c, string cc, HShadowMode h) {
    if (PrintDebug) writefln("DDerived - ManyParmsMethod(%s, %s, %s, %s, %s, %s, %s)", b, i, u, f, c, cc, h);
  }
}
