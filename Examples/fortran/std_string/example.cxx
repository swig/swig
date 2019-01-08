/* File : example.cxx */

#include "example.h"

#include <algorithm>
#include <iostream>
using std::cout;
using std::endl;

void print_str(const std::string &s) {
  cout << "\"" << s << "\"" << endl;
}

std::string halved_str(std::string s) {
  s.erase(s.begin() + s.size() / 2, s.end());
  return s;
}

std::string reversed_str(const std::string &input) {
  std::string result(input);
  std::reverse(result.begin(), result.end());
  return result;
}



