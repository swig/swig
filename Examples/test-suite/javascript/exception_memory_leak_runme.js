var exception_memory_leak = require('exception_memory_leak');

var { Foo } = exception_memory_leak;

var a = new Foo;
if (/* await */(Foo.get_count()) != 1) throw new Error("Should have 1 Foo objects");
var b = new Foo;
if (/* await */(Foo.get_count()) != 2) throw new Error("Should have 2 Foo objects");

  // Normal behaviour
  /* await */(exception_memory_leak.trigger_internal_swig_exception("no problem", a));
if (/* await */(Foo.get_count()) != 2) throw new Error("Should have 2 Foo objects");
if (/* await */(Foo.get_freearg_count()) != 1) throw new Error("freearg should have been used once");

// SWIG exception triggered and handled (return new object case).
var fail = false;
try {
    /* await */(exception_memory_leak.trigger_internal_swig_exception("null", b));
  fail = true;
} catch { }
if (fail) throw new Error("Expected an exception");

if (/* await */(Foo.get_count()) != 2) throw new Error("Should have 2 Foo objects");
if (/* await */(Foo.get_freearg_count()) != 2) throw new Error("freearg should have been used twice");

// SWIG exception triggered and handled (return by value case).
try {
    /* await */(exception_memory_leak.trigger_internal_swig_exception("null"));
  fail = true;
} catch { }
if (fail) throw new Error("Expected an exception");

// SWIG exception triggered and handled (return by value case).
try {
    /* await */(exception_memory_leak.trigger_internal_swig_exception_c("null"));
  fail = true;
} catch { }
if (fail) throw new Error("Expected an exception");

// Throwing constructor
try {
  new exception_memory_leak.ThrowingCtorString("null");
  fail = true;
} catch { }
if (fail) throw new Error("Expected an exception");
try {
  new exception_memory_leak.ThrowingCtorChar("null");
  fail = true;
} catch { }
if (fail) throw new Error("Expected an exception");

// Throwing overloaded constructor
try {
  new exception_memory_leak.ThrowingCtorOverloaded("null");
  fail = true;
} catch (e) { }
if (fail) throw new Error("Expected an exception");

if (/* await */(Foo.get_count()) != 2) throw new Error("Should have 2 Foo objects");
if (/* await */(Foo.get_freearg_count()) != 2) throw new Error("freearg should have been used twice");

if (/* await */(Foo.get_freearg_string_count()) != 5) throw new Error("freearg string should have been used five times");
if (/* await */(Foo.get_freearg_char_count()) != 2) throw new Error("freearg char should have been used twice");
