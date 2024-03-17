%module cpp11_type_aliasing

// Type aliasing seg fault : Github issue #424

%inline %{
namespace Halide {

struct Target {
  int bits;
  Target(int bits=32) : bits(bits) {}
};

class NamesInterface {
public:
  using Target = Halide::Target;
};

Target get_host_target() { 
  return Target();
}

namespace Internal {

template <typename T> class GeneratorParam {
  T value;
public:
  GeneratorParam(const char *name, const T &v) : value(v) {}

  T getValue() { 
    return value;
  }
};

class GeneratorBase : public NamesInterface {
public:
  GeneratorParam<Target> target{ "target", Halide::get_host_target() };
};

}
}
%}

%template(Halide_Target) Halide::Internal::GeneratorParam<Halide::Target>;


%inline %{
using HalideTargetPtr1 = Halide::Target*;
namespace Halide {
  using HalideTargetPtr2 = Target*;
}
%}

// Define some types

%inline %{
using Int = int;
using IntPtr = Int*;
using IntRef = Int&;
using IntPtrRef = Int*&;
using IntRValueRef = Int&&;
using IntArray = Int[];
%}

// Test that SWIG understands these new types

%{
Int mult2(Int x) { return x * 2; }
%}
%callback("%s_cb");
Int mult2(Int x);
%nocallback;

%inline %{
IntPtr allocate_int() { return new Int(12); }
void free_int(int* ptr) { delete ptr; }
void inplace_mult2(IntRef x) { x *= 2; }
Int read_int(IntPtr ptr) { return *ptr; }

template <typename T> class Pair {
public:
  using data_t = T;

  data_t a, b;

  Pair() : a(), b() { }
  Pair(data_t a, data_t b) : a(a), b(b) { }
  data_t first() { return a; }
  data_t second() { return b; }
};
%}

%template(int_pair) Pair<Int>;

%inline %{
using PairInt = Pair<Int>;

class PairSubclass : public PairInt {
public:
  PairSubclass(data_t a, data_t b) : PairInt(a, b) { }

  using const_ref_data_t = const data_t&;
};

PairSubclass::data_t plus1(PairSubclass::const_ref_data_t x) { return x + 1; }
%}

// Test function pointers

%inline %{
using callback_t = int(*)(int);

callback_t get_callback() { return mult2; }
int call(callback_t funk, int param) { return funk(param); }
%}


// Template template parameters - from #1021
%inline %{
#include <type_traits>

class Node {};
struct AnyVal { typedef AnyVal Super; };

template<template<typename D, typename O> class C, typename T, typename Super, typename Root, typename O>
  using DeriveToBase = typename std::conditional<std::is_same<T, AnyVal>::value, Root, C<Super, O> >::type;

template<class T, class Root, class RParent>
  using ImmediateBase = typename std::conditional<std::is_same<T, AnyVal>::value, Root, RParent >::type;

template<class D, typename _Super=AnyVal> class Expression {
  typedef _Super Super;
};

void TestInstantiationsPart4() {
  Expression<AnyVal, AnyVal::Super> express;
  (void)express;
  DeriveToBase<Expression, AnyVal, AnyVal, AnyVal, AnyVal> derive_to_base = AnyVal();
}
%}

#if 0
// TODO define and instantiate std::conditional and std::is_same
%template(ExpressionInstantiation) Expression<AnyVal, AnyVal::Super>;
%template(AnyTypeInstantiation) DeriveToBase<Expression, AnyVal, AnyVal, AnyVal, AnyVal>;

%inline %{
AnyVal takeAnyVal(DeriveToBase<Expression, AnyVal, AnyVal, AnyVal, AnyVal> av) {
  return av;
}
%}
#endif
