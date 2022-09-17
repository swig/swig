var cpp11_std_unique_ptr = require("cpp11_std_unique_ptr");

var checkCount = function(expected_count) {
  actual_count = cpp11_std_unique_ptr.Klass.getTotal_count();
  if (actual_count != expected_count)
    throw new Error("Counts incorrect, expected:" + expected_count + " actual:" + actual_count);
}

// Test raw pointer handling involving virtual inheritance
{
  kini = new cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput");
  checkCount(1);
  s = cpp11_std_unique_ptr.useKlassRawPtr(kini);
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  // delete kini;
  // Above not deleting the C++ object(node v12) - can't reliably control GC
  cpp11_std_unique_ptr.takeKlassUniquePtr(kini);
  checkCount(0);
}


// unique_ptr as input
{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  checkCount(1);
  s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin);
  checkCount(0);
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!cpp11_std_unique_ptr.is_nullptr(kin))
    throw new Error("is_nullptr failed");
  delete kin; // Should not fail, even though already deleted
  checkCount(0);
}

{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  checkCount(1);
  s = cpp11_std_unique_ptr.takeKlassUniquePtr(kin);
  checkCount(0);
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!cpp11_std_unique_ptr.is_nullptr(kin))
    throw new Error("is_nullptr failed");
  exception_thrown = false;
  try {
    cpp11_std_unique_ptr.takeKlassUniquePtr(kin);
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
      throw new Error("double usage of takeKlassUniquePtr should have been an error");
  delete kin; // Should not fail, even though already deleted
  checkCount(0);
}

{
  kin = new cpp11_std_unique_ptr.Klass("KlassInput");
  exception_thrown = false;
  notowned = cpp11_std_unique_ptr.get_not_owned_ptr(kin);
  try {
    cpp11_std_unique_ptr.takeKlassUniquePtr(notowned);
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
    throw new Error("Should have thrown 'Cannot release ownership as memory is not owned' error");
  checkCount(1);
  // delete kin;
  // Above not deleting the C++ object(node v12) - can't reliably control GC
  cpp11_std_unique_ptr.takeKlassUniquePtr(kin);
  checkCount(0);
}

{
  kini = new cpp11_std_unique_ptr.KlassInheritance("KlassInheritanceInput");
  checkCount(1);
  s = cpp11_std_unique_ptr.takeKlassUniquePtr(kini);
  checkCount(0);
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  if (!cpp11_std_unique_ptr.is_nullptr(kini))
    throw new Error("is_nullptr failed");
  delete kini; // Should not fail, even though already deleted
  checkCount(0);
}

cpp11_std_unique_ptr.takeKlassUniquePtr(null);
cpp11_std_unique_ptr.takeKlassUniquePtr(cpp11_std_unique_ptr.make_null());
checkCount(0);

// overloaded parameters
if (cpp11_std_unique_ptr.overloadTest() != 0)
  throw new RuntimeException("overloadTest failed");
if (cpp11_std_unique_ptr.overloadTest(null) != 1)
  throw new RuntimeException("overloadTest failed");
if (cpp11_std_unique_ptr.overloadTest(new cpp11_std_unique_ptr.Klass("over")) != 1)
  throw new RuntimeException("overloadTest failed");
checkCount(0);


// unique_ptr as output
k1 = cpp11_std_unique_ptr.makeKlassUniquePtr("first");
if (k1.getLabel() !== "first")
  throw new Error("wrong object label");

k2 = cpp11_std_unique_ptr.makeKlassUniquePtr("second");
checkCount(2);

// delete k1;
// Above not deleting the C++ object(node v12) - can't reliably control GC
cpp11_std_unique_ptr.takeKlassUniquePtr(k1);
checkCount(1);

if (k2.getLabel() !== "second")
  throw new Error("wrong object label");

// delete k2;
// Above not deleting the C++ object(node v12) - can't reliably control GC
cpp11_std_unique_ptr.takeKlassUniquePtr(k2);
checkCount(0);

if (cpp11_std_unique_ptr.makeNullUniquePtr() != null)
  throw new Error("null failure");
