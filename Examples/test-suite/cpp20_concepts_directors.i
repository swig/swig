%module(directors="1") cpp20_concepts_directors

// GCC accepts a virt-specifier after a trailing requires-clause, and 'final' there stops a director
// overriding the member, in both the plain and the trailing return type spellings.  A final
// override of an inherited virtual member stops it too, rather than leaving the base's entry.

%feature("director") Callback<int>;
%feature("director") Inherited<int>;

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

// Only GCC accepts a trailing requires-clause on a virtual function, so other compilers see the member without one.
#if defined(SWIG) || (defined(__GNUC__) && !defined(__clang__))
#define REQUIRES_NUMERIC(T) requires Numeric<T>
#else
#define REQUIRES_NUMERIC(T)
#endif

template<typename T>
struct Callback {
  virtual T plain(T x) REQUIRES_NUMERIC(T) final { return x + 1; }
  virtual auto arrow(T x) -> T REQUIRES_NUMERIC(T) final { return x + 2; }
  virtual T overridable(T x) { return x + 3; }
  virtual auto arrow_over(T x) -> T REQUIRES_NUMERIC(T) { return x + 4; }
  virtual T plain_over(T x) { return x + 5; }
  virtual ~Callback() {}
};

// A final override of an inherited virtual member, spelt with and without the virtual keyword.
template<typename T>
struct Inherited : Callback<T> {
  auto arrow_over(T x) -> T REQUIRES_NUMERIC(T) final { return x + 20; }
  virtual T plain_over(T x) final { return x + 30; }
};

template<typename T>
T call_arrow_over(Inherited<T> &c, T x) { return c.arrow_over(x); }

template<typename T>
T call_plain_over(Inherited<T> &c, T x) { return c.plain_over(x); }

template<typename T>
T call_plain(Callback<T> &c, T x) { return c.plain(x); }

template<typename T>
T call_arrow(Callback<T> &c, T x) { return c.arrow(x); }

template<typename T>
T call_overridable(Callback<T> &c, T x) { return c.overridable(x); }
%}

%template(CallbackInt) Callback<int>;
%template(InheritedInt) Inherited<int>;
%template(call_arrow_over) call_arrow_over<int>;
%template(call_plain_over) call_plain_over<int>;
%template(call_plain) call_plain<int>;
%template(call_arrow) call_arrow<int>;
%template(call_overridable) call_overridable<int>;
