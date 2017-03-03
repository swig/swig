%module cpp11_shared_ptr_const

%{

#include <memory>
#include <vector>

class Foo
{
public:
  Foo(int i) : m(i) {}
  int get_m() { return m;}
  int m;
};

std::vector<std::shared_ptr<Foo> > foo_vec() {
    std::vector<std::shared_ptr<Foo> > result;
    result.push_back( std::shared_ptr<Foo>(new Foo(7)) );
    return result;
}

std::vector<std::shared_ptr<const Foo> > const_foo_vec() {
  std::vector<std::shared_ptr<const Foo> > result;
  result.push_back( std::shared_ptr<Foo>(new Foo(7)) );
  return result;
}

%}

%include <std_shared_ptr.i>
%include <std_vector.i>

%shared_ptr(Foo);

%template (FooVector) std::vector<std::shared_ptr<Foo> >;
%template (FooConstVector) std::vector<std::shared_ptr<Foo const> >;

std::vector<std::shared_ptr<Foo> > foo_vec() const;
std::vector<std::shared_ptr<const Foo> > const_foo_vec() const;

class Foo
{
public:
  Foo(int i);
  int get_m();
  int m;
};
