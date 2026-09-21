%module julia_containers
%include <std_pair.i>
%include <std_string.i>
%include <std_vector.i>

%inline %{
std::vector<double> doubles(const std::vector<double>& values) { return values; }
std::vector<long long> integers(const std::vector<long long>& values) { return values; }
std::vector<std::string> strings(const std::vector<std::string>& values) { return values; }
std::string string_identity(const std::string& value) { return value; }
std::pair<std::string, std::string> pair_strings() {
  return std::make_pair(std::string(10000, 'a'), std::string(10000, 'b'));
}
%}
