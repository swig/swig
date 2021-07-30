%module xxx

// Constructors, destructors and static methods cannot have qualifiers
struct A {
  ~A() const;
};
struct B {
  virtual ~B() const;
};
struct C {
  ~C() &;
};
struct D {
  virtual ~D() &;
};
struct E {
  ~E() &&;
};
struct F {
  virtual ~F() &&;
};

struct J {
  J() const;
  J(int) const;
};
struct K {
  K() &;
  K(int) &;
};
struct L {
  L() &&;
  L(int) &&;
};

struct M {
  static void m1() const;
  static void m2() &;
  thread_local static void m3() &&;
  static auto m4() const -> int;
  static auto m5() & -> int;
  static auto m6() && -> int;
};
