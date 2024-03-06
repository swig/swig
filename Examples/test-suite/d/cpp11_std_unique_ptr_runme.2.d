module cpp11_std_unique_ptr_runme;

import cpp11_std_unique_ptr.cpp11_std_unique_ptr;
import cpp11_std_unique_ptr.Klass;
import cpp11_std_unique_ptr.KlassInheritance;
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

  ///// INPUT BY VALUE /////
  // unique_ptr as input
  {
    scope Klass kin = new Klass("KlassInput");
    checkCount(1);
    string s = takeKlassUniquePtr(kin);
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
    string s = takeKlassUniquePtr(kin);
    checkCount(0);
    if (s != "KlassInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kin))
      throw new Exception("is_nullptr failed");
    bool exception_thrown = false;
    try {
      takeKlassUniquePtr(kin);
    } catch (Exception e) {
      if (!canFind(e.msg, "Cannot release ownership as memory is not owned"))
        throw new Exception("incorrect exception message: " ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("double usage of takeKlassUniquePtr should have been an error");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  {
    scope Klass kin = new Klass("KlassInput");
    bool exception_thrown = false;
    Klass notowned = get_not_owned_ptr(kin);
    try {
      takeKlassUniquePtr(notowned);
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
    string s = takeKlassUniquePtr(kini);
    checkCount(0);
    if (s != "KlassInheritanceInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kini))
      throw new Exception("is_nullptr failed");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  takeKlassUniquePtr(null);
  takeKlassUniquePtr(make_null());
  checkCount(0);

  // overloaded parameters
  if (overloadTest() != 0)
    throw new Exception("overloadTest failed");
  if (overloadTest(null) != 1)
    throw new Exception("overloadTest failed");
  if (overloadTest(new Klass("over")) != 1)
    throw new Exception("overloadTest failed");
  checkCount(0);


  ///// INPUT BY RVALUE REF /////
  // unique_ptr as input
  {
    scope Klass kin = new Klass("KlassInput");
    checkCount(1);
    string s = moveKlassUniquePtr(kin);
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
    string s = moveKlassUniquePtr(kin);
    checkCount(0);
    if (s != "KlassInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kin))
      throw new Exception("is_nullptr failed");
    bool exception_thrown = false;
    try {
      moveKlassUniquePtr(kin);
    } catch (Exception e) {
      if (!canFind(e.msg, "Cannot release ownership as memory is not owned"))
        throw new Exception("incorrect exception message: " ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("double usage of moveKlassUniquePtr should have been an error");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  {
    scope Klass kin = new Klass("KlassInput");
    bool exception_thrown = false;
    Klass notowned = get_not_owned_ptr(kin);
    try {
      moveKlassUniquePtr(notowned);
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
    string s = moveKlassUniquePtr(kini);
    checkCount(0);
    if (s != "KlassInheritanceInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kini))
      throw new Exception("is_nullptr failed");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  moveKlassUniquePtr(null);
  moveKlassUniquePtr(make_null());
  checkCount(0);

  // overloaded parameters
  if (moveOverloadTest() != 0)
    throw new Exception("moveOverloadTest failed");
  if (moveOverloadTest(null) != 1)
    throw new Exception("moveOverloadTest failed");
  if (moveOverloadTest(new Klass("over")) != 1)
    throw new Exception("moveOverloadTest failed");
  checkCount(0);


  ///// INPUT BY NON-CONST LVALUE REF /////
  // unique_ptr as input
  {
    scope Klass kin = new Klass("KlassInput");
    checkCount(1);
    string s = moveRefKlassUniquePtr(kin);
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
    string s = moveRefKlassUniquePtr(kin);
    checkCount(0);
    if (s != "KlassInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kin))
      throw new Exception("is_nullptr failed");
    bool exception_thrown = false;
    try {
      moveRefKlassUniquePtr(kin);
    } catch (Exception e) {
      if (!canFind(e.msg, "Cannot release ownership as memory is not owned"))
        throw new Exception("incorrect exception message: " ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("double usage of moveRefKlassUniquePtr should have been an error");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  {
    scope Klass kin = new Klass("KlassInput");
    bool exception_thrown = false;
    Klass notowned = get_not_owned_ptr(kin);
    try {
      moveRefKlassUniquePtr(notowned);
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
    string s = moveRefKlassUniquePtr(kini);
    checkCount(0);
    if (s != "KlassInheritanceInput")
      throw new Exception("Incorrect string: " ~ s);
    if (!is_nullptr(kini))
      throw new Exception("is_nullptr failed");
  } // dispose should not fail, even though already deleted
  checkCount(0);

  moveRefKlassUniquePtr(null);
  moveRefKlassUniquePtr(make_null());
  checkCount(0);

  // overloaded parameters
  if (moveRefOverloadTest() != 0)
    throw new Exception("moveRefOverloadTest failed");
  if (moveRefOverloadTest(null) != 1)
    throw new Exception("moveRefOverloadTest failed");
  if (moveRefOverloadTest(new Klass("over")) != 1)
    throw new Exception("moveRefOverloadTest failed");
  checkCount(0);


  ///// INPUT BY CONST LVALUE REF /////
  // unique_ptr as input
  {
    scope Klass kin = new Klass("KlassInput");
    checkCount(1);
    string s = useRefKlassUniquePtr(kin);
    checkCount(1);
    if (s != "KlassInput")
      throw new Exception("Incorrect string: " ~ s);
  }
  checkCount(0);

  {
    scope KlassInheritance kini = new KlassInheritance("KlassInheritanceInput");
    checkCount(1);
    string s = useRefKlassUniquePtr(kini);
    checkCount(1);
    if (s != "KlassInheritanceInput")
      throw new Exception("Incorrect string: " ~ s);
  }
  checkCount(0);

  useRefKlassUniquePtr(null);
  useRefKlassUniquePtr(make_null());
  checkCount(0);

  // overloaded parameters
  if (useRefOverloadTest() != 0)
    throw new Exception("useRefOverloadTest failed");
  if (useRefOverloadTest(null) != 1)
    throw new Exception("useRefOverloadTest failed");
  {
    scope Klass kin = new Klass("over");
    if (useRefOverloadTest(kin) != 1)
      throw new Exception("useRefOverloadTest failed");
    checkCount(1);
  }
  checkCount(0);


  // unique_ptr as output
  Klass k1 = makeKlassUniquePtr("first");
  if (k1.getLabel() != "first")
    throw new Exception("wrong object label");

  Klass k2 = makeKlassUniquePtr("second");
  checkCount(2);

  k1.dispose();
  checkCount(1);

  if (k2.getLabel() != "second")
      throw new Exception("wrong object label");

  k2.dispose();
  checkCount(0);

  if (makeNullUniquePtr() !is null)
    throw new Exception("null failure");

  // unique_ptr as output (rvalue ref)
  k1 = makeRVRKlassUniquePtr("first");
  if (k1.getLabel() != "first")
    throw new Exception("wrong object label");
  k1 = makeRVRKlassUniquePtr(null);
  if (k1 !is null)
    throw new Exception("not null");

  // unique_ptr as output (lvalue ref)
  k1 = makeRefKlassUniquePtr("lvalueref");
  if (k1.getLabel() != "lvalueref")
    throw new Exception("wrong object label");
  k1 = makeRefKlassUniquePtr(null);
  if (k1 !is null)
    throw new Exception("not null");
}
