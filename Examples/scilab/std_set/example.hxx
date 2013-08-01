/* File : example.hxx */

#include <set>
#include <string>


// integer sets
std::set<int> create_integer_set(const int size, const int value);
int sum_integer_set(const std::set<int>& set);
std::set<int> concat_integer_set(const std::set<int> set, const std::set<int> other_set);

// string sets
std::set<std::string> create_string_set(const char* value);
std::set<std::string> concat_string_set(const std::set<std::string> set, const std::set<std::string> other_set);
