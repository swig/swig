%module(directors="1") director_simple

%feature("director") IntBase;
%feature("director") BoolBase;

%inline %{
class IntBase {
 public:
  virtual ~IntBase() {}
  IntBase(int i = 3) { (void)i; }
  virtual int apply(int x) const { return x * 2; }
};

class IntDerived : public IntBase {
 public:
  virtual int apply(int x) const { return x * 3; }
};

int apply(const IntBase& b, int x)
{
  return b.apply(x);
}

class BoolBase {
 public:
  virtual ~BoolBase() {}
  BoolBase() {}
  virtual bool apply(bool a, bool b) const = 0;
};

class BoolDerived : public BoolBase {
 public:
  virtual bool apply(bool a, bool b) const { return a != b; }
};

bool apply(const BoolBase& base, bool a, bool b)
{
  return base.apply(a, b);
}

%}

