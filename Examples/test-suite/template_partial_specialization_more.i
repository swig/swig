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
%include <std_string.i>
%inline %{
template <typename A> struct Allocator {};
template <typename T, class Alloc = Allocator<T> > struct Lyst { void primary(T, Allocator<T>) {} };
template <typename TT, class XXAlloc> struct Lyst<TT*, XXAlloc> { void specialized1(TT, XXAlloc) {} };
template <typename TTT, class YY> struct Lyst<TTT**, Allocator<YY> > { void specialized2(TTT, YY) {} };
template <typename TTTT> struct Lyst<const TTTT&> { void specialized3(TTTT) {} };

void test_list() {
    double mydouble = 0;
    short myshort = 0;
    Lyst<double>().primary(mydouble, Allocator<double>());
    Lyst<short, Allocator<short> >().primary(myshort, Allocator<short>());

    PlainStruct ps;
    int myint = 0;
    std::string mystring = 0;
    Lyst<PlainStruct *>().specialized1(ps, Allocator<PlainStruct *>());
    Lyst<double **>().specialized2(mydouble, (double **)0);
    Lyst<const int&>().specialized3(myint);
    // Specifying the default still calls the partially specialized template
    Lyst<std::string const &, Allocator<std::string const &> >().specialized3(mystring);
}
%}

%template(AllocatorDouble) Allocator<double>;
%template(AllocatorShort) Allocator<short>;
%template(AllocatorPlainStructPtr) Allocator<PlainStruct *>;

%template(LystDouble) Lyst<double>;
%template(LystShort) Lyst<short, Allocator<short> >;
%template(LystPlainStructPtr) Lyst<PlainStruct *>;
%template(LystDoublePtrPtr) Lyst<double **>; // called specialized1 instead of specialized2
%template(LystConstIntRef) Lyst<const int&>;
%template(LystConstStringRef) Lyst<const std::string&, Allocator<const std::string&> >;

%inline %{
// Both parameters in each of the functions below are the same type
void UseLystDouble(Lyst<double> a, Lyst<double, Allocator<double> > b) {}
void UseLystShort(Lyst<short> a, Lyst<short, Allocator<short> > b) {}
void UseLystPlainStructPtr(Lyst<PlainStruct *> a, Lyst<PlainStruct *, Allocator<PlainStruct *> > b) {}
void UseLystDoublePtrPtr(Lyst<double **> a, Lyst<double **, Allocator<double **> > b) {}
void UseLystConstIntRef(Lyst<const int&> a, Lyst<const int&, Allocator<const int&> > b) {}
void UseLystConstStringRef(Lyst<const std::string&> a, Lyst<const std::string&, Allocator<const std::string&> > b) {}
%}

// (6) Default args used in specialization, more variations specifying / not specifying default
%inline %{
template<typename P, typename Q = int> struct Spec { void spec_primary(P p, Q q) {} };
template<typename PP> struct Spec<const PP&, int> { void spec_specialized(PP pp) {} };
%}

%template(SpecDoubleInt) Spec<const double&, int>;
%template(SpecStringInt) Spec<const std::string&>;

%inline %{
void UseSpec1(Spec<const double&, int> x, Spec<const double&, int> y) {}
void UseSpec2(Spec<const std::string&, int> x, Spec<const std::string&, int> y) {}
void test_spec() {
  double mydouble = 0.0;
  Spec<const double&, int>().spec_specialized(mydouble);
  Spec<const double&>().spec_specialized(mydouble);

  std::string mystring;
  Spec<const std::string&, int>().spec_specialized(mystring);
  Spec<const std::string&>().spec_specialized(mystring);
}
%}
