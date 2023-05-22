module argcargvtest_runme;

import std.exception;
import argcargvtest.argcargvtest;

void main() {
  auto largs = ["hi", "hola", "hello"];
  enforce(mainc(largs) == 3, "calling mainc failed");

  auto targs = ["hi", "hola"];
  enforce(mainv(targs, 0) == "hi", "calling mainv failed");
  enforce(mainv(targs, 1) == "hola", "calling mainv failed");

// For dynamically typed languages we test this throws an exception or similar
// at runtime, but for D language this doesn't even compile (but we can't easily
// test for that here).
// mainv("hello", 1);

  initializeApp(largs);

  // Check that an empty array works.
  string[] empty_args;
  enforce(mainc(empty_args) == 0, "calling mainc failed");

  // Check that empty strings are handled.
  auto empty_string = ["hello", "", "world"];
  enforce(mainc(empty_string) == 3, "calling mainc failed");
  enforce(mainv(empty_string, 0) == "hello", "calling mainv failed");
  enforce(mainv(empty_string, 1) == "", "calling mainv failed");
  enforce(mainv(empty_string, 2) == "world", "calling mainv failed");
}
