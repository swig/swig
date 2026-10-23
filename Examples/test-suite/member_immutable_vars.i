%module member_immutable_vars

// Test immutable and mutable member variables, as global_immutable_vars does for global variables

%immutable ImmutableVars::specific_immutable_var;

%inline %{
struct ImmutableVars {
  int mutable_var;
  int specific_immutable_var;
  const int const_var;
  ImmutableVars() : mutable_var(40), specific_immutable_var(41), const_var(42) {}
};

struct DerivedImmutableVars : ImmutableVars {
  int derived_mutable_var;
  DerivedImmutableVars() : derived_mutable_var(43) {}
};
%}
