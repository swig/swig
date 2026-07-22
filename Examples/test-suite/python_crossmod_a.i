%module python_crossmod_a

%{
#include "python_crossmod.h"
%}

class A {
public:
    A();
    int methA();
};
