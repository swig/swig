module sneaky1_runme;

import sneaky1.sneaky1;

void main() {
  if (add(30, 2) != 32) {
    throw new Exception("add test failed");
  }

  if (subtract(20, 2) != 18) {
    throw new Exception("subtract test failed");
  }

  if (mul(20, 2) != 40) {
    throw new Exception("mul test failed");
  }

  if (divide(20, 2) != 10) {
    throw new Exception("div test failed");
  }
}
