%module stl_nested
%inline %{
enum Choice { CHOICE_FIRST = -2, CHOICE_SECOND = 7 };
%}
%include <std_string.i>
%include <std_vector.i>
%include <std_map.i>
%include <std_pair.i>
%template(ChoiceVector) std::vector<Choice>;
%template(FloatVector) std::vector<float>;
%template(BoolVector) std::vector<bool>;
%template(WideVector) std::vector<long long>;
%template(UnsignedWideVector) std::vector<unsigned long long>;
%template(StringVector) std::vector<std::string>;
%template(IntVector) std::vector<int>;
%template(NestedVector) std::vector<std::vector<int> >;
%template(StringVectorMap) std::map<std::string, std::vector<int> >;
%template(WidePair) std::pair<long long, unsigned long long>;
%template(StringPair) std::pair<std::string, std::string>;
%inline %{
std::pair<long long, unsigned long long> wide_pair(std::pair<long long, unsigned long long> value) { return value; }
std::vector<Choice> choice_values(std::vector<Choice> value) { return value; }
std::vector<float> float_values(std::vector<float> value) { return value; }
std::vector<bool> bool_values(std::vector<bool> value) { return value; }
std::vector<long long> wide_values(std::vector<long long> value) { return value; }
std::vector<unsigned long long> unsigned_wide_values(std::vector<unsigned long long> value) { return value; }
std::vector<std::string> string_values(std::vector<std::string> value) { return value; }
std::vector<std::vector<int> > nested_values(std::vector<std::vector<int> > value) { return value; }
std::map<std::string, std::vector<int> > mapped_values(std::map<std::string, std::vector<int> > value) { return value; }
std::pair<std::string, std::string> paired_strings(std::pair<std::string, std::string> value) { return value; }
%}
