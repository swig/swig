module sneaky1_runme;

import std.exception;
import sneaky1.sneaky1;

void main() {
  enforce(add(30, 2) == 32, "add test failed");
  enforce(subtract(20, 2) == 18, "subtract test failed");
  enforce(mul(20, 2) == 40, "mul test failed");
  enforce(divide(20, 2) == 10, "div test failed");
}
