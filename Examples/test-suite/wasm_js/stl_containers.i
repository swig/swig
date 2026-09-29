%module stl_containers
%include <std_string.i>
%include <std_deque.i>
%include <std_list.i>
%include <std_set.i>
%include <std_array.i>
%include <std_unordered_map.i>
%include <std_unordered_set.i>
%template(IntDeque) std::deque<int>;
%template(IntList) std::list<int>;
%template(IntSet) std::set<int>;
%template(IntArray) std::array<int, 3>;
%template(StringUnorderedMap) std::unordered_map<std::string, int>;
%template(IntUnorderedSet) std::unordered_set<int>;
%inline %{
std::deque<int> deque_values(std::deque<int> value) { return value; }
const std::deque<int>& deque_const_ref(const std::deque<int>& value) { return value; }
std::list<int> list_values(std::list<int> value) { return value; }
std::set<int> set_values(std::set<int> value) { return value; }
std::array<int, 3> array_values(std::array<int, 3> value) { return value; }
std::unordered_map<std::string, int> unordered_map_values(std::unordered_map<std::string, int> value) { return value; }
std::unordered_set<int> unordered_set_values(std::unordered_set<int> value) { return value; }
void mutate_deque(std::deque<int>& value) { value.push_back(7); }
void mutate_list(std::list<int>& value) { value.push_back(7); }
void mutate_set(std::set<int>& value) { value.insert(7); }
void mutate_array(std::array<int, 3>& value) { value[1] = 7; }
void mutate_unordered_map(std::unordered_map<std::string, int>& value) { value["seven"] = 7; }
void mutate_unordered_set(std::unordered_set<int>& value) { value.insert(7); }
%}
