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

// Also when only the text skipped in a subscript or the arguments of a call names one.
Inner inners[2];
int overloaded(int);
int overloaded(double);
struct Skipped {
  int idx;
  auto index() -> decltype(inners[idx].x) { return inners[idx].x; }
  auto this_index() -> decltype(inners[this->idx].x) { return inners[idx].x; }
  auto argument() -> decltype(overloaded(idx)) { return overloaded(idx); }
};

// A call is overloaded even where %ignore or %rename leaves the target language only one of the overloads.
%ignore IgnoredOverload::ov(double);
%rename(ov_double) RenamedOverload::ov(double);
struct IgnoredOverload {
  double ov(double) { return 2.5; }
  int ov(int) { return 1; }
  auto call() -> decltype(ov(1)) { return ov(1); }
};
struct RenamedOverload {
  int ov(int) { return 1; }
  double ov(double) { return 2.5; }
  auto call() -> decltype(ov(1.5)) { return ov(1.5); }
};
