/* File : director.cxx */
#include "director.h"

#include <sstream>

// Default destructor
Joiner::~Joiner() { /* * */ }

// Join a bunch of strings with the given director
std::string Joiner::join(const std::string& conjunction) const
{
  std::ostringstream os;
  for (VecStr::const_iterator iter = items_.begin(); iter != items_.end(); ++iter) {
    if (iter != items_.begin())
      os << conjunction;
    os << this->transform(*iter);
  }
  return os.str();
}

std::string Joiner::join_default() const {
  return this->join(", ");
}

void Joiner::append_several() {
  static const char* my_strings[] = {
    "whiskey",
    "tango",
    "foxtrot",
    "sierra",
    "juliet"};

  for (const char** s_iter = my_strings; s_iter != (my_strings + 5); ++s_iter) {
    this->append(*s_iter);
  }
}


std::string QuoteJoiner::transform(const std::string& s) const {
  std::string result;
  result.push_back('"');
  result.append(s);
  result.push_back('"');
  return result;
}


std::string join_with_commas(const Joiner& j) {
  return j.join(", ");
}

std::string join_default(const Joiner& j) {
  return j.join_default();
}

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
