%module name_inherit
%{
class A {
};

class B : public A {
};

%}

%name(AA) class A { };
class B : public A { };

