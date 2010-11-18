/// This is the bool runtime testcase. It checks that the C++ bool type works.
module bools_runme;

import bools.bools;

void main() {
  bool t = true;
  bool f = false;

  check_bo(f);
  check_bo(t);
}

void check_bo(bool input) {
  for (int i = 0; i < 1000; ++i) {
    if (bo(input) != input) {
      throw new Exception("Runtime test check_bo failed.");
    }
  }
}
