/* File : example.h */

#include <string>

void print_str(const std::string &s);

std::string halved_str(std::string s);

std::string reversed_str(const std::string &input);

inline std::string reversed_str_mutable(std::string &input) {
  return reversed_str(const_cast<const std::string &>(input));
}

