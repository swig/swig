/* File: fortran_shared_ptr.i */
%module fortran_shared_ptr

%include <std_shared_ptr.i>
%shared_ptr(Foo);

%{
#include <memory>
%}

%inline %{
class Foo {
public:
  explicit Foo(int val) {}
  ~Foo() {}
  const Foo *my_raw_ptr() const { return this; }
};

int use_count(const std::shared_ptr<Foo> *f) {
  if (!f) return 0;
  return f->use_count();
}
%}

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
