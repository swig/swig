// This testcase checks that SWIG parses a C++17 structured binding.  The names are bound to the
// members of the initialiser, which SWIG would have to know the layout of to give each name a
// type, so the declaration is ignored with warning 349.  What matters is that parsing carries on,
// as the declaration used to be a syntax error.  A 'static' binding is C++20 grammar, so it is
// exercised by the errors test suite rather than here, where the code is compiled as C++17.
%module cpp17_structured_bindings

#pragma SWIG nowarn=SWIGWARN_CPP17_STRUCTURED_BINDING

%inline %{
struct Pt {
  int x;
  int y;
};

Pt global_pt = {1, 2};

auto [plain_a, plain_b] = global_pt;
auto& [ref_a, ref_b] = global_pt;
const auto& [cref_a, cref_b] = global_pt;
auto&& [rref_a, rref_b] = Pt{3, 4};

// Declared after the structured bindings to show that parsing recovers and carries on.
int parsing_continues() { return 42; }

struct Holder {
  int v;

  explicit Holder(int v_) : v(v_) { }

  int get() const { return v; }
};
%}
