module li_std_auto_ptr_runme;

import li_std_auto_ptr.li_std_auto_ptr;
import li_std_auto_ptr.Klass;
import li_std_auto_ptr.KlassInheritance;
import std.conv;
import std.algorithm;

void checkCount(int expected_count) {
  int actual_count = Klass.getTotal_count();
  if (actual_count != expected_count)
    throw new Exception("Counts incorrect, expected:" ~ to!string(expected_count) ~ " actual:" ~ to!string(actual_count));
}

void main() {
  // Test raw pointer handling involving virtual inheritance
  {
    scope KlassInheritance kini = new KlassInheritance("KlassInheritanceInput");
    checkCount(1);
    string s = useKlassRawPtr(kini);
    if (s != "KlassInheritanceInput")
      throw new Exception("Incorrect string: " ~ s);
  }
  checkCount(0);

  // auto_ptr as input
  {
    scope Klass kin = new Klass("KlassInput");
    checkCount(1);
    string s = takeKlassAutoPtr(kin);
    checkCount(0);
    if (s != "KlassInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kin))
      throw new Exception("is_nullptr failed");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  {
    scope Klass kin = new Klass("KlassInput");
    checkCount(1);
    string s = takeKlassAutoPtr(kin);
    checkCount(0);
    if (s != "KlassInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kin))
      throw new Exception("is_nullptr failed");
    bool exception_thrown = false;
    try {
      takeKlassAutoPtr(kin);
    } catch (Exception e) {
      if (!canFind(e.msg, "Cannot release ownership as memory is not owned"))
        throw new Exception("incorrect exception message: " ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("double usage of takeKlassAutoPtr should have been an error");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  {
    scope Klass kin = new Klass("KlassInput");
    bool exception_thrown = false;
    Klass notowned = get_not_owned_ptr(kin);
    try {
      takeKlassAutoPtr(notowned);
    } catch (Exception e) {
      if (!canFind(e.msg, "Cannot release ownership as memory is not owned"))
        throw new Exception("incorrect exception message: " ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("Should have thrown 'Cannot release ownership as memory is not owned' error");
    checkCount(1);
  }
  checkCount(0);

  {
    scope KlassInheritance kini = new KlassInheritance("KlassInheritanceInput");
    checkCount(1);
    string s = takeKlassAutoPtr(kini);
    checkCount(0);
    if (s != "KlassInheritanceInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kini))
      throw new Exception("is_nullptr failed");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  takeKlassAutoPtr(null);
  takeKlassAutoPtr(make_null());
  checkCount(0);

  // overloaded parameters
  if (overloadTest() != 0)
    throw new Exception("overloadTest failed");
  if (overloadTest(null) != 1)
    throw new Exception("overloadTest failed");
  if (overloadTest(new Klass("over")) != 1)
    throw new Exception("overloadTest failed");
  checkCount(0);


  // auto_ptr as output
  Klass k1 = makeKlassAutoPtr("first");
  if (k1.getLabel() != "first")
    throw new Exception("wrong object label");

  Klass k2 = makeKlassAutoPtr("second");
  checkCount(2);

  k1.dispose();
  checkCount(1);

  if (k2.getLabel() != "second")
      throw new Exception("wrong object label");

  k2.dispose();
  checkCount(0);

  if (makeNullAutoPtr() !is null)
    throw new Exception("null failure");
}
