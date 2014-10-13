var li_boost_shared_ptr = require("li_boost_shared_ptr");
debug = false

function mygc() {
  if(typeof engine === "undefined" || engine()=="v8") {
    gc()
  } else {
    garbage()
  }
}

function haveGC() {
  if(typeof engine === "undefined" || engine()=="v8") {
    return true
  } else {
    return garbage()
  }
}

// simple shared_ptr usage - created in C++
function li_boost_shared_ptr_runme() {
  this.main = function() {
    if (debug) {
      console.log("Started")
    }

    li_boost_shared_ptr.debug_shared = debug

    // Change loop count to run for a long time to monitor memory
    for (var i = 0; i < 1; i++) {
      this.runtest()
    }

    // Expect 1 instance - the one global variable (GlobalValue)
    mygc();
    if (li_boost_shared_ptr.Klass.getTotal_count() != 1) {
      throw new Error("Klass.total_count=" + li_boost_shared_ptr.Klass.getTotal_count())
    }

    wrapper_count = li_boost_shared_ptr.shared_ptr_wrapper_count() 
    if (wrapper_count != li_boost_shared_ptr.NOT_COUNTING) {
      // Expect 1 instance - the one global variable (GlobalSmartValue)
      if (wrapper_count != 1) {
        throw new Error("shared_ptr wrapper count=" + wrapper_count)
      }
    }
    if (debug) {
      console.log("Finished")
    }
  }

  this.runtest = function() {
    // simple shared_ptr usage - created in C++
    k = new li_boost_shared_ptr.Klass("me oh my")
    val = k.getValue()
    this.verifyValue("me oh my", val)
    this.verifyCount(1, k)

    // simple shared_ptr usage - not created in C++
    k = li_boost_shared_ptr.factorycreate()
    val = k.getValue()
    this.verifyValue("factorycreate", val)
    this.verifyCount(1, k)

    // pass by shared_ptr
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.smartpointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my smartpointertest", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // pass by shared_ptr pointer
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.smartpointerpointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my smartpointerpointertest", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // pass by shared_ptr reference
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.smartpointerreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my smartpointerreftest", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // pass by shared_ptr pointer reference
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.smartpointerpointerreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my smartpointerpointerreftest", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // const pass by shared_ptr
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.constsmartpointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // const pass by shared_ptr pointer
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.constsmartpointerpointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // const pass by shared_ptr reference
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.constsmartpointerreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // pass by value
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.valuetest(k)
    val = kret.getValue()
    this.verifyValue("me oh my valuetest", val)
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // pass by pointer
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.pointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my pointertest", val)
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // pass by reference
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.reftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my reftest", val)
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // pass by pointer reference
    k = new li_boost_shared_ptr.Klass("me oh my")
    kret = li_boost_shared_ptr.pointerreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my pointerreftest", val)
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // null tests
    k = null

    if (li_boost_shared_ptr.smartpointertest(k) != null) {
      throw new Error("return was not null")
    }

    if (li_boost_shared_ptr.smartpointerpointertest(k) != null) {
      throw new Error("return was not null")
    }

    if (li_boost_shared_ptr.smartpointerreftest(k) != null) {
      throw new Error("return was not null")
    }

    if (li_boost_shared_ptr.smartpointerpointerreftest(k) != null) {
      throw new Error("return was not null")
    }

    if (li_boost_shared_ptr.nullsmartpointerpointertest(null) != "null pointer") {
      throw new Error("not null smartpointer pointer")
    }

    try {
      li_boost_shared_ptr.valuetest(k)
      throw new Error("Failed to catch null pointer")
    } catch(err) {
    }

    if (li_boost_shared_ptr.pointertest(k) != null) {
      throw new Error("return was not null")
    }

    try {
      li_boost_shared_ptr.reftest(k)
      throw new Error("Failed to catch null pointer")
    } catch(err) {
    }

    // $owner
    k = li_boost_shared_ptr.pointerownertest()
    val = k.getValue()
    this.verifyValue("pointerownertest", val)
    this.verifyCount(1, k)
    k = li_boost_shared_ptr.smartpointerpointerownertest()
    val = k.getValue()
    this.verifyValue("smartpointerpointerownertest", val)
    this.verifyCount(1, k)

    // //////////////////////////////// Derived class ////////////////////////////////////////
    // derived pass by shared_ptr
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.derivedsmartptrtest(k)
    val = kret.getValue()
    this.verifyValue("me oh my derivedsmartptrtest-Derived", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // derived pass by shared_ptr pointer
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.derivedsmartptrpointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my derivedsmartptrpointertest-Derived", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // derived pass by shared_ptr ref
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.derivedsmartptrreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my derivedsmartptrreftest-Derived", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // derived pass by shared_ptr pointer ref
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.derivedsmartptrpointerreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my derivedsmartptrpointerreftest-Derived", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // derived pass by pointer
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.derivedpointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my derivedpointertest-Derived", val)
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // derived pass by ref
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.derivedreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my derivedreftest-Derived", val)
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // //////////////////////////////// Derived and base class mixed ////////////////////////////////////////
    // pass by shared_ptr (mixed)
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.smartpointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my smartpointertest-Derived", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // pass by shared_ptr pointer (mixed)
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.smartpointerpointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my smartpointerpointertest-Derived", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // pass by shared_ptr reference (mixed)
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.smartpointerreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my smartpointerreftest-Derived", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // pass by shared_ptr pointer reference (mixed)
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.smartpointerpointerreftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my smartpointerpointerreftest-Derived", val)
    this.verifyCount(2, k)
    this.verifyCount(2, kret)

    // pass by value (mixed)
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.valuetest(k)
    val = kret.getValue()
    this.verifyValue("me oh my valuetest", val) // note slicing
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // pass by pointer (mixed)
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.pointertest(k)
    val = kret.getValue()
    this.verifyValue("me oh my pointertest-Derived", val)
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // pass by ref (mixed)
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    kret = li_boost_shared_ptr.reftest(k)
    val = kret.getValue()
    this.verifyValue("me oh my reftest-Derived", val)
    this.verifyCount(1, k)
    this.verifyCount(1, kret)

    // //////////////////////////////// Overloading tests ////////////////////////////////////////
    // Base class
    k = new li_boost_shared_ptr.Klass("me oh my")
    this.verifyValue(li_boost_shared_ptr.overload_rawbyval(k), "rawbyval")
    this.verifyValue(li_boost_shared_ptr.overload_rawbyref(k), "rawbyref")
    this.verifyValue(li_boost_shared_ptr.overload_rawbyptr(k), "rawbyptr")
    this.verifyValue(li_boost_shared_ptr.overload_rawbyptrref(k), "rawbyptrref")

    this.verifyValue(li_boost_shared_ptr.overload_smartbyval(k), "smartbyval")
    this.verifyValue(li_boost_shared_ptr.overload_smartbyref(k), "smartbyref")
    this.verifyValue(li_boost_shared_ptr.overload_smartbyptr(k), "smartbyptr")
    this.verifyValue(li_boost_shared_ptr.overload_smartbyptrref(k), "smartbyptrref")

    // Derived class
    k = new li_boost_shared_ptr.KlassDerived("me oh my")
    this.verifyValue(li_boost_shared_ptr.overload_rawbyval(k), "rawbyval")
    this.verifyValue(li_boost_shared_ptr.overload_rawbyref(k), "rawbyref")
    this.verifyValue(li_boost_shared_ptr.overload_rawbyptr(k), "rawbyptr")
    this.verifyValue(li_boost_shared_ptr.overload_rawbyptrref(k), "rawbyptrref")

    this.verifyValue(li_boost_shared_ptr.overload_smartbyval(k), "smartbyval")
    this.verifyValue(li_boost_shared_ptr.overload_smartbyref(k), "smartbyref")
    this.verifyValue(li_boost_shared_ptr.overload_smartbyptr(k), "smartbyptr")
    this.verifyValue(li_boost_shared_ptr.overload_smartbyptrref(k), "smartbyptrref")

    // 3rd derived class
    k = new li_boost_shared_ptr.Klass3rdDerived("me oh my")
    val = k.getValue()
    this.verifyValue("me oh my-3rdDerived", val)
    this.verifyCount(1, k)
    val = li_boost_shared_ptr.test3rdupcast(k)
    this.verifyValue("me oh my-3rdDerived", val)
    this.verifyCount(1, k)

    // //////////////////////////////// Member variables ////////////////////////////////////////
    // smart pointer by value
    m = new li_boost_shared_ptr.MemberVariables()
    k = new li_boost_shared_ptr.Klass("smart member value")
    m.SmartMemberValue = k
    val = k.getValue()
    this.verifyValue("smart member value", val)
    this.verifyCount(2, k)

    kmember = m.SmartMemberValue
    val = kmember.getValue()
    this.verifyValue("smart member value", val)
    this.verifyCount(3, kmember)
    this.verifyCount(3, k)

    delete m
    mygc();
    this.verifyCount(2, kmember)
    this.verifyCount(2, k)

    // smart pointer by pointer
    m = new li_boost_shared_ptr.MemberVariables()
    k = new li_boost_shared_ptr.Klass("smart member pointer")
    m.SmartMemberPointer = k
    val = k.getValue()
    this.verifyValue("smart member pointer", val)
    this.verifyCount(1, k)

    kmember = m.SmartMemberPointer
    val = kmember.getValue()
    this.verifyValue("smart member pointer", val)
    this.verifyCount(2, kmember)
    this.verifyCount(2, k)

    delete m
    mygc();
    this.verifyCount(2, kmember)
    this.verifyCount(2, k)

    // smart pointer by reference
    m = new li_boost_shared_ptr.MemberVariables()
    k = new li_boost_shared_ptr.Klass("smart member reference")
    m.SmartMemberReference = k
    val = k.getValue()
    this.verifyValue("smart member reference", val)
    this.verifyCount(2, k)

    kmember = m.SmartMemberReference
    val = kmember.getValue()
    this.verifyValue("smart member reference", val)
    this.verifyCount(3, kmember)
    this.verifyCount(3, k)

    // The C++ reference refers to SmartMemberValue...
    kmemberVal = m.SmartMemberValue
    val = kmember.getValue()
    this.verifyValue("smart member reference", val)
    this.verifyCount(4, kmemberVal)
    this.verifyCount(4, kmember)
    this.verifyCount(4, k)

    delete m
    mygc();
    this.verifyCount(3, kmemberVal)
    this.verifyCount(3, kmember)
    this.verifyCount(3, k)

    // plain by value
    m = new li_boost_shared_ptr.MemberVariables()
    k = new li_boost_shared_ptr.Klass("plain member value")
    m.MemberValue = k
    val = k.getValue()
    this.verifyValue("plain member value", val)
    this.verifyCount(1, k)

    kmember = m.MemberValue
    val = kmember.getValue()
    this.verifyValue("plain member value", val)
    this.verifyCount(1, kmember)
    this.verifyCount(1, k)

    delete m
    mygc();
    this.verifyCount(1, kmember)
    this.verifyCount(1, k)

    // plain by pointer
    m = new li_boost_shared_ptr.MemberVariables()
    k = new li_boost_shared_ptr.Klass("plain member pointer")
    m.MemberPointer = k
    val = k.getValue()
    this.verifyValue("plain member pointer", val)
    this.verifyCount(1, k)

    kmember = m.MemberPointer
    val = kmember.getValue()
    this.verifyValue("plain member pointer", val)
    this.verifyCount(1, kmember)
    this.verifyCount(1, k)

    delete m
    mygc();
    this.verifyCount(1, kmember)
    this.verifyCount(1, k)

    // plain by reference
    m = new li_boost_shared_ptr.MemberVariables()
    k = new li_boost_shared_ptr.Klass("plain member reference")
    m.MemberReference = k
    val = k.getValue()
    this.verifyValue("plain member reference", val)
    this.verifyCount(1, k)

    kmember = m.MemberReference
    val = kmember.getValue()
    this.verifyValue("plain member reference", val)
    this.verifyCount(1, kmember)
    this.verifyCount(1, k)

    delete m
    mygc();
    this.verifyCount(1, kmember)
    this.verifyCount(1, k)

    // null member variables
    m = new li_boost_shared_ptr.MemberVariables()

    // shared_ptr by value
    k = m.SmartMemberValue
    if (k != null) {
      throw new Error("expected null")
    }
    m.SmartMemberValue = null
    k = m.SmartMemberValue
    if (k != null) {
      throw new Error("expected null")
    }
    this.verifyCount(0, k)

    // plain by value
    try {
      m.MemberValue = null
      throw new Error("Failed to catch null pointer")
    } catch(err) {
    }

    // ////////////////////////////////// Global variables ////////////////////////////////////////
    // smart pointer
    kglobal = li_boost_shared_ptr.GlobalSmartValue
    if (kglobal != null) {
      throw new Error("expected null")
    }

    k = new li_boost_shared_ptr.Klass("smart global value")
    li_boost_shared_ptr.GlobalSmartValue = k
    this.verifyCount(2, k)

    kglobal = li_boost_shared_ptr.GlobalSmartValue
    val = kglobal.getValue()
    this.verifyValue("smart global value", val)
    this.verifyCount(3, kglobal)
    this.verifyCount(3, k)
    this.verifyValue("smart global value", li_boost_shared_ptr.GlobalSmartValue.getValue())
    li_boost_shared_ptr.GlobalSmartValue = null

    // plain value
    k = new li_boost_shared_ptr.Klass("global value")
    li_boost_shared_ptr.GlobalValue = k
    this.verifyCount(1, k)

    kglobal = li_boost_shared_ptr.GlobalValue
    val = kglobal.getValue()
    this.verifyValue("global value", val)
    this.verifyCount(1, kglobal)
    this.verifyCount(1, k)
    this.verifyValue("global value", li_boost_shared_ptr.GlobalValue.getValue())

    try {
      li_boost_shared_ptr.GlobalValue = null
      throw new Error("Failed to catch null pointer")
    } catch(err) {
    }

    // plain pointer
    kglobal = li_boost_shared_ptr.GlobalPointer
    if (kglobal != null) {
      throw new Error("expected null")
    }

    k = new li_boost_shared_ptr.Klass("global pointer")
    li_boost_shared_ptr.GlobalPointer = k
    this.verifyCount(1, k)

    kglobal = li_boost_shared_ptr.GlobalPointer
    val = kglobal.getValue()
    this.verifyValue("global pointer", val)
    this.verifyCount(1, kglobal)
    this.verifyCount(1, k)
    li_boost_shared_ptr.GlobalPointer = null

    // plain reference
    kglobal

    k = new li_boost_shared_ptr.Klass("global reference")
    li_boost_shared_ptr.GlobalReference = k
    this.verifyCount(1, k)

    kglobal = li_boost_shared_ptr.GlobalReference
    val = kglobal.getValue()
    this.verifyValue("global reference", val)
    this.verifyCount(1, kglobal)
    this.verifyCount(1, k)

    try {
      li_boost_shared_ptr.GlobalReference = null 
      throw new Error("Failed to catch null pointer")
    } catch(err) {
    }

    // ////////////////////////////////// Templates ////////////////////////////////////////
    pid = new li_boost_shared_ptr.PairIntDouble(10, 20.2)
    if (pid.baseVal1 != 20 || pid.baseVal2 != 40.4) {
      throw new Error("Base values wrong " + pid.baseVal1 + " " + pid.baseVal2)
    }
    if (pid.val1 != 10 || pid.val2 != 20.2) {
      throw new Error("Derived Values wrong")
    }
    
    k = null;
    kmember = null;
    kmemberVal = null;
    kret = null;
    val = null;
    kglobal = null;
    pid = null;
    m = null;
  }

  this.verifyValue = function(expected, got) {
    if (expected != got) {
      throw new Error("verify value failed. Expected: " + expected + " Got: " + got)
    }
  }

  this.verifyCount = function(expected, k) {
    got = li_boost_shared_ptr.use_count(k)
    if (expected != got) {
      throw new Error("verify use_count failed. Expected: " + expected + " Got: " + got)
    }
  }
}

var runme = new li_boost_shared_ptr_runme()
if (haveGC()) {
  runme.main()
}

