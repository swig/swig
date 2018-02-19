/* File : stdstr.cxx */

#include "stdstr.h"

#include <algorithm>
#include <iostream>
using std::cout;
using std::endl;

void print_str(const std::string &s) {
  cout << "\"" << s << "\"" << endl;
}

void halve_str(std::string &s) {
  s.erase(s.begin() + s.size() / 2, s.end());
}

std::string get_reversed_native_string(const std::string &input) {
  std::string result(input);
  std::reverse(result.begin(), result.end());
  return result;
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
