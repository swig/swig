#ifndef CLIENTDATA_TEARDOWN_H
#define CLIENTDATA_TEARDOWN_H

static int counted_dtors = 0;

struct Counted {
  int value;
  Counted(int v = 42) : value(v) {}
  ~Counted() { ++counted_dtors; }
  int get() const { return value; }
};

inline int counted_dtors_called() {
  return counted_dtors;
}

#endif
