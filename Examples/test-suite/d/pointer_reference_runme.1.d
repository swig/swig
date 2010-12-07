module pointer_reference_runme;

import pointer_reference.pointer_reference;
import pointer_reference.Struct;

void main() {
  Struct s  = get();
  if (s.value != 10) throw new Exception("get test failed");

  Struct ss = new Struct(20);
  set(ss);
  if (Struct.instance.value != 20) throw new Exception("set test failed");
}
