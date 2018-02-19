/* File : spdemo.cxx */

#include "spdemo.h"

#include <stdexcept>
#include <iostream>
using std::cout;
using std::endl;

Foo::Foo() : d_val(0) {
  cout << "Initialized Foo at " << this << endl;
}

Foo::Foo(double val) : d_val(val) {
  cout << "Initialized Foo at " << this << endl;
}

Foo::Foo(const Foo &other) : d_val(other.d_val) {
  cout << "Copy-constructed Foo at " << this << endl;
}

Foo::~Foo() {
  cout << "Destroyed Foo at " << this << endl;
}

double Foo::get() const {
  return d_val;
}
void Foo::set(double v) {
  d_val = v;
}

Foo Foo::clone() const {
  return *this;
}

std::shared_ptr<Foo> Foo::clone_sp() const {
  return std::make_shared<Foo>(*this);
}

void print_sp(std::shared_ptr<Foo> f) {
  cout << "Shared pointer at " << &f << " with reference count " << f.use_count() << ": ";
  print_crsp(f);
}

void print_crsp(const std::shared_ptr<Foo> &f) {
  cout << "Shared pointer at " << &f << " with reference count " << f.use_count() << ": ";
  print_crspc(f);
}

void print_spc(std::shared_ptr<const Foo> f) {
  cout << "Shared pointer at " << &f << " with reference count " << f.use_count() << ": ";
  print_crspc(f);
}

void print_crspc(const std::shared_ptr<const Foo> &f) {
  if (!f)
    throw std::logic_error("got null sp");

  cout << "Shared pointer at " << &f << " with reference count " << f.use_count() << ": ";
  print_cr(*f);
}

void print_cr(const Foo &f) {
  cout << "Foo at " << &f << ": " << f.get() << endl;
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
