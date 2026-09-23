%module abstract_inherit_default_args

%inline %{
class AbstractBase {
public:
  virtual ~AbstractBase() {}
  virtual int f(int n, int m = 0) const = 0;
};

// The override without the default argument still overrides the pure virtual f(int) generated for it
class ConcreteDerived : public AbstractBase {
public:
  ConcreteDerived() {}
  virtual int f(int n, int m) const { return n + m; }
};

class ConcreteDerivedDerived : public ConcreteDerived {
public:
  ConcreteDerivedDerived() {}
};

class ConcreteDerivedDefault : public AbstractBase {
public:
  ConcreteDerivedDefault() {}
  virtual int f(int n, int m = 0) const { return n + m; }
};

class AbstractDerived : public AbstractBase {
public:
  virtual int g() const = 0;
};

class ConcreteAbstractDerived : public AbstractDerived {
public:
  ConcreteAbstractDerived() {}
  virtual int f(int n, int m) const { return n + m; }
  virtual int g() const { return 0; }
};
%}
