module virtual_poly_runme;

import std.exception;
import virtual_poly.NDouble;
import virtual_poly.NInt;
import virtual_poly.NNumber;

void main() {
  // D supports covariant (polymorphic) return types, so this should work like
  // in C++.
  auto d = new NDouble(3.5);
  NDouble dc = d.copy();
  enforce(d.get() == dc.get(), "Test 1 failed.");

  auto i = new NInt(2);
  NInt ic = i.copy();
  enforce(i.get() == ic.get(), "Test 2 failed.");

  NNumber n = d;
  auto nd = cast(NDouble) n.copy();
  enforce(nd.get() == d.get(), "Test 3 failed.");
}
