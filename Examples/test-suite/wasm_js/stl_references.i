%module stl_references
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
class Store {
  std::vector<int> vector_;
  std::map<int, int> map_;
  std::pair<int, int> pair_;
public:
  Store() : pair_(1, 2) { vector_.push_back(3); map_[4] = 5; }
  std::vector<int>& vector_ref() { return vector_; }
  std::vector<int>* vector_pointer() { return &vector_; }
  const std::vector<int>& vector_snapshot() const { return vector_; }
  std::map<int, int>& map_ref() { return map_; }
  std::map<int, int>* map_pointer() { return &map_; }
  const std::map<int, int>& map_snapshot() const { return map_; }
  std::pair<int, int>& pair_ref() { return pair_; }
  std::pair<int, int>* pair_pointer() { return &pair_; }
  const std::pair<int, int>& pair_snapshot() const { return pair_; }
};
std::vector<int>* missing_vector() { return 0; }
std::map<int, int>* missing_map() { return 0; }
std::pair<int, int>* missing_pair() { return 0; }
void mutate_vector(std::vector<int>& value) { value.push_back(9); }
void mutate_vector_pointer(std::vector<int>* value) { value->push_back(10); }
void mutate_map(std::map<int, int>& value) { value[6] = 7; }
void mutate_map_pointer(std::map<int, int>* value) { (*value)[8] = 9; }
void mutate_pair(std::pair<int, int>& value) { value.first = 11; }
void mutate_pair_pointer(std::pair<int, int>* value) { value->second = 12; }
%}
