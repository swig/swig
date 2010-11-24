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

import tango.io.Stdout;
import director_primitives.director_primitives;
import director_primitives.Base;
import director_primitives.Caller;
import director_primitives.Derived;
import director_primitives.HShadowMode;

void main() {
  PrintDebug = false;
  if (PrintDebug) Stdout("------------ Start ------------ ").newline;

  Caller myCaller = new Caller();

  // Test C++ base class.
  {
    scope myBase = new Base(100.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) Stdout("--------------------------------").newline;

  // Test vanilla C++ wrapped derived class.
  {
    scope Base myBase = new Derived(100.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) Stdout("--------------------------------").newline;

  // Test director/D derived class.
  {
    scope Base myBase = new DDerived(300.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) Stdout("------------ Finish ------------ ").newline;
}

void makeCalls(Caller myCaller, Base myBase) {
  myCaller.set(myBase);

  myCaller.NoParmsMethodCall();
  if (myCaller.BoolMethodCall(true) != true) throw new Exception("failed");
  if (myCaller.BoolMethodCall(false) != false) throw new Exception("failed");
  if (myCaller.IntMethodCall(-123) != -123) throw new Exception("failed");
  if (myCaller.UIntMethodCall(123) != 123) throw new Exception("failed");
  if (myCaller.FloatMethodCall(-123.456f) != -123.456f) throw new Exception("failed");
  if (myCaller.CharPtrMethodCall("test string") != "test string") throw new Exception("failed");
  if (myCaller.ConstCharPtrMethodCall("another string") != "another string") throw new Exception("failed");
  if (myCaller.EnumMethodCall(HShadowMode.HShadowHard) != HShadowMode.HShadowHard) throw new Exception("failed");
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
    if (PrintDebug) Stdout("DDerived - NoParmsMethod()").newline;
  }

  override bool BoolMethod(bool x) {
    if (PrintDebug) Stdout.formatln("DDerived - BoolMethod({0})", x);
    return x;
  }

  override int IntMethod(int x) {
    if (PrintDebug) Stdout.formatln("DDerived - IntMethod({0})", x);
    return x;
  }

  override uint UIntMethod(uint x) {
    if (PrintDebug) Stdout.formatln("DDerived - UIntMethod({0})", x);
    return x;
  }

  override float FloatMethod(float x) {
    if (PrintDebug) Stdout.formatln("DDerived - FloatMethod({0})", x);
    return x;
  }

  override char[] CharPtrMethod(char[] x) {
    if (PrintDebug) Stdout.formatln("DDerived - CharPtrMethod({0})", x);
    return x;
  }

  override char[] ConstCharPtrMethod(char[] x) {
    if (PrintDebug) Stdout.formatln("DDerived - ConstCharPtrMethod({0})", x);
    return x;
  }

  override HShadowMode EnumMethod(HShadowMode x) {
    if (PrintDebug) Stdout.formatln("DDerived - EnumMethod({0})", x);
    return x;
  }

  override void ManyParmsMethod(bool b, int i, uint u, float f, char[] c, char[] cc, HShadowMode h) {
    if (PrintDebug) Stdout.formatln("DDerived - ManyParmsMethod({0}, {1}, {2}, {3:d3}, {4}, {5}, {6})", b, i, u, f, c, cc, h);
  }
}
