%module  multiple_inheritance_interfaces

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%include "swiginterface.i"
%interface_custom("A", "IA", IA)
%interface_custom("B", "IB", IB)
%interface_custom("%(strip:[I])s", "I%s", IC) // same as %interface_custom("C", "IC", IC)
#endif
%inline %{
struct IA {
  virtual void ia() {};
  virtual void ia(const char *s, bool b = true) {}
  virtual void ia(int i) {}
};
struct IB { virtual void ib() {} };
struct IC : IA, IB {};
struct D : IC {};
struct E : D {};
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface_custom("J", "IJ", IJ)
%interface_custom("K", "IK", IK)
%interface_custom("L", "IL", IL)
#endif
%inline %{
struct IJ { virtual void ij() {} };
struct IK : IJ {};
struct IL : IK {};
struct M : IL {};
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface_custom("Q", "IQ", IQ)
#endif
%inline %{
struct P { virtual void p() {}; };
struct IQ { virtual void iq() {}; };
struct R : IQ, P {};
struct S : P, IQ {};
struct T : IQ {};
struct U : R {};
struct V : S {};
struct W : T {};
%}
