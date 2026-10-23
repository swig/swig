%module cpp11_using_member_template

// Regression test: SWIG segfaulted in Allocate::usingDeclaration when a class has
// both a public 'using Base::method' (where Base::method is a member template with no
// SWIG-visible instantiations) and a protected concrete override of the same name.
//
// The crash was a null-pointer dereference in clean_overloaded() (allocate.cxx)
// because firstoverloaded became null: the using node was the sole overload head,
// the template produced no child nodes (ccount==0), and sym:nextSibling was null.
//
// Replicates the real-world pattern from https://godbolt.org/z/1b8xTevWP

%{
#include <memory>

namespace detail {
struct Base_Impl : public std::enable_shared_from_this<Base_Impl> {
  virtual int value() const = 0;
  virtual ~Base_Impl() = default;
};

struct Derived_Impl : public Base_Impl {
  int value() const override { return 1; }
};

struct MoreDerived_Impl : public Derived_Impl {
  int value() const override { return 2; }
};
}  // namespace detail
%}

%inline %{
#include <memory>

struct Base {
public:
  template <typename T>
  std::shared_ptr<T> getImpl() const {
    return std::dynamic_pointer_cast<T>(m_impl);
  }

protected:
  using ImplType = detail::Base_Impl;
  Base(std::shared_ptr<ImplType> impl) : m_impl(std::move(impl)) {}

private:
  std::shared_ptr<detail::Base_Impl> m_impl;
};

struct Derived : public Base {
public:
  Derived() : Base(std::shared_ptr<detail::Base_Impl>(new detail::Derived_Impl())) {}
  using Base::getImpl;

  int value() const {
    return getImpl()->value();
  }

protected:
  using ImplType = detail::Derived_Impl;
  explicit Derived(std::shared_ptr<ImplType> impl) : Base(std::move(impl)) {}

  std::shared_ptr<ImplType> getImpl() const {
    return Base::getImpl<ImplType>();
  }
};

// A further-derived class exercises the inherited using declaration path.
struct MoreDerived : public Derived {
  MoreDerived() : Derived(std::shared_ptr<detail::Derived_Impl>(new detail::MoreDerived_Impl())) {}
};
%}
