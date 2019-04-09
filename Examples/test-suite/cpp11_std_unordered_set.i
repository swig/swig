%module cpp11_std_unordered_set

%include <std_string.i>
%include <std_unordered_set.i>

%template(UnorderedSetInt) std::unordered_set<int>;
%template(UnorderedSetString) std::unordered_set<std::string>;
