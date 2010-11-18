module sizet_runme;

import sizet.sizet;

void main() {
  size_t s = 2000;
  s = test1(s+1);
  s = test2(s+1);
  s = test3(s+1);
  s = test4(s+1);

  if (s != 2004) {
    throw new Exception("failed");
  }
}
