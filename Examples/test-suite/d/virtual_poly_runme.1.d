module virtual_poly_runme;

import virtual_poly.NDouble;
import virtual_poly.NInt;
import virtual_poly.NNumber;

void main() {
  // D supports covariant (polymorphic) return types, so this should work like
  // in C++.
  auto d = new NDouble(3.5);
  NDouble dc = d.copy();
  if (d.get() != dc.get()) {
    throw new Exception("Test 1 failed.");
  }

  auto i = new NInt(2);
  NInt ic = i.copy();
  if (i.get() != ic.get()) {
    throw new Exception("Test 2 failed.");
  }

  NNumber n = d;
  auto nd = cast(NDouble) n.copy();
  if (nd.get() != d.get()) {
    throw new Exception("Test 3 failed.");
  }
}
