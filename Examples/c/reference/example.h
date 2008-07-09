#include <stdio.h>

class Bar {
private:
  int x;
public:
  Bar() : x(0) {}
  ~Bar() {}
  void set(int x) { this->x = x; }
  int get() { return x; }
};

void foo_by_val(Bar bar);
void foo_by_ref(Bar& bar);
void foo_by_ptr(Bar* bar);

