%module cpp11_std_unordered_map

%include <std_string.i>
%include <std_unordered_map.i>

%template(UnorderedMapIntInt) std::unordered_map<int, int>;
%template(UnorderedMapStringInt) std::unordered_map<std::string, int>;

%inline %{
std::unordered_map<std::string, int, std::hash< std::string >,std::equal_to< std::string >,std::allocator< std::pair< std::string const,int > > > inout(std::unordered_map<std::string, int> m) { return m; }
%}
