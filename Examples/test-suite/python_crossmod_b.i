%module python_crossmod_b

%{
#include "python_crossmod.h"
%}

%import(module="python_crossmod_a") "python_crossmod_a.i"

class B {
public:
    B();
    int methB();
};

class C : public A, public B {
public:
    C();
    int methC();
};
