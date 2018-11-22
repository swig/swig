/*
 * A test of unordered_set containers.
 */

%module li_std_unordered_set

%include <std_string.i>
%include <std_unordered_set.i>

%template(StringUnorderedSet) std::unordered_set<std::string>;

