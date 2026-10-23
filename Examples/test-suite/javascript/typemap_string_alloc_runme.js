var typemap_string_alloc = require("typemap_string_alloc");

function check(actual, expected) {
  if (actual !== expected)
    throw new Error("Expected " + expected + ", got " + actual);
}

typemap_string_alloc.Custom_Reset();
typemap_string_alloc.some_text = "one";
typemap_string_alloc.some_text = "two";

check(typemap_string_alloc.Custom_WasAllocated(), true);
check(typemap_string_alloc.Custom_WasDeallocated(), true);
