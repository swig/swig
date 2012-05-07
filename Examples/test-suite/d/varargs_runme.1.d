module varargs_runme;

import varargs.varargs;
import varargs.Foo;

void main() {
  if (test("Hello") != "Hello") {
    throw new Exception("Test 1 failed");
  }

  auto f = new Foo("Greetings");

  if (f.str != "Greetings") {
    throw new Exception("Test 2 failed");
  }

  if (f.test("Hello") != "Hello") {
    throw new Exception("Test 3 failed");
  }
}
