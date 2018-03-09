/* File : callback.cxx */
#include "callback.h"

#include <sstream>

std::string passthrough(const std::string& s) {
  return s;
}

std::string enquote(const std::string& s) {
  std::string result;
  result.push_back('"');
  result.append(s);
  result.push_back('"');
  return result;
}

// Join a bunch of strings with the given callback
std::string join_transformed(const std::string& joiner, fp_transform cb)
{
  static const char* my_strings[] = {
    "whiskey",
    "tango",
    "foxtrot",
    "sierra",
    "juliet"};

  std::ostringstream os;
  for (const char** s_iter = my_strings; s_iter != (my_strings + 5); ++s_iter) {
    std::string input(*s_iter);
    std::string output;

    output = cb(input);
    if (s_iter != my_strings)
      os << joiner;
    os << output;
  }
  return os.str();
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
