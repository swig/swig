module varargs_runme;

import std.exception;
import varargs.varargs;
import varargs.Foo;

void main() {
  enforce(test("Hello") == "Hello", "Test 1 failed");

  auto f = new Foo("Greetings");
  enforce(f.str == "Greetings", "Test 2 failed");
  enforce(f.test("Hello") == "Hello", "Test 3 failed");
}
