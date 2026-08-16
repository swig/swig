%module(directors="1") cpp20_concepts_directors

// GCC accepts a virt-specifier after a trailing requires-clause, and 'final' there stops a director
// overriding the member, in both the plain and the trailing return type spellings.

%feature("director") Callback<int>;

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
  virtual ~Callback() {}
};

template<typename T>
T call_plain(Callback<T> &c, T x) { return c.plain(x); }

template<typename T>
T call_arrow(Callback<T> &c, T x) { return c.arrow(x); }

template<typename T>
T call_overridable(Callback<T> &c, T x) { return c.overridable(x); }
%}

%template(CallbackInt) Callback<int>;
%template(call_plain) call_plain<int>;
%template(call_arrow) call_arrow<int>;
%template(call_overridable) call_overridable<int>;
