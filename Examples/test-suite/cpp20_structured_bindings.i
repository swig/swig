// This testcase checks that SWIG parses the C++20 additions to structured bindings.  As in C++17 the
// names are bound to the members of the initialiser, which SWIG would have to know the layout of to
// give each name a type, so every declaration is ignored with warning 349 and what matters is that
// parsing carries on.  See cpp17_structured_bindings.i for the forms C++17 already had.
%module cpp20_structured_bindings

#pragma SWIG nowarn=SWIGWARN_CPP17_STRUCTURED_BINDING

%inline %{
struct Pt {
  int x;
  int y;
};

Pt global_pt = {1, 2};

// Parenthesised initialisation, which C++17 did not have.
auto [paren_a, paren_b](global_pt);

// A storage-class-specifier on a structured binding.  C++17 allowed none, C++20 allows these two.
static auto [static_a, static_b] = global_pt;
thread_local auto [tl_a, tl_b] = global_pt;

// The decorations combined with the new initialiser form.
static const auto& [static_cref_a, static_cref_b](global_pt);

// A structured binding captured by a lambda, which C++20 allows and C++17 did not.  SWIG skips
// function bodies, so this is here to show the testcase is compiled as C++20 rather than to
// exercise the parser.
int capture_binding() {
  auto [ca, cb] = global_pt;
  return [ca, cb] { return ca + cb; }();
}

// Declared after the structured bindings to show that parsing recovers and carries on.
int parsing_continues() { return 42; }
%}
