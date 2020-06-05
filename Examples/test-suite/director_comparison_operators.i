%module(directors="1") director_comparison_operators

%include "std_string.i"
%feature("director");

%inline %{
class Foo {
public:
  virtual ~Foo() { }
  virtual bool operator==(const Foo&) const = 0;
  virtual bool operator>=(const Foo&) const = 0;
  virtual bool operator<=(const Foo&) const = 0;
  virtual bool operator!=(const Foo&) const = 0;
  virtual std::string test(const char *foo="a=1,b=2") { return foo; }
};
%}
