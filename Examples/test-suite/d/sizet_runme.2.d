module sizet_runme;

import std.exception;
import sizet.sizet;

void main() {
  size_t s = 2000;
  s = test1(s+1);
  s = test2(s+1);
  s = test3(s+1);
  s = test4(s+1);

  enforce(s == 2004, "failed");
}
