%module cpp20_constrained_template_directives

// %ignore and %feature naming one of two function templates that differ only by their constraint, with a trailing requires-clause.

%{
const char *LastCalled = "<none>";
%}
%inline %{
const char *getLastCalled() {
  const char *last = LastCalled;
  LastCalled = "<none>";
  return last;
}

template<typename T> concept IsInt = T(3) / T(2) == T(1);
template<typename T> concept IsReal = !IsInt<T>;
template<typename T> concept Signed = T(-1) < T(0);
%}

// A prefix requires-clause, and a constrained %exception taking precedence over an unconstrained one whatever the order.
%ignore prefixed(T) requires IsInt<T>;
%exception prefixed(T) requires IsReal<T> %{
  LastCalled = "prefixed IsReal";
  $action
%}
%exception prefixed(T) requires IsInt<T> %{
  LastCalled = "prefixed IsInt";
  $action
%}
%exception prefixed(T) %{
  LastCalled = "prefixed";
  $action
%}

%inline %{
template<typename T> requires IsInt<T> int prefixed(T) { return 1; }
template<typename T> requires IsReal<T> int prefixed(T) { return 2; }
%}

%template(prefixed) prefixed<double>;

// A trailing requires-clause.
%ignore trailing(T) requires IsReal<T>;
%exception trailing(T) requires IsInt<T> %{
  LastCalled = "trailing IsInt";
  $action
%}

%inline %{
template<typename T> int trailing(T) requires IsInt<T> { return 1; }
template<typename T> int trailing(T) requires IsReal<T> { return 2; }
%}

%template(trailing) trailing<int>;

// A type-constraint is matched as the concept-id it stands for.
%ignore typed(T) requires IsInt<T>;

%inline %{
template<IsInt T> int typed(T) { return 1; }
template<IsReal T> int typed(T) { return 2; }
%}

%template(typed) typed<double>;

// The operands of '&&' can be written in any order.
%ignore mixed(T) requires Signed<T> && IsReal<T>;

%inline %{
template<IsInt T> requires Signed<T> int mixed(T) { return 1; }
template<IsReal T> requires Signed<T> int mixed(T) { return 2; }
%}

%template(mixed) mixed<int>;

// Whitespace in a parenthesised constraint does not matter.
%ignore halved(T) requires (T(3)/T(2)==T(1));

%inline %{
template<typename T> requires (T(3) / T(2) == T(1)) int halved(T) { return 1; }
template<typename T> requires (T(3) / T(2) != T(1)) int halved(T) { return 2; }
%}

%template(halved) halved<double>;

// Whitespace inside a string literal does matter.
%ignore spelt(T) requires (sizeof(T) > sizeof("a  b"));

%inline %{
struct FiveBytes {
  char bytes[5];
};
template<typename T> requires (sizeof(T) > sizeof("a b")) int spelt(T) { return 1; }
template<typename T> requires (sizeof(T) > sizeof("a  b")) int spelt(T) { return 2; }
%}

%template(spelt) spelt<FiveBytes>;

// A type-constraint on a parameter pack is matched as the fold-expression it stands for.
%ignore packed(Ts...) requires (IsInt<Ts> && ...);

%inline %{
template<IsInt... Ts> int packed(Ts...) { return 1; }
template<IsReal... Ts> int packed(Ts...) { return 2; }
%}

%template(packed) packed<double, double>;

// A member function template.
%ignore Picker::pick(T) requires IsInt<T>;

%inline %{
struct Picker {
  template<typename T> requires IsInt<T> int pick(T) { return 1; }
  template<typename T> requires IsReal<T> int pick(T) { return 2; }
};
%}

%extend Picker {
  %template(pick) pick<double>;
}

// An unconstrained function template is not named by a constrained %ignore.
%ignore plain(T) requires IsInt<T>;

%inline %{
template<typename T> int plain(T) { return 1; }
%}

%template(plain) plain<int>;
