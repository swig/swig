%module using_method_typedefs

// Bring a protected base class method into the derived class's public interface with a using
// declaration whose qualifier names the base through a variety of typedef forms: a typedef for
// the base, a typedef of a typedef, a typedef for a template instantiation base, a typedef for a
// template instantiation whose template argument is itself a typedef, a scope qualified name, and
// a typedef chain whose intermediate lives in a namespace.  This mirrors the inheriting-constructor
// typedef coverage in cpp11_template_using_base but for an ordinary member.
//
// Some cases additionally give the base a constructor of its own.  A constructor shares its class
// name, so it must not shadow the base class when the typedef qualifier is resolved to a scope.
//
// The final cases name a base that lives in a namespace without the namespace qualifier.  In C++ the
// base class name is visible unqualified from within the derived class (it is the injected class
// name, a member of the base), so the typedef still resolves to the base.
//
// The method is protected in the base so that it is wrapped only because the using declaration
// brings it into the derived class's public interface.

%include <std_string.i>

%inline %{
#include <string>

struct Base {
protected:
  std::string testmethod(std::string v) const { return "Base:" + v; }
};

template <typename T> struct TBase {
protected:
  std::string testmethod(std::string v) const { return "TBase:" + v; }
};

namespace ns {
struct NsBase {
protected:
  std::string testmethod(std::string v) const { return "Ns:" + v; }
};
}

typedef int IntAlias;
%}

%template(TBaseInt) TBase<int>;

%inline %{
// Direct: the qualifier is the base class name (control case).
struct UseDirect : Base {
  using Base::testmethod;
};

// The qualifier is a typedef for the base class.
struct UseTypedef : Base {
  typedef Base base_type;
  using base_type::testmethod;
};

// The qualifier is a typedef of a typedef.
struct UseTypedefChain : Base {
  typedef Base base_alias;
  typedef base_alias base_type;
  using base_type::testmethod;
};

// The qualifier is a typedef for a template instantiation base.
struct UseTemplateTypedef : TBase<int> {
  typedef TBase<int> base_type;
  using base_type::testmethod;
};

// The qualifier is a typedef for a template instantiation whose template argument is itself a typedef.
struct UseTemplateArgTypedef : TBase<int> {
  typedef TBase<IntAlias> base_type;
  using base_type::testmethod;
};

// The qualifier is a scope-qualified base class name.
struct UseQualified : ns::NsBase {
  using ns::NsBase::testmethod;
};

// The qualifier is a typedef of a typedef whose intermediate typedef lives in a namespace.
struct UseNsChain : ns::NsBase {
  typedef ns::NsBase ns_alias;
  typedef ns_alias base_type;
  using base_type::testmethod;
};
%}

%inline %{
// The base declares constructors of its own.  The constructor shares the base class name, which must
// not be mistaken for the base class itself while resolving the typedef qualifier to a scope.
struct CtorBase {
  CtorBase() {}
  CtorBase(int) {}
protected:
  std::string testmethod(std::string v) const { return "Ctor:" + v; }
};

struct UseCtorTypedef : CtorBase {
  typedef CtorBase base_type;
  using base_type::testmethod;
};
%}

%inline %{
// Bases that live in a namespace.  They are named below from a derived class without the Space::
// qualifier, relying on the base class name being visible (as the injected class name) from within
// the derived class.
namespace Space {
struct ConstructorBase {
  ConstructorBase() {}
  ConstructorBase(int) {}
protected:
  std::string testmethod(std::string v) const { return "Constructor:" + v; }
};
// A base with no constructor of its own, so only the injected class name resolves the base name.
struct PlainBase {
protected:
  std::string plainmethod(std::string v) const { return "Plain:" + v; }
};
}
%}

%inline %{
// Control: the typedef qualifier names the namespaced base with its namespace qualifier.
struct UseNsQualified : Space::ConstructorBase {
  typedef Space::ConstructorBase base_type;
  using base_type::testmethod;
};

// The typedef qualifier names the namespaced base without the namespace qualifier.  The base has a
// constructor, which shares the base class name.
struct UseNsCtorTypedef : Space::ConstructorBase {
  typedef ConstructorBase base_type; // not Space:: qualified
  using base_type::testmethod;
};

// As above, but the base has no constructor of its own.
struct UseNsPlainTypedef : Space::PlainBase {
  typedef PlainBase base_type; // not Space:: qualified
  using base_type::plainmethod;
};
%}
