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

Bar foo_ret_val();
Bar& foo_ret_ref(Bar& bar);
Bar* foo_ret_ptr(Bar* bar);

