%module cpp17_using_typename_pack

// C++17 (P0195R2) pack expansion of a using-declaration combined with the typename
// disambiguator: 'using typename Bases::value_type ...;' imports a dependent member type
// from each base in a base pack. This combination was a syntax error before (issue #3479):
// the typename form and the pack form each parsed on their own, but not together.

%inline %{
#include <type_traits>

template <typename... Bases> struct Collector : Bases... {
#ifndef _MSC_VER
  using typename Bases::value_type ...;   // C++17 member type pack import
#else
  // Workaround for Visual C++ not implementing typename member type pack using-declarations and instead errors with C3520.
  using value_type = typename std::common_type<typename Bases::value_type...>::type;
#endif
  value_type zero() { return value_type(); }
  value_type echo(value_type v) { return v; }
};

struct IntHolder {
  typedef int value_type;
};
%}

%template(CollectorInt) Collector<IntHolder>;
