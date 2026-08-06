#ifndef SWIFT_IMPORT_INHERIT_A_H
#define SWIFT_IMPORT_INHERIT_A_H

class Base {
  int id_;

public:
  Base(int id) : id_(id) {}
  virtual ~Base() {}
  int getId() const { return id_; }
};

#endif
