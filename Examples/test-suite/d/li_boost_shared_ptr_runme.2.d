module li_boost_shared_ptr_runme;

import core.memory;
import core.thread;
import core.time;
import std.conv;
import std.exception;
import std.stdio;
import li_boost_shared_ptr.li_boost_shared_ptr;
import li_boost_shared_ptr.Klass;
import li_boost_shared_ptr.KlassDerived;
import li_boost_shared_ptr.Klass3rdDerived;
import li_boost_shared_ptr.MemberVariables;
import li_boost_shared_ptr.PairIntDouble;

// Debugging flag
enum TRACE = false;

void main() {
  if (TRACE)
    writeln("---> STARTED <---");

  debug_shared = TRACE;

  // Change loop count to run for a long time to monitor memory
  enum LOOP_COUNT = 1; // 50000;
  for (int i = 0; i < LOOP_COUNT; ++i) {
    runTest();
    GC.collect();
  }

  if (TRACE)
    writeln("---> NEARLY FINISHED <---");

  // A single remaining instance expected: the global variable (GlobalValue).
  if (Klass.getTotal_count() != 1)
    throw new Exception("Klass.total_count=" ~ to!string(Klass.getTotal_count()));

  // A single remaining instance expected: the global variable (GlobalSmartValue).
  int wrapper_count = shared_ptr_wrapper_count();
  if (wrapper_count != NOT_COUNTING)
    if (wrapper_count != 1)
      throw new Exception("shared_ptr wrapper count=" ~ to!string(wrapper_count));

  if (TRACE)
    writeln("---> FINISHED <---");
}

