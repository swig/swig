var cpp11_std_unique_ptr = require("cpp11_std_unique_ptr");

var checkCount = /* async */ function(expected_count) {
  var actual_count = /* await */(cpp11_std_unique_ptr.Klass.getTotal_count());
  if (actual_count != expected_count)
    throw new Error("Counts incorrect, expected:" + expected_count + " actual:" + actual_count);
}

// Test raw pointer handling involving virtual inheritance
{
  var kini = new cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput");
  /* await */(checkCount(1));
  var s = /* await */(cpp11_std_unique_ptr.useKlassRawPtr(kini));
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  // delete kini;
  // Above not deleting the C++ object(node v12) - can't reliably control GC
  /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kini));
  /* await */(checkCount(0));
}


///// INPUT BY VALUE /////
// unique_ptr as input
{
  var kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kin));
  /* await */(checkCount(0));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!/* await */(cpp11_std_unique_ptr.is_nullptr(kin)))
    throw new Error("is_nullptr failed");
  /* await */(checkCount(0));
}

{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kin));
  /* await */(checkCount(0));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!/* await */(cpp11_std_unique_ptr.is_nullptr(kin)))
    throw new Error("is_nullptr failed");
  var exception_thrown = false;
  try {
    /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kin));
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
      throw new Error("double usage of takeKlassUniquePtr should have been an error");
  /* await */(checkCount(0));
}

{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  exception_thrown = false;
  var notowned = /* await */(cpp11_std_unique_ptr.get_not_owned_ptr(kin));
  try {
    /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(notowned));
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
    throw new Error("Should have thrown 'Cannot release ownership as memory is not owned' error");
  /* await */(checkCount(1));
  // delete kin;
  // Above not deleting the C++ object(node v12) - can't reliably control GC
  /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kin));
  /* await */(checkCount(0));
}

{
  kini = new cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kini));
  /* await */(checkCount(0));
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  if (!/* await */(cpp11_std_unique_ptr.is_nullptr(kini)))
    throw new Error("is_nullptr failed");
  /* await */(checkCount(0));
}

/* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(null));
/* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(/* await */(cpp11_std_unique_ptr.make_null())));
/* await */(checkCount(0));

// overloaded parameters
if (/* await */(cpp11_std_unique_ptr.overloadTest()) != 0)
  throw new Error("overloadTest failed");
if (/* await */(cpp11_std_unique_ptr.overloadTest(null)) != 1)
  throw new Error("overloadTest failed");
if (/* await */(cpp11_std_unique_ptr.overloadTest(new cpp11_std_unique_ptr.Klass("over"))) != 1)
  throw new Error("overloadTest failed");
/* await */(checkCount(0));


///// INPUT BY RVALUE REF /////
// unique_ptr as input
{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.moveKlassUniquePtr(kin));
  /* await */(checkCount(0));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!cpp11_std_unique_ptr.is_nullptr(kin))
    throw new Error("is_nullptr failed");
  //delete kin; // delete in JavaScript has a different meaning
  /* await */(checkCount(0));
}

{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.moveKlassUniquePtr(kin));
  /* await */(checkCount(0));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!/* await */(cpp11_std_unique_ptr.is_nullptr(kin)))
    throw new Error("is_nullptr failed");
  exception_thrown = false;
  try {
    /* await */(cpp11_std_unique_ptr.moveKlassUniquePtr(kin));
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
      throw new Error("double usage of moveKlassUniquePtr should have been an error");
  //delete kin; // delete in JavaScript has a different meaning
  /* await */(checkCount(0));
}

{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  exception_thrown = false;
  notowned = /* await */(cpp11_std_unique_ptr.get_not_owned_ptr(kin));
  try {
    /* await */(cpp11_std_unique_ptr.moveKlassUniquePtr(notowned));
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
    throw new Error("Should have thrown 'Cannot release ownership as memory is not owned' error");
  /* await */(checkCount(1));
  // delete kin;
  // Above not deleting the C++ object(node v12) - can't reliably control GC
  /* await */(cpp11_std_unique_ptr.moveKlassUniquePtr(kin));
  /* await */(checkCount(0));
}

{
  kini = new cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.moveKlassUniquePtr(kini));
  /* await */(checkCount(0));
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  if (!cpp11_std_unique_ptr.is_nullptr(kini))
    throw new Error("is_nullptr failed");
  //delete kin; // delete in JavaScript has a different meaning
  /* await */(checkCount(0));
}

/* await */(cpp11_std_unique_ptr.moveKlassUniquePtr(null));
/* await */(cpp11_std_unique_ptr.moveKlassUniquePtr(/* await */(cpp11_std_unique_ptr.make_null())));
/* await */(checkCount(0));

// overloaded parameters
if (/* await */(cpp11_std_unique_ptr.moveOverloadTest()) != 0)
  throw new Error("moveOverloadTest failed");
if (/* await */(cpp11_std_unique_ptr.moveOverloadTest(null)) != 1)
  throw new Error("moveOverloadTest failed");
if (/* await */(cpp11_std_unique_ptr.moveOverloadTest(new cpp11_std_unique_ptr.Klass("over"))) != 1)
  throw new Error("moveOverloadTest failed");
/* await */(checkCount(0));


///// INPUT BY NON-CONST LVALUE REF /////
// unique_ptr as input
{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin));
  /* await */(checkCount(0));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!cpp11_std_unique_ptr.is_nullptr(kin))
    throw new Error("is_nullptr failed");
  //delete kin; // delete in JavaScript has a different meaning
  /* await */(checkCount(0));
}

