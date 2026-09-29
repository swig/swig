%module stl_ownership
%ignore tracked_count;
%ignore copy_count;
%insert("js") %{
__m.handle_count = () => M.count_emval_handles();
%}
%ignore Unwrapped;
%inline %{
#include <stdexcept>
int& copy_count() { static int count = 0; return count; }
int& tracked_count() { static int count = 0; return count; }
class Tracked {
public:
  int value;
  Tracked(int input = 0) : value(input) { ++tracked_count(); }
  Tracked(const Tracked& other) : value(other.value) { ++tracked_count(); ++copy_count(); }
  ~Tracked() { --tracked_count(); }
  static int copies() { return copy_count(); }
  static int live() { return tracked_count(); }
};
class Unwrapped { Tracked member; };
%}
%include <std_string.i>
%include <std_vector.i>
%include <std_map.i>
%include <std_pair.i>
%template(TrackedVector) std::vector<Tracked>;
%template(TrackedPointerVector) std::vector<Tracked*>;
%template(TrackedMap) std::map<std::string, Tracked>;
%template(StringVector) std::vector<std::string>;
%template(TrackedPair) std::pair<Tracked, Tracked>;
%template(NestedPair) std::pair<std::map<std::string, Tracked>, std::vector<std::string> >;
%typemap(out, tsstub_out="[Tracked, unknown]") std::pair<Tracked, Unwrapped> fail_output {
  $result = swig_wasmjs::to_value< $1_ltype >($1).release_ownership();
}
%insert("stubs") %{
type Unwrapped = unknown;
%}
%inline %{
Tracked *echo_pointer(Tracked *value) { return value; }
Tracked *null_value() { return 0; }
Unwrapped unwrapped_output() { return Unwrapped(); }
std::pair<Tracked, Unwrapped> fail_output() { return std::make_pair(Tracked(23), Unwrapped()); }
std::vector<Tracked> copy_values(std::vector<Tracked> values) { return values; }
std::vector<Tracked*> copy_pointers(std::vector<Tracked*> values) { return values; }
std::pair<Tracked, Tracked> copy_pair(std::pair<Tracked, Tracked> values) { return values; }
std::pair<std::map<std::string, Tracked>, std::vector<std::string> > copy_nested(
    std::pair<std::map<std::string, Tracked>, std::vector<std::string> > values) { return values; }
void fail_after_values(std::vector<Tracked> values) {
  (void)values;
  throw std::runtime_error("expected container call failure");
}
int consume_two(std::vector<Tracked> first, std::vector<Tracked> second) {
  return static_cast<int>(first.size() + second.size());
}
%}
