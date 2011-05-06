module constover_runme;

import std.exception;
import constover.constover;
import constover.Foo;

void main() {
  enforce(test("test") == "test", "test failed!");
  enforce(test_pconst("test") == "test_pconst", "test_pconst failed!");

  auto f = new Foo();
  enforce(f.test("test") == "test", "member-test failed!");
  enforce(f.test_pconst("test") == "test_pconst", "member-test_pconst failed!");
  enforce(f.test_constm("test") == "test_constmethod", "member-test_constm failed!");
  enforce(f.test_pconstm("test") == "test_pconstmethod", "member-test_pconstm failed!");
}