{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin));
  /* await */(checkCount(0));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!cpp11_std_unique_ptr.is_nullptr(kin))
    throw new Error("is_nullptr failed");
  exception_thrown = false;
  try {
    /* await */(cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin));
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
      throw new Error("double usage of moveRefKlassUniquePtr should have been an error");
  //delete kin; // delete in JavaScript has a different meaning
  /* await */(checkCount(0));
}

{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  exception_thrown = false;
  notowned = /* await */(cpp11_std_unique_ptr.get_not_owned_ptr(kin));
  try {
    /* await */(cpp11_std_unique_ptr.moveRefKlassUniquePtr(notowned));
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
    throw new Error("Should have thrown 'Cannot release ownership as memory is not owned' error");
  /* await */(checkCount(1));
  // delete kin;
  // Above not deleting the C++ object(node v12) - can't reliably control GC
  /* await */(cpp11_std_unique_ptr.moveRefKlassUniquePtr(kin));
  /* await */(checkCount(0));
}

{
  kini = new cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.moveRefKlassUniquePtr(kini));
  /* await */(checkCount(0));
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  if (!/* await */(cpp11_std_unique_ptr.is_nullptr(kini)))
    throw new Error("is_nullptr failed");
  //delete kin; // delete in JavaScript has a different meaning
  /* await */(checkCount(0));
}

/* await */(cpp11_std_unique_ptr.moveRefKlassUniquePtr(null));
/* await */(cpp11_std_unique_ptr.moveRefKlassUniquePtr(/* await */(cpp11_std_unique_ptr.make_null())));
checkCount(0);

// overloaded parameters
if (/* await */(cpp11_std_unique_ptr.moveRefOverloadTest()) != 0)
  throw new Error("moveRefOverloadTest failed");
if (/* await */(cpp11_std_unique_ptr.moveRefOverloadTest(null)) != 1)
  throw new Error("moveRefOverloadTest failed");
if (/* await */(cpp11_std_unique_ptr.moveRefOverloadTest(new cpp11_std_unique_ptr.Klass("over"))) != 1)
  throw new Error("moveRefOverloadTest failed");
/* await */(checkCount(0));


///// INPUT BY CONST LVALUE REF /////
// unique_ptr as input
{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.useRefKlassUniquePtr(kin));
  /* await */(checkCount(1));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  // delete kin;
  // Above not deleting the C++ object(node v12) - can't reliably control GC
  /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kin));
  /* await */(checkCount(0));
}

{
  kini = new cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput");
  /* await */(checkCount(1));
  s = /* await */(cpp11_std_unique_ptr.useRefKlassUniquePtr(kini));
  /* await */(checkCount(1));
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  // delete kini;
  // Above not deleting the C++ object - can't reliably control GC
  /* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kini));
  /* await */(checkCount(0));
}

/* await */(cpp11_std_unique_ptr.useRefKlassUniquePtr(null));
/* await */(cpp11_std_unique_ptr.useRefKlassUniquePtr(/* await */(cpp11_std_unique_ptr.make_null())));
/* await */(checkCount(0));

// overloaded parameters
if (/* await */(cpp11_std_unique_ptr.useRefOverloadTest()) != 0)
  throw new Error("useRefOverloadTest failed");
if (/* await */(cpp11_std_unique_ptr.useRefOverloadTest(null)) != 1)
  throw new Error("useRefOverloadTest failed");
kin = new cpp11_std_unique_ptr.Klass("over")
if (/* await */(cpp11_std_unique_ptr.useRefOverloadTest(kin)) != 1)
  throw new Error("useRefOverloadTest failed");
/* await */(checkCount(1));
// delete kin;
// Above not deleting the C++ object - can't reliably control GC
/* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(kin));
/* await */(checkCount(0));


// unique_ptr as output
var k1 = /* await */(cpp11_std_unique_ptr.makeKlassUniquePtr("first"));
if (/* await */(k1.getLabel()) !== "first")
  throw new Error("wrong object label");

var k2 = /* await */(cpp11_std_unique_ptr.makeKlassUniquePtr("second"));
/* await */(checkCount(2));

// delete k1;
// Above not deleting the C++ object(node v12) - can't reliably control GC
/* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(k1));
/* await */(checkCount(1));

if (/* await */(k2.getLabel()) !== "second")
  throw new Error("wrong object label");

// delete k2;
// Above not deleting the C++ object(node v12) - can't reliably control GC
/* await */(cpp11_std_unique_ptr.takeKlassUniquePtr(k2));
/* await */(checkCount(0));

if (/* await */(cpp11_std_unique_ptr.makeNullUniquePtr()) != null)
  throw new Error("null failure");

// unique_ptr as output (rvalue ref)
k1 = /* await */(cpp11_std_unique_ptr.makeRVRKlassUniquePtr("first"));
if (/* await */(k1.getLabel()) !== "first")
  throw new Error("wrong object label");
k1 = /* await */(cpp11_std_unique_ptr.makeRVRKlassUniquePtr(null));

// unique_ptr as output (lvalue ref)
k1 = /* await */(cpp11_std_unique_ptr.makeRefKlassUniquePtr("lvalueref"));
if (/* await */(k1.getLabel()) !== "lvalueref")
  throw new Error("wrong object label");
k1 = /* await */(cpp11_std_unique_ptr.makeRefKlassUniquePtr(null));
