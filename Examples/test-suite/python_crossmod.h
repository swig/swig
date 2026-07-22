class A {
public:
    A() {}
    int methA() { return 1; }
};

class B {
public:
    B() {}
    int methB() { return 2; }
};

class C : public A, public B {
public:
    C() {}
    int methC() { return 3; }
};
