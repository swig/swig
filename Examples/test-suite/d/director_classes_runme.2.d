/**
 * This test demonstrates director classes when the types are classes. Shown are
 * virtual function calls which use classes passed by
 *  - Value
 *  - Reference
 *  - Pointer
 * as both parameters and return values
 *
 * The test also demonstrates directors used with:
 *  - method overloading
 *  - default parameters
 *
 * Note: Methods with default parameters that call up from C++ cannot call the
 * overloaded D methods, see DefaultParms method.

 * Expected output if PrintDebug enabled:
 * ------------ Start ------------
 * Base - Val(444.555)
 * Base - Ref(444.555)
 * Base - Ptr(444.555)
 * Base - ConstPtrRef(444.555)
 * Base - FullyOverloaded(int 10)
 * Base - FullyOverloaded(bool 1)
 * Base - SemiOverloaded(int -678)
 * Base - SemiOverloaded(bool 1)
 * Base - DefaultParms(10, 2.2)
 * Base - DefaultParms(10, 1.1)
 * --------------------------------
 * Derived - Val(444.555)
 * Derived - Ref(444.555)
 * Derived - Ptr(444.555)
 * Derived - ConstPtrRef(444.555)
 * Derived - FullyOverloaded(int 10)
 * Derived - FullyOverloaded(bool 1)
 * Derived - SemiOverloaded(int -678)
 * Base - SemiOverloaded(bool 1)
 * Derived - DefaultParms(10, 2.2)
 * Derived - DefaultParms(10, 1.1)
 * --------------------------------
 * DDerived - Val(444.555)
 * DDerived - Ref(444.555)
 * DDerived - Ptr(444.555)
 * DDerived - ConstPtrRef(444.555)
 * DDerived - FullyOverloaded(int 10)
 * DDerived - FullyOverloaded(bool true)
 * DDerived - SemiOverloaded(-678)
 * Base - SemiOverloaded(bool 1)
 * DDerived - DefaultParms(10, 2.2)
 * DDerived - DefaultParms(10, 1.1)
 * ------------ Finish ------------
 */
module director_classes_runme;

import std.exception;
import std.stdio;
import std.string;
import director_classes.director_classes;
import director_classes.Caller;
import director_classes.Base;
import director_classes.Derived;
import director_classes.DoubleHolder;

void main() {
  if (PrintDebug) writeln("------------ Start ------------");

  auto myCaller = new Caller();

  // Test C++ base class.
  {
    scope myBase = new Base(100.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) writeln("--------------------------------");

  // Test vanilla C++ wrapped derived class.
  {
    scope myBase = new Derived(200.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) writeln("--------------------------------");

  // Test director / D derived class.
  {
    scope myBase = new DDerived(300.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) writeln("------------ Finish ------------");
}

void makeCalls(Caller myCaller, Base myBase) {
  string myBaseType = myBase.classinfo.name.split(".")[$-1];
  myCaller.set(myBase);

  DoubleHolder dh = new DoubleHolder(444.555);

  // Class pointer, reference and pass by value tests
  enforce(myCaller.ValCall(dh).val == dh.val, "[1] failed");
  enforce(myCaller.RefCall(dh).val == dh.val, "[2] failed");
  enforce(myCaller.PtrCall(dh).val == dh.val, "[3] failed");
  enforce(myCaller.ConstPtrRefCall(dh).val == dh.val, "[3] failed");

  // Fully overloaded method test (all methods in base class are overloaded)
  enforce(myCaller.FullyOverloadedCall(10) == myBaseType ~ "::FullyOverloaded(int)", "[4] failed");
  enforce(myCaller.FullyOverloadedCall(true) == myBaseType ~ "::FullyOverloaded(bool)", "[5] failed");

  // Semi overloaded method test (some methods in base class are overloaded)
  enforce(myCaller.SemiOverloadedCall(-678) == myBaseType ~ "::SemiOverloaded(int)", "[6] failed");
  enforce(myCaller.SemiOverloadedCall(true) == "Base" ~ "::SemiOverloaded(bool)", "[7] failed");

  // Default parameters methods test
  enforce(myCaller.DefaultParmsCall(10, 2.2) == myBaseType ~ "::DefaultParms(int, double)", "[8] failed");
  if (myBase.classinfo == DDerived.classinfo) { // special handling for D derived classes, there is no other way to do this
    enforce(myCaller.DefaultParmsCall(10) == myBaseType ~ "::DefaultParms(int, double)", "[9] failed");
  } else {
    enforce(myCaller.DefaultParmsCall(10) == myBaseType ~ "::DefaultParms(int)", "[10] failed");
  }

  myCaller.reset();
}

public class DDerived : Base {
  public this(double dd) {
    super(dd);
  }

  public override DoubleHolder Val(DoubleHolder x) {
    if (PrintDebug) writefln("DDerived - Val(%s)", x.val);
    return x;
  }

  public override DoubleHolder Ref(DoubleHolder x) {
    if (PrintDebug) writefln("DDerived - Ref(%s)", x.val);
    return x;
  }

  public override DoubleHolder Ptr(DoubleHolder x) {
    if (PrintDebug) writefln("DDerived - Ptr(%s)", x.val);
    return x;
  }

  public override DoubleHolder ConstPtrRef(DoubleHolder x) {
    if (PrintDebug) writefln("DDerived - ConstPtrRef(%s)", x.val);
    return x;
  }

  public override string FullyOverloaded(int x) {
    if (PrintDebug) writefln("DDerived - FullyOverloaded(int %s)", x);
    return "DDerived::FullyOverloaded(int)";
  }

  public override string FullyOverloaded(bool x) {
    if (PrintDebug) writefln("DDerived - FullyOverloaded(bool %s)", x);
    return "DDerived::FullyOverloaded(bool)";
  }

  public override string SemiOverloaded(int x) {
    string ret = "DDerived::SemiOverloaded(int)";
    if (PrintDebug) writefln("DDerived - SemiOverloaded(%s)", x);
    return ret;
  }
  alias Base.SemiOverloaded SemiOverloaded; // Alias in SemiOverloaded(bool x).

  public override string DefaultParms(int x, double y) {
    string ret = "DDerived::DefaultParms(int, double)";
    if (PrintDebug) writefln("DDerived - DefaultParms(%s, %s)", x, y);
    return ret;
  }
  // This method will never be called from C++ code because the two-parameter
  // DefaultParams() has a default value for the second parameter there. It is
  // only here to ensure consistent behavior for calls from C++ and D code.
  public override string DefaultParms(int x) {
    if (PrintDebug) writefln("DDerived - DefaultParms(%s)", x);
    return DefaultParms(x, 1.1/*use C++ default here*/);
  }
}
