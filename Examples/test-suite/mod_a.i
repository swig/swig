%module mod_a

%{
#include "mod.h"
%}


class C;
// Not wrapped by either module
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
    B();
};
