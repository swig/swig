var li_std_auto_ptr = require("li_std_auto_ptr");

var checkCount = /* async */ function(expected_count) {
  var actual_count = /* await */(li_std_auto_ptr.Klass.getTotal_count());
  if (actual_count != expected_count)
    throw new Error("Counts incorrect, expected:" + expected_count + " actual:" + actual_count);
}

// Test raw pointer handling involving virtual inheritance
{
  var kini = new li_std_auto_ptr.KlassInheritance("KlassInheritanceInput");
  /* await */(checkCount(1));
  var s = /* await */(li_std_auto_ptr.useKlassRawPtr(kini));
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);

  /* await */(li_std_auto_ptr.takeKlassAutoPtr(kini));
  /* await */(checkCount(0));
}


// auto_ptr as input
{
  var kin = new li_std_auto_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(li_std_auto_ptr.takeKlassAutoPtr(kin));
  /* await */(checkCount(0));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!/* await */(li_std_auto_ptr.is_nullptr(kin)))
    throw new Error("is_nullptr failed");
  /* await */(checkCount(0));
}

{
  kin = new li_std_auto_ptr.Klass("KlassInput");
  /* await */(checkCount(1));
  s = /* await */(li_std_auto_ptr.takeKlassAutoPtr(kin));
  /* await */(checkCount(0));
  if (s !== "KlassInput")
    throw new Error("Incorrect string: " + s);
  if (!/* await */(li_std_auto_ptr.is_nullptr(kin)))
    throw new Error("is_nullptr failed");
  var exception_thrown = false;
  try {
    /* await */(li_std_auto_ptr.takeKlassAutoPtr(kin));
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
      throw new Error("double usage of takeKlassAutoPtr should have been an error");
  /* await */(checkCount(0));
}

{
  kin = new li_std_auto_ptr.Klass("KlassInput");
  exception_thrown = false;
  var notowned = /* await */(li_std_auto_ptr.get_not_owned_ptr(kin));
  try {
    /* await */(li_std_auto_ptr.takeKlassAutoPtr(notowned));
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
    throw new Error("Should have thrown 'Cannot release ownership as memory is not owned' error");
  /* await */(checkCount(1));

  /* await */(li_std_auto_ptr.takeKlassAutoPtr(kin));
  /* await */(checkCount(0));
}

{
  kini = new li_std_auto_ptr.KlassInheritance("KlassInheritanceInput");
  /* await */(checkCount(1));
  s = /* await */(li_std_auto_ptr.takeKlassAutoPtr(kini));
  /* await */(checkCount(0));
  if (s !== "KlassInheritanceInput")
    throw new Error("Incorrect string: " + s);
  if (!/* await */(li_std_auto_ptr.is_nullptr(kini)))
    throw new Error("is_nullptr failed");
  /* await */(checkCount(0));
}

/* await */(li_std_auto_ptr.takeKlassAutoPtr(null));
/* await */(li_std_auto_ptr.takeKlassAutoPtr(/* await */(li_std_auto_ptr.make_null())));
/* await */(checkCount(0));

// overloaded parameters
if (/* await */(li_std_auto_ptr.overloadTest()) != 0)
  throw new Error("overloadTest failed");
if (/* await */(li_std_auto_ptr.overloadTest(null)) != 1)
  throw new Error("overloadTest failed");
if (/* await */(li_std_auto_ptr.overloadTest(new li_std_auto_ptr.Klass("over"))) != 1)
  throw new Error("overloadTest failed");
/* await */(checkCount(0));

// auto_ptr as output
var k1 = /* await */(li_std_auto_ptr.makeKlassAutoPtr("first"));
if (/* await */(k1.getLabel()) !== "first")
  throw new Error("wrong object label");

var k2 = /* await */(li_std_auto_ptr.makeKlassAutoPtr("second"));
/* await */(checkCount(2));


/* await */(li_std_auto_ptr.takeKlassAutoPtr(k1));
/* await */(checkCount(1));

if (/* await */(k2.getLabel()) !== "second")
  throw new Error("wrong object label");

/* await */(li_std_auto_ptr.takeKlassAutoPtr(k2));

if (/* await */(li_std_auto_ptr.makeNullAutoPtr()) != null)
  throw new Error("null failure");

/* await */(checkCount(0));
