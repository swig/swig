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
 * DDerived - FullyOverloaded(bool True)
 * DDerived - SemiOverloaded(-678)
 * Base - SemiOverloaded(bool 1)
 * DDerived - DefaultParms(10, 2.2)
 * DDerived - DefaultParms(10, 1.1)
 * ------------ Finish ------------
 */
module director_classes_runme;

import tango.io.Stdout;
import tango.text.Util;
import director_classes.director_classes;
import director_classes.Caller;
import director_classes.Base;
import director_classes.Derived;
import director_classes.DoubleHolder;

void main() {
  if (PrintDebug) Stdout.formatln("------------ Start ------------");

  auto myCaller = new Caller();

  // Test C++ base class.
  {
    scope myBase = new Base(100.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) Stdout.formatln("--------------------------------");

  // Test vanilla C++ wrapped derived class.
  {
    scope myBase = new Derived(200.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) Stdout.formatln("--------------------------------");

  // Test director / D derived class.
  {
    scope myBase = new DDerived(300.0);
    makeCalls(myCaller, myBase);
  }

  if (PrintDebug) Stdout.formatln("------------ Finish ------------");
}

void makeCalls(Caller myCaller, Base myBase) {
  char[] myBaseType = myBase.classinfo.name.split(".")[$-1];
  myCaller.set(myBase);

  DoubleHolder dh = new DoubleHolder(444.555);

  // Class pointer, reference and pass by value tests
  if (myCaller.ValCall(dh).val != dh.val) throw new Exception("[1] failed");
  if (myCaller.RefCall(dh).val != dh.val) throw new Exception("[2] failed");
  if (myCaller.PtrCall(dh).val != dh.val) throw new Exception("[3] failed");
  if (myCaller.ConstPtrRefCall(dh).val != dh.val) throw new Exception("[3] failed");

  // Fully overloaded method test (all methods in base class are overloaded)
  if (myCaller.FullyOverloadedCall(10) != myBaseType ~ "::FullyOverloaded(int)") throw new Exception("[4] failed");
  if (myCaller.FullyOverloadedCall(true) != myBaseType ~ "::FullyOverloaded(bool)") throw new Exception("[5] failed");

  // Semi overloaded method test (some methods in base class are overloaded)
  if (myCaller.SemiOverloadedCall(-678) != myBaseType ~ "::SemiOverloaded(int)") throw new Exception("[6] failed");
  if (myCaller.SemiOverloadedCall(true) != "Base" ~ "::SemiOverloaded(bool)") throw new Exception("[7] failed");

  // Default parameters methods test
  if (myCaller.DefaultParmsCall(10, 2.2) != myBaseType ~ "::DefaultParms(int, double)") throw new Exception("[8] failed");
  if (myBase.classinfo == DDerived.classinfo) { // special handling for D derived classes, there is no way to do this any other way
    if (myCaller.DefaultParmsCall(10) != myBaseType ~ "::DefaultParms(int, double)") throw new Exception("[9] failed");
  } else {
    if (myCaller.DefaultParmsCall(10) != myBaseType ~ "::DefaultParms(int)") throw new Exception("[10] failed");
  }

  myCaller.reset();
}

public class DDerived : Base {
  public this(double dd) {
    super(dd);
  }

  public override DoubleHolder Val(DoubleHolder x) {
    if (PrintDebug) Stdout.formatln("DDerived - Val({0:d3})", x.val);
    return x;
  }

  public override DoubleHolder Ref(DoubleHolder x) {
    if (PrintDebug) Stdout.formatln("DDerived - Ref({0:d3})", x.val);
    return x;
  }

  public override DoubleHolder Ptr(DoubleHolder x) {
    if (PrintDebug) Stdout.formatln("DDerived - Ptr({0:d3})", x.val);
    return x;
  }

  public override DoubleHolder ConstPtrRef(DoubleHolder x) {
    if (PrintDebug) Stdout.formatln("DDerived - ConstPtrRef({0:d3})", x.val);
    return x;
  }

  public override char[] FullyOverloaded(int x) {
    if (PrintDebug) Stdout.formatln("DDerived - FullyOverloaded(int {0})", x);
    return "DDerived::FullyOverloaded(int)";
  }

  public override char[] FullyOverloaded(bool x) {
    if (PrintDebug) Stdout.formatln("DDerived - FullyOverloaded(bool {0})", x);
    return "DDerived::FullyOverloaded(bool)";
  }

  public override char[] SemiOverloaded(int x) {
    char[] ret = "DDerived::SemiOverloaded(int)";
    if (PrintDebug) Stdout.formatln("DDerived - SemiOverloaded({0})", x);
    return ret;
  }
  alias Base.SemiOverloaded SemiOverloaded; // Alias in SemiOverloaded(bool x).

  public override char[] DefaultParms(int x, double y) {
    char[] ret = "DDerived::DefaultParms(int, double)";
    if (PrintDebug) Stdout.formatln("DDerived - DefaultParms({0}, {1:d1})", x, y);
    return ret;
  }
  // This method will never be called from C++ code because the two-parameter
  // DefaultParams() has a default value for the second parameter there. It is
  // only here to ensure consistent behavior for calls from C++ and D code.
  public override char[] DefaultParms(int x) {
    if (PrintDebug) Stdout.formatln("DDerived - DefaultParms({0})", x);
    return DefaultParms(x, 1.1/*use C++ default here*/);
  }
}
