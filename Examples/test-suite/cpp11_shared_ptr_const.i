%module cpp11_shared_ptr_const

#if defined(SWIGC) || defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON) || defined(SWIGD) || defined(SWIGOCTAVE) || defined(SWIGRUBY) || defined(SWIGR) || defined(SWIGLUA)
#define SHARED_PTR_WRAPPERS_IMPLEMENTED
#endif

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)
%include <std_shared_ptr.i>
%shared_ptr(Foo);
#endif

%include <std_vector.i>

%{

#include <memory>
#include <vector>

class Foo
{
  int m;
public:
  Foo(int i) : m(i) {}
  int get_m() { return m;}
};

std::shared_ptr<Foo> single_foo(Foo v) {
  return std::shared_ptr<Foo>(new Foo(v));
}

std::shared_ptr<const Foo> const_single_foo(Foo v) {
  return std::shared_ptr<const Foo>(new Foo(v));
}

std::vector<std::shared_ptr<Foo> > foo_vec(Foo v) {
    std::vector<std::shared_ptr<Foo> > result;
    result.push_back( std::shared_ptr<Foo>(new Foo(v)) );
    return result;
}

std::vector<std::shared_ptr<const Foo> > const_foo_vec(Foo v) {
  std::vector<std::shared_ptr<const Foo> > result;
  result.push_back( std::shared_ptr<Foo>(new Foo(v)) );
  return result;
}

%}

%template (FooVector) std::vector<std::shared_ptr<Foo> >;
%template (FooConstVector) std::vector<std::shared_ptr<Foo const> >;

class Foo
{
  int m;
public:
  Foo(int i);
  int get_m();
};
std::shared_ptr<Foo> single_foo(Foo v);
std::shared_ptr<const Foo> const_single_foo(Foo v);
std::vector<std::shared_ptr<Foo> > foo_vec(Foo v) const;
std::vector<std::shared_ptr<const Foo> > const_foo_vec(Foo v) const;

