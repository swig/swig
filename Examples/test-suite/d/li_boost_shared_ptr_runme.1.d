module li_boost_shared_ptr_runme;

import tango.io.Stdout;
import tango.core.Exception;
import tango.core.Memory;
import tango.core.Thread;
import tango.text.convert.Integer;
import li_boost_shared_ptr.li_boost_shared_ptr;
import li_boost_shared_ptr.Klass;
import li_boost_shared_ptr.KlassDerived;
import li_boost_shared_ptr.Klass3rdDerived;
import li_boost_shared_ptr.MemberVariables;
import li_boost_shared_ptr.PairIntDouble;

// Debugging flag
const bool TRACE = false;

void main() {
  if (TRACE)
    Stdout("---> STARTED <---").newline;

  debug_shared=TRACE;

  // Change loop count to run for a long time to monitor memory
  const int LOOP_COUNT = 1; // 50000;
  for (int i = 0; i < LOOP_COUNT; ++i) {
    runTest();
    GC.collect();
  }

  if (TRACE)
    Stdout("---> NEARLY FINISHED <---").newline;

  // Try to get the GC to collect everything not referenced anymore.
  int countdown = 100;
  while (--countdown) {
    GC.collect();
    if (Klass.getTotal_count() == 1)
      break;
    Thread.sleep(0.01);
  }

  // A single remaining instance expected: the global variable (GlobalValue).
  if (Klass.getTotal_count() != 1)
    throw new Exception("Klass.total_count=" ~ toString(Klass.getTotal_count()));

  // A single remaining instance expected: the global variable (GlobalSmartValue).
  int wrapper_count = shared_ptr_wrapper_count();
  if (wrapper_count != NOT_COUNTING)
    if (wrapper_count != 1)
      throw new Exception("shared_ptr wrapper count=" ~ toString(wrapper_count));

  if (TRACE)
    Stdout("---> FINISHED <---").newline;
}

