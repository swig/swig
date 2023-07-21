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
  throw new RuntimeException("overloadTest failed");
if (/* await */(cpp11_std_unique_ptr.overloadTest(null)) != 1)
  throw new RuntimeException("overloadTest failed");
if (/* await */(cpp11_std_unique_ptr.overloadTest(new cpp11_std_unique_ptr.Klass("over"))) != 1)
  throw new RuntimeException("overloadTest failed");
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
