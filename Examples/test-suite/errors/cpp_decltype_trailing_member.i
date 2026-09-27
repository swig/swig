%module xxx

// A trailing return type decltype over class members or 'this' that no type can be deduced for is ignored.
struct Inner { int x; };
struct Members {
  int d;
  Inner inner;
  int ov(int) { return 1; }
  int ov(double) { return 2; }
  auto overloaded() -> decltype(ov(1)) { return 1; }
  auto member_access() -> decltype(inner.x) { return inner.x; }
  auto this_access() -> decltype(this->inner.x) { return inner.x; }

  // Not ignored: these are deduced from the members.
  int h() { return 1; }
  auto bare() -> decltype(d) { return d; }
  auto via_this() -> decltype(this->d) { return d; }
  auto call() -> decltype(h()) { return h(); }
};

struct This {
  int d;
  auto member_of_deref() -> decltype((*this).d) { return d; }
};
