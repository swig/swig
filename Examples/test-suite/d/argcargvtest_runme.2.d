module argcargvtest_runme;

import std.exception;
import argcargvtest.argcargvtest;

void main() {
  auto largs = ["hi", "hola", "hello"];
  enforce(mainc(largs) == 3, "calling mainc failed");

  auto targs = ["hi", "hola"];
  enforce(mainv(targs, 1) == "hola", "calling mainv failed");

// For dynamically typed languages we test this throws an exception or similar
// at runtime, but for D language this doesn't even compile (but we can't easily
// test for that here).
// mainv("hello", 1);

  initializeApp(largs);
}
