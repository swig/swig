%module swift_vector
// Swift-specific test: std::vector exposed to Swift.
%include <std_vector.i>
%template(IntVector) std::vector<int>;
%inline %{
#include <vector>
int sum(const std::vector<int> &v) { int s = 0; for (int x : v) s += x; return s; }
std::vector<int> make_range(int n) { std::vector<int> v; for (int i = 0; i < n; i++) v.push_back(i); return v; }
%}

// Ownership regression: a std::vector returned by value from a function must be
// owned by the Swift proxy so ARC frees the vector (and its elements) when the
// last reference drops. Item counts live instances so the runme can assert the
// count returns to its baseline; a non-owning proxy would leak the whole vector.
%inline %{
struct Item {
  int v;
  Item(int x = 0) : v(x) { ++live_count(); }
  Item(const Item &o) : v(o.v) { ++live_count(); }
  ~Item() { --live_count(); }
  static int &live_count() { static int n = 0; return n; }
};
%}
%template(ItemVector) std::vector<Item>;
%inline %{
std::vector<Item> make_items(int n) { std::vector<Item> v; for (int i = 0; i < n; i++) v.push_back(Item(i)); return v; }
int item_live_count() { return Item::live_count(); }
%}
