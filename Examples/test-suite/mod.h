#include <cstddef>

class C;
class E;

class A
{
public:
    A() {}
    C* GetC() { return NULL; }
    E* GetE() { return NULL; }

    void DoSomething(A* a) {}
};


class B : public A
{
public:
  B() {}
  
};


class C : public B
{
public:
    C() {}
};


class D : public C
{
public:
    D() {}
    void SetE(E* e) {}
};
