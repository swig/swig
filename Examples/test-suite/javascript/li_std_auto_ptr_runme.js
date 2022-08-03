var li_std_auto_ptr = require("li_std_auto_ptr");

var checkCount = function(expected_count) {
  actual_count = li_std_auto_ptr.Klass.getTotal_count();
  if (actual_count != expected_count)
    throw new Error("Counts incorrect, expected:" + expected_count + " actual:" + actual_count);
}

// auto_ptr as input
{
  kin = new li_std_auto_ptr.Klass("KlassInput");
  checkCount(1);
  s = li_std_auto_ptr.takeKlassAutoPtr(kin);
  checkCount(0);
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!li_std_auto_ptr.is_nullptr(kin))
    throw new Error("is_nullptr failed");
  delete kin; // Should not fail, even though already deleted
  checkCount(0);
}

{
  kin = new li_std_auto_ptr.Klass("KlassInput");
  checkCount(1);
  s = li_std_auto_ptr.takeKlassAutoPtr(kin);
  checkCount(0);
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!li_std_auto_ptr.is_nullptr(kin))
    throw new Error("is_nullptr failed");
  exception_thrown = false;
  try {
    li_std_auto_ptr.takeKlassAutoPtr(kin);
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
      throw new Error("double usage of takeKlassAutoPtr should have been an error");
  delete kin; // Should not fail, even though already deleted
  checkCount(0);
}

{
  kin = new li_std_auto_ptr.Klass("KlassInput");
  exception_thrown = false;
  notowned = li_std_auto_ptr.get_not_owned_ptr(kin);
  try {
    li_std_auto_ptr.takeKlassAutoPtr(notowned);
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
  li_std_auto_ptr.takeKlassAutoPtr(kin);
  checkCount(0);
}

{
  kini = new li_std_auto_ptr.KlassInheritance("KlassInheritanceInput");
  checkCount(1);
  s = li_std_auto_ptr.takeKlassAutoPtr(kini);
  checkCount(0);
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  if (!li_std_auto_ptr.is_nullptr(kini))
    throw new Error("is_nullptr failed");
  delete kini; // Should not fail, even though already deleted
  checkCount(0);
}

// auto_ptr as output
k1 = li_std_auto_ptr.makeKlassAutoPtr("first");
if (k1.getLabel() !== "first")
  throw new Error("wrong object label");

k2 = li_std_auto_ptr.makeKlassAutoPtr("second");
if (li_std_auto_ptr.Klass.getTotal_count() != 2)
  throw new Error("number of objects should be 2");

// delete k1;
// Above not deleting the C++ object(node v12), not sure why, use below as workaround
li_std_auto_ptr.takeKlassAutoPtr(k1);
if (li_std_auto_ptr.Klass.getTotal_count() != 1)
  throw new Error("number of objects should be 1");

if (k2.getLabel() !== "second")
  throw new Error("wrong object label");

// delete k2;
// Above not deleting the C++ object(node v12) - can't reliably control GC
li_std_auto_ptr.takeKlassAutoPtr(k2);
if (li_std_auto_ptr.Klass.getTotal_count() != 0)
  throw new Error("no objects should be left");
