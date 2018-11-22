/*
 * A test of unordered_map containers.
 */

%module li_std_unordered_map

%include <std_string.i>
%include <std_unordered_map.i>

%template(IntIntUnorderedMap) std::unordered_map<int, int>;
%template(StringIntUnorderedMap) std::unordered_map<std::string, int>;

