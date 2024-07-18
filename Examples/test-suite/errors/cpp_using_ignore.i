%module xxx

%feature("flatnested");

%ignore B::unknown1;

%{
struct B {
  void unknown1() { }
  void unknown2() { }
};
%}

%inline {
class C {
protected:
  struct D : B {
    using B::unknown1;
    using B::unknown2;
  };
};
}


