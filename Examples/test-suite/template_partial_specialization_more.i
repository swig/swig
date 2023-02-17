%module template_partial_specialization_more


// (1) Based on https://stackoverflow.com/questions/9757642/wrapping-specialised-c-template-class-with-swig
%inline %{
template<typename V> struct Vect {};
template<class T, typename TT>
class Foo {
public:
    Foo() {}
    virtual ~Foo() {}
    T primary() const { return T(); }
};

template<class TS, typename TTS>
class Foo<Vect<TS>, TTS> {
public:
    Foo() {}
    virtual ~Foo() {}
    TS partially_specialized(TS parmin) const { return parmin; }
};
template<>
class Foo<Vect<double>, double> {
public:
    Foo() {}
    virtual ~Foo() {}
    double value_fully_specialized(double d) const { return d; }
};
template<class T, typename TT>
class Foo<T*, TT> {
public:
    Foo() {}
    virtual ~Foo() {}
    int pointer_specialize(T myT) const { return 0; }
};
%}
%template(VectInt) Vect<int>;
%template(FooVectIntDouble) Foo<Vect<int>, double>; // was failing
%template(FooShortPtrDouble) Foo<short*, double>;
%template(FooVectVectInt) Foo<Vect<Vect<int> >, int>; // was failing


// (2) Same types in both args
%inline %{
template<typename X, typename Y> struct Hey { void primary() {} };
template<typename T> struct Hey<T, T> { void special_hey() {} };
%}
%template(HeyInts) Hey<int, int>; // was failing, was calling primary


// (3) Partial specialization using one template parameter instead of two
%inline %{
  struct PlainStruct {};
  template <typename T, typename U> struct XX { void primary() {} };
  template <typename T> struct XX<T, T &> { void special1() {} };         // r.$1
  template <typename T> struct XX<T, T const&> { void special2() {} };    // r.q(const).$1
  template <typename T> struct XX<T, T *const&> { void special3() {} };   // r.q(const).p.$1
%}
%template(XX1) XX<int, int&>; // was failing, was calling primary
%template(XX2) XX<int, int const&>;
%template(XX3) XX<PlainStruct, PlainStruct *const&>;


// (4) Switching parameters around
%inline %{
#include <iostream>
template<typename P1 = int, typename P2 = double> struct Partialler { void primary(P1, P2) {}; };
template<typename S1, typename S2> struct Partialler<S2, S1*> { void special(S1*, S2, bool) {}; };
%}
%template(PartiallerPrimary) Partialler<short, short>;
%template(PartiallerSpecial) Partialler<int, PlainStruct*>;


// (5) Default args used in specialization, like std::list
%inline %{
template <typename A> struct Allocator {};
template <typename T, class Alloc = Allocator<T> > struct Lyst { void primary(T, Allocator<T>) {} };
template <typename TT, class XXAlloc> struct Lyst<TT*, XXAlloc> { void specialized1(TT, XXAlloc) {} };
template <typename TTT, class YY> struct Lyst<TTT**, Allocator<YY> > { void specialized2(TTT, YY) {} };
// TODO  Error: Inconsistent argument count in template partial specialization. 1 2
//template <typename TTTT> struct Lyst<const TTTT&> { void specialized3(TTTT) {} };
void test_list() {
    int myint = 0;
    Lyst<int> lis;
    lis.primary(myint, Allocator<int>());

    PlainStruct ps;
    Lyst<PlainStruct *> liss;
    liss.specialized1(ps, Allocator<PlainStruct *>());

    double mydouble = 0;
    Lyst<double **> lissd;
    lissd.specialized2(mydouble, (double **)0);

//    Lyst<const int&> lissconstint;
//    lissconstint.specialized3(myint);
}
%}

%template(LystDouble) Lyst<double>;
//%template(LystDouble) Lyst<short, Allocator<short> >;
%template(LystPlainStructPtr) Lyst<PlainStruct *>;
%template(LystDoublePtrPtr) Lyst<double **>; // called specialized1 instead of specialized2
