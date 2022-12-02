%module template_template_template_parameters

%inline %{
// Github issue #624
class CustomAttrs {
public:
  enum dattr1d {pos, vel, someCustomCaseVar, d1dLast};
};

template <class TT> 
class A {
public:
  TT attributes;
  virtual ~A() {}
};

template <template<class> class A, class T> 
class B : public A<T> {
public:
  virtual void BMethod(T t_parm, A<T> at_parm) {}
};

template <template<template<class> class, class> class Op, template<class> class X, class Y>
class C : public Op<X,Y> {
public:
  virtual void CMethod(Y y_parm, Op<X, Y> opxy_parm) {}
};

template <template<template<class K1> class K2, class K3> class L, template<class K4> class M, class N>
class D : public L<M,N> {
public:
  virtual void DMethod(N n_parm, L<M, N> lmn_parm) {}
};
%}

%{
template class A<CustomAttrs>;
template class B<A, CustomAttrs>;
template class C<B, A, CustomAttrs>;
template class D<B, A, CustomAttrs>;
%}

%template(AC) A<CustomAttrs>;
%template(BAC) B<A, CustomAttrs>;
%template(CBAC) C<B, A, CustomAttrs>;
%template(DBAC) D<B, A, CustomAttrs>;
