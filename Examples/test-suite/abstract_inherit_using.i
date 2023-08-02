%module abstract_inherit_using

%inline %{
class AbstractBase
{
public:
  virtual void f(int n) = 0;
  void f(const char *another_representation_of_n) {}
  virtual ~AbstractBase() {}
};

class ConcreteDerived1 : public AbstractBase
{
public:
  ConcreteDerived1() {}

  // Abstract test always worked
  virtual void f(int n) {}
  using AbstractBase::f;
};

class ConcreteDerived2 : public AbstractBase
{
public:
  ConcreteDerived2() {}

  // SWIG thought this class was abstract when using declaration was before method f and didn't generate constructor
  using AbstractBase::f;
  virtual void f(int n) {}
};
%}
