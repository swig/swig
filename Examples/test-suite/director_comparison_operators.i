%module(directors="1") director_comparison_operators

%include "std_string.i"
%feature("director");

#if !defined(SWIGLUA) && !defined(SWIGR)
%rename(EqualEqual) operator ==;
%rename(NotEqual) operator !=;
%rename(LessThanEqual) operator <=;
%rename(GreaterThanEqual) operator >=;
#endif

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
