module pointer_reference_runme;

import std.exception;
import pointer_reference.pointer_reference;
import pointer_reference.Struct;

void main() {
  Struct s = get();
  enforce(s.value == 10, "get test failed");

  auto ss = new Struct(20);
  set(ss);
  enforce(Struct.instance.value == 20, "set test failed");
}
