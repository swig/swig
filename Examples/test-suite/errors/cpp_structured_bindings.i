%module xxx

// A C++17 structured binding is parsed and ignored, whatever decoration the placeholder carries.

struct Pt {
  int x;
  int y;
};

Pt global_pt = {1, 2};

auto [plain_a, plain_b] = global_pt;
auto& [ref_a, ref_b] = global_pt;
const auto& [cref_a, cref_b] = global_pt;
auto&& [rref_a, rref_b] = Pt{3, 4};
static auto [static_a, static_b] = global_pt;

// A binding of three names, to show the whole list is reported.
struct Triple {
  int a;
  int b;
  int c;
};

Triple global_triple = {1, 2, 3};

auto [t1, t2, t3] = global_triple;

// Direct-list initialisation (C++17) and parenthesised initialisation (C++20).
auto [braced_a, braced_b]{global_pt};
auto [paren_a, paren_b](global_pt);

// An initialiser holding a semicolon of its own - the declaration ends at the semicolon after the
// call, not at the one inside the lambda body, so the declaration after it is still seen.
auto [lambda_a, lambda_b] = [] { return Pt{5, 6}; }();

int after = 1;
