module default_constructor_runme;

import default_constructor.FFF;
import default_constructor.G;

void main() {
  // D2 does not support something akin to D1/Tango dispose() for deterministic
  // destruction yet.

  // enforceThrows((){ scope g = new G(); }, "Protected destructor exception should have been thrown");
  // enforceThrows((){ scope f = new FFF(); }, "Private destructor exception should have been thrown");
}

private void enforceThrows(void delegate() dg, string errorMessage) {
  bool hasThrown;
  try {
    dg();
  } catch (Exception) {
    hasThrown = true;
  } finally {
    if (!hasThrown) {
      throw new Exception(errorMessage);
    }
  }
}
