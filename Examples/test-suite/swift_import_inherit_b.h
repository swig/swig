#ifndef SWIFT_IMPORT_INHERIT_B_H
#define SWIFT_IMPORT_INHERIT_B_H

#include "swift_import_inherit_a.h"

class Derived : public Base {
public:
  Derived(int id) : Base(id) {}
  int doubled() const { return getId() * 2; }
};

#endif
