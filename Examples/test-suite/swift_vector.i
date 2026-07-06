%module swift_vector
// Swift-specific test: std::vector exposed to Swift.
%include <std_vector.i>
%template(IntVector) std::vector<int>;
%inline %{
#include <vector>
int sum(const std::vector<int> &v) { int s = 0; for (int x : v) s += x; return s; }
std::vector<int> make_range(int n) { std::vector<int> v; for (int i = 0; i < n; i++) v.push_back(i); return v; }
%}
