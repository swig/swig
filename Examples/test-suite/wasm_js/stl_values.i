%module stl_values
%include <std_vector.i>
%include <std_map.i>
%include <std_pair.i>
%template(IntVector) std::vector<int>;
%template(IntMap) std::map<int, int>;
%template(IntPair) std::pair<int, int>;
%inline %{
#include <vector>
#include <map>
#include <utility>
std::vector<int> vector_value(std::vector<int> value) {
  value.push_back(9);
  return value;
}
const std::vector<int>& vector_const_ref(const std::vector<int>& value) { return value; }
std::map<int, int> map_value(std::map<int, int> value) {
  value[7] = 8;
  return value;
}
const std::map<int, int>& map_const_ref(const std::map<int, int>& value) { return value; }
std::pair<int, int> pair_value(std::pair<int, int> value) {
  ++value.first;
  return value;
}
const std::pair<int, int>& pair_const_ref(const std::pair<int, int>& value) { return value; }
%}
