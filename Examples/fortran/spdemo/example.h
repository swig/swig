/* File : example.h */


#include "boost/shared_ptr.hpp"
using boost::shared_ptr;

class Foo {
public:
  double d_val;

public:
  // Constructor
  Foo();
  Foo(const Foo &other);
  Foo(double val);
  ~Foo();

  double get() const;
  void set(double v);

  // Return a copy by value
  Foo clone() const;
  // Return an SP copy
  shared_ptr<Foo> clone_sp() const;

  // Return references to ourself
  Foo &mutable_ref() { return *this; }
  const Foo &ref() const { return *this; }

  Foo *mutable_ptr() { return this; }
  const Foo *ptr() const { return this; }
};

int use_count(const shared_ptr<Foo> *f);
void print_crsp(const shared_ptr<Foo> &f);
void print_sp(shared_ptr<Foo> f);
void print_spc(shared_ptr<const Foo> f);
void print_crspc(const shared_ptr<const Foo> &f);
void print_cr(const Foo &f);