void runTest() {
  // simple shared_ptr usage - created in C++
  {
    auto k = new Klass("me oh my");
    char[] val = k.getValue();
    verifyValue("me oh my", val);
    verifyCount(1, k);
  }

  // simple shared_ptr usage - not created in C++
  {
    auto k = factorycreate();
    char[] val = k.getValue();
    verifyValue("factorycreate", val);
    verifyCount(1, k);
  }

  // pass by shared_ptr
  {
    auto k = new Klass("me oh my");
    auto kret = smartpointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my smartpointertest", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // pass by shared_ptr pointer
  {
    auto k = new Klass("me oh my");
    auto kret = smartpointerpointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my smartpointerpointertest", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // pass by shared_ptr reference
  {
    auto k = new Klass("me oh my");
    auto kret = smartpointerreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my smartpointerreftest", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // pass by shared_ptr pointer reference
  {
    auto k = new Klass("me oh my");
    auto kret = smartpointerpointerreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my smartpointerpointerreftest", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // const pass by shared_ptr
  {
    auto k = new Klass("me oh my");
    auto kret = constsmartpointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // const pass by shared_ptr pointer
  {
    auto k = new Klass("me oh my");
    auto kret = constsmartpointerpointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // const pass by shared_ptr reference
  {
    auto k = new Klass("me oh my");
    auto kret = constsmartpointerreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my", val);
    verifyCount(2, k);
    verifyCount(2, kret);
  }

  // pass by value
  {
    auto k = new Klass("me oh my");
    auto kret = valuetest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my valuetest", val);
    verifyCount(1, k);
    verifyCount(1, kret);
  }

  // pass by pointer
  {
    auto k = new Klass("me oh my");
    auto kret = pointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my pointertest", val);
    verifyCount(1, k);
    verifyCount(1, kret);
  }

  // pass by reference
  {
    auto k = new Klass("me oh my");
    auto kret = reftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my reftest", val);
    verifyCount(1, k);
    verifyCount(1, kret);
  }

  // pass by pointer reference
  {
    auto k = new Klass("me oh my");
    auto kret = pointerreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my pointerreftest", val);
    verifyCount(1, k);
    verifyCount(1, kret);
  }

  // null tests
  {
    Klass k = null;

    // TODO: add in const versions too
    if (smartpointertest(k) !is null)
      throw new Exception("return was not null");

    if (smartpointerpointertest(k) !is null)
      throw new Exception("return was not null");

    if (smartpointerreftest(k) !is null)
      throw new Exception("return was not null");

    if (smartpointerpointerreftest(k) !is null)
      throw new Exception("return was not null");

    if (nullsmartpointerpointertest(null) != "null pointer")
      throw new Exception("not null smartpointer pointer");

    try { valuetest(k); throw new Exception("Failed to catch null pointer"); } catch (IllegalArgumentException) {}

    if (pointertest(k) !is null)
      throw new Exception("return was not null");

    try { reftest(k); throw new Exception("Failed to catch null pointer"); } catch (IllegalArgumentException) {}
  }

  // $owner
  {
    auto k = pointerownertest();
    char[] val = k.getValue();
    verifyValue("pointerownertest", val);
    verifyCount(1, k);
  }
  {
    auto k = smartpointerpointerownertest();
    char[] val = k.getValue();
    verifyValue("smartpointerpointerownertest", val);
    verifyCount(1, k);
  }

  ////////////////////////////////// Derived classes ////////////////////////////////////////
  // derived pass by shared_ptr
  {
    auto k = new KlassDerived("me oh my");
    auto kret = derivedsmartptrtest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my derivedsmartptrtest-Derived", val);
    verifyCount(4, k); // includes two extra references for upcasts in the proxy classes
    verifyCount(4, kret);
  }
  // derived pass by shared_ptr pointer
  {
    auto k = new KlassDerived("me oh my");
    auto kret = derivedsmartptrpointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my derivedsmartptrpointertest-Derived", val);
    verifyCount(4, k); // includes two extra references for upcasts in the proxy classes
    verifyCount(4, kret);
  }
  // derived pass by shared_ptr ref
  {
    auto k = new KlassDerived("me oh my");
    auto kret = derivedsmartptrreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my derivedsmartptrreftest-Derived", val);
    verifyCount(4, k); // includes two extra references for upcasts in the proxy classes
    verifyCount(4, kret);
  }
  // derived pass by shared_ptr pointer ref
  {
    auto k = new KlassDerived("me oh my");
    auto kret = derivedsmartptrpointerreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my derivedsmartptrpointerreftest-Derived", val);
    verifyCount(4, k); // includes two extra references for upcasts in the proxy classes
    verifyCount(4, kret);
  }
  // derived pass by pointer
  {
    auto k = new KlassDerived("me oh my");
    auto kret = derivedpointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my derivedpointertest-Derived", val);
    verifyCount(2, k); // includes an extra reference for the upcast in the proxy class
    verifyCount(2, kret);
  }
  // derived pass by ref
  {
    auto k = new KlassDerived("me oh my");
    auto kret = derivedreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my derivedreftest-Derived", val);
    verifyCount(2, k); // includes an extra reference for the upcast in the proxy class
    verifyCount(2, kret);
  }

  ////////////////////////////////// Derived and base class mixed ////////////////////////////////////////
  // pass by shared_ptr (mixed)
  {
    auto k = new KlassDerived("me oh my");
    auto kret = smartpointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my smartpointertest-Derived", val);
    verifyCount(3, k); // an extra reference for the upcast in the proxy class
    verifyCount(3, kret);
  }

  // pass by shared_ptr pointer (mixed)
  {
    auto k = new KlassDerived("me oh my");
    auto kret = smartpointerpointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my smartpointerpointertest-Derived", val);
    verifyCount(3, k); // an extra reference for the upcast in the proxy class
    verifyCount(3, kret);
  }

  // pass by shared_ptr reference (mixed)
  {
    auto k = new KlassDerived("me oh my");
    auto kret = smartpointerreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my smartpointerreftest-Derived", val);
    verifyCount(3, k); // an extra reference for the upcast in the proxy class
    verifyCount(3, kret);
  }

  // pass by shared_ptr pointer reference (mixed)
  {
    auto k = new KlassDerived("me oh my");
    auto kret = smartpointerpointerreftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my smartpointerpointerreftest-Derived", val);
    verifyCount(3, k); // an extra reference for the upcast in the proxy class
    verifyCount(3, kret);
  }

  // pass by value (mixed)
  {
    auto k = new KlassDerived("me oh my");
    auto kret = valuetest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my valuetest", val); // note slicing
    verifyCount(2, k); // an extra reference for the upcast in the proxy class
    verifyCount(1, kret);
  }

  // pass by pointer (mixed)
  {
    auto k = new KlassDerived("me oh my");
    auto kret = pointertest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my pointertest-Derived", val);
    verifyCount(2, k); // an extra reference for the upcast in the proxy class
    verifyCount(1, kret);
  }

  // pass by ref (mixed)
  {
    auto k = new KlassDerived("me oh my");
    auto kret = reftest(k);
    char[] val = kret.getValue();
    verifyValue("me oh my reftest-Derived", val);
    verifyCount(2, k); // an extra reference for the upcast in the proxy class
    verifyCount(1, kret);
  }

  // 3rd derived class
  {
    auto k = new Klass3rdDerived("me oh my");
    char[] val = k.getValue();
    verifyValue("me oh my-3rdDerived", val);
    verifyCount(3, k); // 3 classes in inheritance chain == 3 swigCPtr values
    val = test3rdupcast(k);
    verifyValue("me oh my-3rdDerived", val);
    verifyCount(3, k);
  }

  ////////////////////////////////// Member variables ////////////////////////////////////////
  // smart pointer by value
  {
    auto m = new MemberVariables();
    auto k = new Klass("smart member value");
    m.SmartMemberValue = k;
    char[] val = k.getValue();
    verifyValue("smart member value", val);
    verifyCount(2, k);

    auto kmember = m.SmartMemberValue;
    val = kmember.getValue();
    verifyValue("smart member value", val);
    verifyCount(3, kmember);
    verifyCount(3, k);

    delete m;

    verifyCount(2, kmember);
    verifyCount(2, k);
  }
  // smart pointer by pointer
  {
    auto m = new MemberVariables();
    auto k = new Klass("smart member pointer");
    m.SmartMemberPointer = k;
    char[] val = k.getValue();
    verifyValue("smart member pointer", val);
    verifyCount(1, k);

    auto kmember = m.SmartMemberPointer;
    val = kmember.getValue();
    verifyValue("smart member pointer", val);
    verifyCount(2, kmember);
    verifyCount(2, k);

    delete m;

    verifyCount(2, kmember);
    verifyCount(2, k);
  }
  // smart pointer by reference
  {
    auto m = new MemberVariables();
    auto k = new Klass("smart member reference");
    m.SmartMemberReference = k;
    char[] val = k.getValue();
    verifyValue("smart member reference", val);
    verifyCount(2, k);

    auto kmember = m.SmartMemberReference;
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

    delete m;

    verifyCount(3, kmember);
    verifyCount(3, k);
  }
  // plain by value
  {
    auto m = new MemberVariables();
    auto k = new Klass("plain member value");
    m.MemberValue = k;
    char[] val = k.getValue();
    verifyValue("plain member value", val);
    verifyCount(1, k);

    auto kmember = m.MemberValue;
    val = kmember.getValue();
    verifyValue("plain member value", val);
    verifyCount(1, kmember);
    verifyCount(1, k);

    delete m;

    verifyCount(1, kmember);
    verifyCount(1, k);
  }
  // plain by pointer
  {
    auto m = new MemberVariables();
    auto k = new Klass("plain member pointer");
    m.MemberPointer = k;
    char[] val = k.getValue();
    verifyValue("plain member pointer", val);
    verifyCount(1, k);

    auto kmember = m.MemberPointer;
    val = kmember.getValue();
    verifyValue("plain member pointer", val);
    verifyCount(1, kmember);
    verifyCount(1, k);

    delete m;

    verifyCount(1, kmember);
    verifyCount(1, k);
  }
  // plain by reference
  {
    auto m = new MemberVariables();
    auto k = new Klass("plain member reference");
    m.MemberReference = k;
    char[] val = k.getValue();
    verifyValue("plain member reference", val);
    verifyCount(1, k);

    auto kmember = m.MemberReference;
    val = kmember.getValue();
    verifyValue("plain member reference", val);
    verifyCount(1, kmember);
    verifyCount(1, k);

    delete m;

    verifyCount(1, kmember);
    verifyCount(1, k);
  }

  // null member variables
  {
    auto m = new MemberVariables();

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
    try { m.MemberValue = null; throw new Exception("Failed to catch null pointer"); } catch (IllegalArgumentException) {}
  }

  ////////////////////////////////// Global variables ////////////////////////////////////////
  // smart pointer
  {
    auto kglobal = GlobalSmartValue;
    if (kglobal !is null)
      throw new Exception("expected null");

    auto k = new Klass("smart global value");
    GlobalSmartValue = k;
    verifyCount(2, k);

    kglobal = GlobalSmartValue;
    char[] val = kglobal.getValue();
    verifyValue("smart global value", val);
    verifyCount(3, kglobal);
    verifyCount(3, k);
    verifyValue("smart global value", GlobalSmartValue.getValue());
    GlobalSmartValue = null;
  }
  // plain value
  {
    Klass kglobal;

    auto k = new Klass("global value");
    GlobalValue = k;
    verifyCount(1, k);

    kglobal = GlobalValue;
    char[] val = kglobal.getValue();
    verifyValue("global value", val);
    verifyCount(1, kglobal);
    verifyCount(1, k);
    verifyValue("global value", GlobalValue.getValue());

    try { GlobalValue = null; throw new Exception("Failed to catch null pointer"); } catch (IllegalArgumentException) {}
  }
  // plain pointer
  {
    auto kglobal = GlobalPointer;
    if (kglobal !is null)
      throw new Exception("expected null");

    auto k = new Klass("global pointer");
    GlobalPointer = k;
    verifyCount(1, k);

    kglobal = GlobalPointer;
    char[] val = kglobal.getValue();
    verifyValue("global pointer", val);
    verifyCount(1, kglobal);
    verifyCount(1, k);
    GlobalPointer = null;
  }
  // plain reference
  {
    Klass kglobal;

    auto k = new Klass("global reference");
    GlobalReference = k;
    verifyCount(1, k);

    kglobal = GlobalReference;
    char[] val = kglobal.getValue();
    verifyValue("global reference", val);
    verifyCount(1, kglobal);
    verifyCount(1, k);

    try { GlobalReference = null; throw new Exception("Failed to catch null pointer"); } catch (IllegalArgumentException) {}
  }

  ////////////////////////////////// Templates ////////////////////////////////////////
  {
    PairIntDouble pid = new PairIntDouble(10, 20.2);
    if (pid.baseVal1 != 20 || pid.baseVal2 != 40.4)
      throw new Exception("Base values wrong");
    if (pid.val1 != 10 || pid.val2 != 20.2)
      throw new Exception("Derived Values wrong");
  }
}

private void verifyValue(char[] expected, char[] got) {
  if (expected != got)
    throw new Exception("verify value failed. Expected: " ~ expected ~ " Got: " ~ got);
}

private void verifyCount(int expected, Klass k) {
  // We deliberately call the use_count(Klass) overload also for objects which
  // are instances of a subclass of Klass (due to static dispatch); things still
  // have to work.
  int got = use_count(k);
  if (expected != got)
    throw new Exception("verify use_count failed. Expected: " ~ toString(expected) ~ " Got: " ~ toString(got));
}
