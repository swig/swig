%module cpp20_concepts_extra

// Additional C++20 concept and requires-clause forms beyond the core suite:
// negation via parens, multi parameter requires-expression with mixed types,
// fold-expression over a pack (variadic concept), type trait primary, and
// deeper nesting of '&&' / '||' inside parens.

%inline %{
#include <concepts>
#include <type_traits>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<typename T>
concept Sized = (sizeof(T) <= 8);

// Negation of a concept-id is not a primary-expression in C++20; the user
// must wrap it in parens.  A struct that is not Numeric satisfies the
// constraint, so the function instantiates only for non-numeric types.
struct Tag {
  int n;
  Tag(int v) : n(v) {}
  int value() const { return n; }
};

template<typename T>
T identity_non_numeric(T x) requires (!Numeric<T>) { return x; }

// Multi parameter requires-expression mixing two unrelated template
// parameters, exercising the requirement-parameter-list with more than one
// parm of differing type.
template<typename T, typename U>
T mix_add(T a, U b) requires requires(T t, U u) { t + u; } {
  return a + (T)b;
}

// Variadic concept defined by a fold-expression over '&&' on a pack.
template<typename... Ts>
concept AllNumeric = (Numeric<Ts> && ...);

// Variadic function template constrained by the variadic concept.  The base
// case is unconstrained; the recursive case adds the constraint.
template<typename T>
T sum_all(T t) { return t; }

template<typename T, typename... Rest>
T sum_all(T first, Rest... rest) requires AllNumeric<T, Rest...> {
  return first + sum_all<T>((T)rest...);
}

// Type trait primary - 'std::is_integral_v<T>' is a constexpr bool, used
// here as a constraint atom rather than a concept-id.
template<typename T>
T trait_primary(T x) requires std::is_integral_v<T> { return x + x; }

// Deeper nesting of '&&' and '||' inside parens.
template<typename T>
T deeper(T x) requires (Numeric<T> && (Sized<T> || std::is_pointer_v<T>)) {
  return x;
}

// Both prefix AND trailing requires-clauses on the same function template.
// Per [temp.constr.decl]/3 the C++20 standard conjoins the two; the parser
// builds a single op="and" constraint subtree from the two clauses.
template<typename T>
requires Numeric<T>
T both_clauses(T x) requires Sized<T> {
  return x + x;
}

// Default template argument paired with a requires-clause - exercises the default argument plumbing in
// cpp_template_decl together with the prefix requires-clause.
template<typename T = int> requires Numeric<T>
T identity_default(T x) { return x; }

// Concept refinement - 'Integer' is defined in terms of 'Numeric', so the captured requires text for
// 'requires Integer<T>' contains a nested concept name.  C++20 subsumption (where the more refined
// concept wins between two same signature overloads) is not modelled by SWIG - that broken path is
// covered by errors/cpp_concept_redefinition.i.  Here only the positive parse and instantiate path is
// exercised.
template<typename T>
concept Integer = Numeric<T> && std::integral<T>;

template<typename T> requires Integer<T>
T succ(T x) { return x + 1; }

// Trailing requires-clause on a non-template member of a class template - the
// method itself has no template head of its own; the constraint refers only to
// the enclosing class's template parameter.
template<typename T>
struct ConstrainedHolder {
  T value;
  ConstrainedHolder(T v) : value(v) {}
  T cube() const requires Numeric<T> { return value * value * value; }
};

// Subsumption driven overload selection (negative case, kept here as documentation of what does not
// work).  In C++20 the Integer constrained overload would win for integral types because Integer
// subsumes Numeric.  SWIG sees the two same signature templates as a redefinition (warning 302) and
// drops the second declaration, so subsumption based dispatch cannot be expressed:
//
// template<typename T> requires Numeric<T> T pick(T x) { return x; }
// template<typename T> requires Integer<T> T pick(T x) { return x + 1; }   // dropped, warning 302
%}

%template(identity_non_numeric_tag) identity_non_numeric<Tag>;
%template(mix_add_id)               mix_add<int, double>;
%template(sum_all_iii)              sum_all<int, int, int>;
%template(sum_all_ddd)              sum_all<double, double, double>;
%template(trait_primary_int)        trait_primary<int>;
%template(deeper_int)               deeper<int>;
%template(both_clauses_int)         both_clauses<int>;
%template(identity_default_int)     identity_default<int>;
%template(identity_default_double)  identity_default<double>;
%template(succ_int)                 succ<int>;
%template(ConstrainedHolderInt)     ConstrainedHolder<int>;
