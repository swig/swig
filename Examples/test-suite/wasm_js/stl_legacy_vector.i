%module stl_legacy_vector
%include <std_vector.i>
%template(IntVector) std::vector<int>;
%wasm_vec(int, IntVector)
%insert("js") %{
__m.handle_count = () => M.count_emval_handles();
%}
%inline %{
class VectorConsumer {
  int count_;
public:
  VectorConsumer(std::vector<int> value, bool fail = false) : count_(value.size()) {
    if (fail) throw std::runtime_error("expected constructor failure");
  }
  int size() const { return count_; }
};
std::vector<int> echo(std::vector<int> value) { return value; }
const std::vector<int>& echo_ref(const std::vector<int>& value) { return value; }
std::vector<int> echo_two(std::vector<int> first, std::vector<int> second) {
  first.insert(first.end(), second.begin(), second.end());
  return first;
}
void fail(std::vector<int> value) {
  (void)value;
  throw std::runtime_error("expected failure");
}
%}
