module constover_runme;

import constover.constover;
import constover.Foo;

void main() {
  char[] p = test("test");
  if (p != "test")
    throw new Exception("test failed!");

  p = test_pconst("test");
  if (p != "test_pconst")
    throw new Exception("test_pconst failed!");

  auto f = new Foo();
  p = f.test("test");
  if (p != "test")
    throw new Exception("member-test failed!");

  p = f.test_pconst("test");
  if (p != "test_pconst")
    throw new Exception("member-test_pconst failed!");

  p = f.test_constm("test");
  if (p != "test_constmethod")
    throw new Exception("member-test_constm failed!");

  p = f.test_pconstm("test");
  if (p != "test_pconstmethod")
    throw new Exception("member-test_pconstm failed!");
}
