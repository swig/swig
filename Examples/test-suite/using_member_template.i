%module using_member_template

// Regression test: SWIG segfaulted in Allocate::usingDeclaration when a class has
// both a public 'using Base::method' (where Base::method is a template with no
// SWIG-visible instantiations) and a protected concrete override of the same name.
//
// The crash was a null-pointer dereference in clean_overloaded() (allocate.cxx)
// because firstoverloaded became null: the using node was the sole overload head,
// the template produced no child nodes (ccount==0), and sym:nextSibling was null.

%inline %{

struct Impl {};

struct Base {
  template <typename T>
  T *getImpl() const { return nullptr; }
};

struct Derived : public Base {
  using Base::getImpl;

protected:
  Impl *getImpl() const { return nullptr; }
};

// A further-derived class exercises the inherited using declaration path.
struct MoreDerived : public Derived {};

%}
