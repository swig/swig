/* Shared by import_vector_fwd_a.i and import_vector_fwd_b.i.

   Bar is only forward-declared in import_vector_fwd_a.i (which declares Container, using
   std::vector<Bar> as a parameter/return type). Bar is fully defined, and
   std::vector<Bar> is %template'd, in import_vector_fwd_b.i, which %imports
   import_vector_fwd_a.i. */

#ifndef SWIGTESTIMPORTVECTORFWD_H
#define SWIGTESTIMPORTVECTORFWD_H

#include <vector>
#include <string>
/* Some std_vector.i variants only #include these in a %{ %} block, a no-op for a module reached via %import. */
#include <algorithm>
#include <stdexcept>

class Bar {
public:
  Bar() : name_("bar") {}
  Bar(std::string name) : name_(name) {}
  std::string name() const { return name_; }
private:
  std::string name_;
};

class Container {
public:
  Container() : count_(0) {}
  bool addBars(const std::vector<Bar>& bars) {
    count_ += bars.size();
    return true;
  }
  std::vector<Bar> getBars() const {
    return std::vector<Bar>(count_);
  }
private:
  size_t count_;
};

#endif
