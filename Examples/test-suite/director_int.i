%module(directors="1") director_int

%feature("director") Base;
%ignore Base::apply_ignored;
%ignore Base::ignored_pure;

%inline %{
class Base {
 public:
  virtual ~Base() {}
  Base(int i = 3) { (void)i; }
  virtual int apply(int x) const { return x * 2; }
};

class Derived : public Base {
 public:
  virtual int apply(int x) const { return x * 3; }
};

int apply(const Base& b, int x)
{
  return b.apply(x);
}

%}

