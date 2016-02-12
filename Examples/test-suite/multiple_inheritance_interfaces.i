%module  multiple_inheritance_interfaces

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%include "feature_interface.i"
DECLARE_INTERFACE_RENAME(IA, A, IA)
DECLARE_INTERFACE_RENAME(IB, B, IB)
DECLARE_INTERFACE_RENAME(IC, C, IC)
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
DECLARE_INTERFACE_RENAME(IJ, J, IJ)
DECLARE_INTERFACE_RENAME(IK, K, IK)
DECLARE_INTERFACE_RENAME(IL, L, IL)
#endif
%inline %{
struct IJ { virtual void ij() {} };
struct IK : IJ {};
struct IL : IK {};
struct M : IL {};
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
DECLARE_INTERFACE_RENAME(IQ, Q, IQ)
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
