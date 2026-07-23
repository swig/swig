%module cpp17_using_pack_alias_template

// A C++17 using-declaration pack whose base is an alias template pack ('struct ... : Identity<Ts>...').
// The identity alias template 'Identity<T> = T' resolves for each expanded base, so the pack
// using-declaration reaches every base.  Two faces are covered:
//   - bringing inherited member functions into scope ('using Identity<Ts>::g...;')
//   - bringing inherited constructors into scope ('using Identity<Ts>::Identity...;'), the alias
//     template analogue of cpp17_inheriting_constructors_pack, which inherits through direct bases
// As documented for alias templates, each alias instantiation is registered with an empty %template().
// cpp17_using_pack_expansion covers the member-function pack over direct bases.

// The instantiated classes have multiple bases, so target languages that wrap multiple inheritance
// with a single proxy plus mix-in methods report their usual multiple inheritance notes.
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) Over<A, B>;
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) CtorWrap<CtorA, CtorB>;

%inline %{
template <class T> using Identity = T;
%}

// D wraps multiple inheritance as single inheritance plus mix-in methods, but marks the g(int)
// overload inherited from the second base 'override', which ldmd2 rejects as it overrides nothing.
// Drop Over's imported g overload set for D; the rest of the proxy still builds and is exercised.
#if defined(SWIGD)
%ignore Over<A, B>::g;
#endif

%inline %{
struct A {
  int g() { return 1; }
};
struct B {
  int g(int x) { return x; }
};

#ifndef _MSC_VER
template <class... Ts> struct Over : Identity<Ts>... {
  using Identity<Ts>::g...;
};
#else
// Workaround for Visual C++ rejecting an alias template (Identity<Ts>) as a base class in a pack
// expansion with C3770; inherit from the underlying type Ts directly, since Identity<T> is T.
template <class... Ts> struct Over : Ts... {
  using Ts::g...;
};
#endif
%}

%template() Identity<A>; // register the alias template instantiations used as Over's expanded bases
%template() Identity<B>;
%template(OverAB) Over<A, B>;

// Inheriting-constructor pack through the alias template base pack.  The alias instantiations must be
// registered before the derived class so the inherited constructors recognise them as bases.
%inline %{
static int g_last_ctor = 0;

struct CtorA {
  CtorA() {}
  CtorA(int a) { g_last_ctor = 100 + a; }
};
struct CtorB {
  CtorB() {}
  CtorB(int a, int b) { g_last_ctor = 200 + a + b; }
};
%}

%template() Identity<CtorA>; // register the alias template instantiations used as CtorWrap's bases
%template() Identity<CtorB>;

%inline %{
#ifndef _MSC_VER
template <class... Ts> struct CtorWrap : Identity<Ts>... {
  using Identity<Ts>::Identity...;
};
#else
// Workaround for Visual C++ rejecting an alias template base in a pack expansion (C3770).
template <class... Ts> struct CtorWrap : Ts... {
  using Ts::Ts...;
};
#endif

int last_ctor() { return g_last_ctor; }
%}

%template(CtorWrapIS) CtorWrap<CtorA, CtorB>;
