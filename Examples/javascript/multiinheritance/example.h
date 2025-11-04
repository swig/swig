/* File : example.h */

class A {
public:
  A() {
    count++;
  }
  virtual ~A() {
    count--;
  }

  static  int count;
};

class B : public A {
public:
  enum Color {BLUE, RED, GREEN} b;
  B(Color col) : b(col) { }
  
};

class C : public A {
public:
  enum Color {RED, GREEN, BLUE} c;
  C(Color col) : c(col) { }
};

class D : public B, public C {
public:
  D(int col) : B((B::Color)col), C((C::Color)col) { }
};

class E : public C, public B {
public:
  E(int col) : C((C::Color)col), B((B::Color)col) { }
};