void runTest() {
  // We want to check whether all the C++ Klass instances have been properly
  // destructed after the tests have run. However, as it is legal for the GC
  // to leave an object around even if it is unreachable, use deterministic
  // memory management here.
  import std.typecons : scoped;

  // simple shared_ptr usage - created in C++
  {
    auto k = scoped!Klass("me oh my");
    string val = k.getValue();
    verifyValue("me oh my", val);
    verifyCount(1, k);
  }

  // simple shared_ptr usage - not created in C++
  {
    auto k = factorycreate();
    string val = k.getValue();
    verifyValue("factorycreate", val);
    verifyCount(1, k);
  }

  // pass by shared_ptr
  {
    auto k = scoped!Klass("me oh my");
    auto kret = smartpointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my smartpointertest", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // pass by shared_ptr pointer
  {
    auto k = scoped!Klass("me oh my");
    auto kret = smartpointerpointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my smartpointerpointertest", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // pass by shared_ptr reference
  {
    auto k = scoped!Klass("me oh my");
    auto kret = smartpointerreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my smartpointerreftest", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // pass by shared_ptr pointer reference
  {
    auto k = scoped!Klass("me oh my");
    auto kret = smartpointerpointerreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my smartpointerpointerreftest", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // const pass by shared_ptr
  {
    auto k = scoped!Klass("me oh my");
    auto kret = constsmartpointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // const pass by shared_ptr pointer
  {
    auto k = scoped!Klass("me oh my");
    auto kret = constsmartpointerpointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // const pass by shared_ptr reference
  {
    auto k = scoped!Klass("me oh my");
    auto kret = constsmartpointerreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // pass by value
  {
    auto k = scoped!Klass("me oh my");
    auto kret = valuetest(k);
    string val = kret.getValue();
    verifyValue("me oh my valuetest", val);
    verifyCount(1, k);
    verifyCount(1, kret);
  }

  // pass by pointer
  {
    auto k = scoped!Klass("me oh my");
    auto kret = pointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my pointertest", val);
    verifyCount(1, k);
    verifyCount(1, kret);
  }

  // pass by reference
  {
    auto k = scoped!Klass("me oh my");
    auto kret = reftest(k);
    string val = kret.getValue();
    verifyValue("me oh my reftest", val);
    verifyCount(1, k);
    verifyCount(1, kret);
  }

  // pass by pointer reference
  {
    auto k = scoped!Klass("me oh my");
    auto kret = pointerreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my pointerreftest", val);
    verifyCount(1, k);
    verifyCount(1, kret);
  }

  // null tests
  {
    Klass k = null;

    // TODO: add in const versions too
    enforce(smartpointertest(k) is null, "return was not null");
    enforce(smartpointerpointertest(k) is null, "return was not null");
    enforce(smartpointerreftest(k) is null, "return was not null");
    enforce(smartpointerpointerreftest(k) is null, "return was not null");
    enforce(nullsmartpointerpointertest(null) == "null pointer",
      "not null smartpointer pointer");

    enforceThrows( (){ valuetest(k); }, "Failed to catch null pointer");
    enforce(pointertest(k) is null, "return was not null");
    enforceThrows( (){ reftest(k); }, "Failed to catch null pointer");
  }

  // $owner
  {
    auto k = pointerownertest();
    string val = k.getValue();
    verifyValue("pointerownertest", val);
    verifyCount(1, k);
  }
  {
    auto k = smartpointerpointerownertest();
    string val = k.getValue();
    verifyValue("smartpointerpointerownertest", val);
    verifyCount(1, k);
  }

  ////////////////////////////////// Derived classes ////////////////////////////////////////
  // derived pass by shared_ptr
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = derivedsmartptrtest(k);
    string val = kret.getValue();
    verifyValue("me oh my derivedsmartptrtest-Derived", val);
    verifyCount(4, k); // includes two extra references for upcasts in the proxy classes
    verifyCount(4, kret);
  }
  // derived pass by shared_ptr pointer
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = derivedsmartptrpointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my derivedsmartptrpointertest-Derived", val);
    verifyCount(4, k); // includes two extra references for upcasts in the proxy classes
    verifyCount(4, kret);
  }
  // derived pass by shared_ptr ref
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = derivedsmartptrreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my derivedsmartptrreftest-Derived", val);
    verifyCount(4, k); // includes two extra references for upcasts in the proxy classes
    verifyCount(4, kret);
  }
  // derived pass by shared_ptr pointer ref
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = derivedsmartptrpointerreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my derivedsmartptrpointerreftest-Derived", val);
    verifyCount(4, k); // includes two extra references for upcasts in the proxy classes
    verifyCount(4, kret);
  }
  // derived pass by pointer
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = derivedpointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my derivedpointertest-Derived", val);
    verifyCount(2, k); // includes an extra reference for the upcast in the proxy class
    verifyCount(2, kret);
  }
  // derived pass by ref
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = derivedreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my derivedreftest-Derived", val);
    verifyCount(2, k); // includes an extra reference for the upcast in the proxy class
    verifyCount(2, kret);
  }

  ////////////////////////////////// Derived and base class mixed ////////////////////////////////////////
  // pass by shared_ptr (mixed)
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = smartpointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my smartpointertest-Derived", val);
    verifyCount(3, k); // an extra reference for the upcast in the proxy class
    verifyCount(3, kret);
  }

  // pass by shared_ptr pointer (mixed)
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = smartpointerpointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my smartpointerpointertest-Derived", val);
    verifyCount(3, k); // an extra reference for the upcast in the proxy class
    verifyCount(3, kret);
  }

  // pass by shared_ptr reference (mixed)
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = smartpointerreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my smartpointerreftest-Derived", val);
    verifyCount(3, k); // an extra reference for the upcast in the proxy class
    verifyCount(3, kret);
  }

  // pass by shared_ptr pointer reference (mixed)
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = smartpointerpointerreftest(k);
    string val = kret.getValue();
    verifyValue("me oh my smartpointerpointerreftest-Derived", val);
    verifyCount(3, k); // an extra reference for the upcast in the proxy class
    verifyCount(3, kret);
  }

  // pass by value (mixed)
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = valuetest(k);
    string val = kret.getValue();
    verifyValue("me oh my valuetest", val); // note slicing
    verifyCount(2, k); // an extra reference for the upcast in the proxy class
    verifyCount(1, kret);
  }

  // pass by pointer (mixed)
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = pointertest(k);
    string val = kret.getValue();
    verifyValue("me oh my pointertest-Derived", val);
    verifyCount(2, k); // an extra reference for the upcast in the proxy class
    verifyCount(1, kret);
  }

  // pass by ref (mixed)
  {
    auto k = scoped!KlassDerived("me oh my");
    auto kret = reftest(k);
    string val = kret.getValue();
    verifyValue("me oh my reftest-Derived", val);
    verifyCount(2, k); // an extra reference for the upcast in the proxy class
    verifyCount(1, kret);
  }

  // 3rd derived class
  {
    auto k = scoped!Klass3rdDerived("me oh my");
    string val = k.getValue();
    verifyValue("me oh my-3rdDerived", val);
    verifyCount(3, k); // 3 classes in inheritance chain == 3 swigCPtr values
    val = test3rdupcast(k);
    verifyValue("me oh my-3rdDerived", val);
    verifyCount(3, k);
  }

  ////////////////////////////////// Member variables ////////////////////////////////////////
  // smart pointer by value
  {
    auto k = scoped!Klass("smart member value");
    Klass kmember;

    {
      auto m = scoped!MemberVariables();
      m.SmartMemberValue = k;
      string val = k.getValue();
      verifyValue("smart member value", val);
      verifyCount(2, k);

      kmember = m.SmartMemberValue;
      val = kmember.getValue();
      verifyValue("smart member value", val);
      verifyCount(3, kmember);
      verifyCount(3, k);
    }

    verifyCount(2, kmember);
    verifyCount(2, k);
  }
  // smart pointer by pointer
  {
    auto k = scoped!Klass("smart member pointer");
    Klass kmember;

    {
      auto m = scoped!MemberVariables();
      m.SmartMemberPointer = k;
      string val = k.getValue();
      verifyValue("smart member pointer", val);
      verifyCount(1, k);

      kmember = m.SmartMemberPointer;
      val = kmember.getValue();
      verifyValue("smart member pointer", val);
      verifyCount(2, kmember);
      verifyCount(2, k);
    }

    verifyCount(2, kmember);
    verifyCount(2, k);
  }
  // smart pointer by reference
  {
    auto k = scoped!Klass("smart member reference");
    Klass kmember;

    {
      auto m = scoped!MemberVariables();
      m.SmartMemberReference = k;
      string val = k.getValue();
      verifyValue("smart member reference", val);
      verifyCount(2, k);

      kmember = m.SmartMemberReference;
      val = kmember.getValue();
      verifyValue("smart member reference", val);
      verifyCount(3, kmember);
      verifyCount(3, k);

      // The C++ reference refers to SmartMemberValue...
      auto kmemberVal = m.SmartMemberValue;
      val = kmember.getValue();
      verifyValue("smart member reference", val);
      verifyCount(4, kmemberVal);
      verifyCount(4, kmember);
      verifyCount(4, k);
    }

    verifyCount(3, kmember);
    verifyCount(3, k);
  }
  // plain by value
  {
    auto k = scoped!Klass("plain member value");
    Klass kmember;

    {
      auto m = scoped!MemberVariables();
      m.MemberValue = k;
      string val = k.getValue();
      verifyValue("plain member value", val);
      verifyCount(1, k);

      kmember = m.MemberValue;
      val = kmember.getValue();
      verifyValue("plain member value", val);
      verifyCount(1, kmember);
      verifyCount(1, k);
    }

    verifyCount(1, kmember);
    verifyCount(1, k);
  }
  // plain by pointer
  {
    auto k = scoped!Klass("plain member pointer");
    Klass kmember;

    {
      auto m = scoped!MemberVariables();
      m.MemberPointer = k;
      string val = k.getValue();
      verifyValue("plain member pointer", val);
      verifyCount(1, k);

      kmember = m.MemberPointer;
      val = kmember.getValue();
      verifyValue("plain member pointer", val);
      verifyCount(1, kmember);
      verifyCount(1, k);
    }

    verifyCount(1, kmember);
    verifyCount(1, k);
  }
  // plain by reference
  {
    auto k = scoped!Klass("plain member reference");
    Klass kmember;

    {
      auto m = scoped!MemberVariables();
      m.MemberReference = k;
      string val = k.getValue();
      verifyValue("plain member reference", val);
      verifyCount(1, k);

      kmember = m.MemberReference;
      val = kmember.getValue();
      verifyValue("plain member reference", val);
      verifyCount(1, kmember);
      verifyCount(1, k);
    }

    verifyCount(1, kmember);
    verifyCount(1, k);
  }

  // null member variables
  {
    auto m = scoped!MemberVariables();

    // shared_ptr by value
    auto k = m.SmartMemberValue;
    if (k !is null)
      throw new Exception("expected null");
    m.SmartMemberValue = null;
    k = m.SmartMemberValue;
    if (k !is null)
      throw new Exception("expected null");
    verifyCount(0, k);

    // plain by value
    enforceThrows( (){ m.MemberValue = null; }, "Failed to catch null pointer");
  }

  ////////////////////////////////// Global variables ////////////////////////////////////////
  // smart pointer
  {
    auto kglobal = GlobalSmartValue;
    enforce(kglobal is null, "expected null");

    auto k = scoped!Klass("smart global value");
    GlobalSmartValue = k;
    verifyCount(2, k);

    kglobal = GlobalSmartValue;
    string val = kglobal.getValue();
    verifyValue("smart global value", val);
    verifyCount(3, kglobal);
    verifyCount(3, k);
    verifyValue("smart global value", GlobalSmartValue.getValue());
    GlobalSmartValue = null;
  }
  // plain value
  {
    Klass kglobal;

    auto k = scoped!Klass("global value");
    GlobalValue = k;
    verifyCount(1, k);

    kglobal = GlobalValue;
    string val = kglobal.getValue();
    verifyValue("global value", val);
    verifyCount(1, kglobal);
    verifyCount(1, k);
    verifyValue("global value", GlobalValue.getValue());

    enforceThrows((){ GlobalValue = null; }, "Failed to catch null pointer");
  }
  // plain pointer
  {
    auto kglobal = GlobalPointer;
    enforce(kglobal is null, "expected null");

    auto k = scoped!Klass("global pointer");
    GlobalPointer = k;
    verifyCount(1, k);

    kglobal = GlobalPointer;
    string val = kglobal.getValue();
    verifyValue("global pointer", val);
    verifyCount(1, kglobal);
    verifyCount(1, k);
    GlobalPointer = null;
  }
  // plain reference
  {
    Klass kglobal;

    auto k = scoped!Klass("global reference");
    GlobalReference = k;
    verifyCount(1, k);

    kglobal = GlobalReference;
    string val = kglobal.getValue();
    verifyValue("global reference", val);
    verifyCount(1, kglobal);
    verifyCount(1, k);

    enforceThrows((){ GlobalReference = null; }, "Failed to catch null pointer");
  }

  ////////////////////////////////// Templates ////////////////////////////////////////
  {
    auto pid = new PairIntDouble(10, 20.2);
    enforce(pid.baseVal1 == 20 && pid.baseVal2== 40.4, "Base values wrong");
    enforce(pid.val1 == 10 && pid.val2 == 20.2, "Derived Values wrong");
  }
}

private void verifyValue(string expected, string got) {
  if (expected != got)
    throw new Exception("verify value failed. Expected: " ~ expected ~ " Got: " ~ got);
}

private void verifyCount(int expected, Klass k) {
  // We deliberately call the use_count(Klass) overload also for objects which
  // are instances of a subclass of Klass (due to static dispatch); things still
  // have to work.
  auto got = use_count(k);
  if (expected != got)
    throw new Exception("verify use_count failed. Expected: " ~ to!string(expected) ~ " Got: " ~ to!string(got));
}

private void enforceThrows(void delegate() dg, string errorMessage) {
  bool hasThrown;
  try {
    dg();
  } catch (Exception) {
    hasThrown = true;
  } finally {
    if (!hasThrown) {
      throw new Exception(errorMessage);
    }
  }
}
