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
