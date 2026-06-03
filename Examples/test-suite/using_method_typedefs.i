%module using_method_typedefs

// Bring a protected base class method into the derived class's public interface with a using
// declaration whose qualifier names the base through a variety of typedef forms: a typedef for
// the base, a typedef of a typedef, a typedef for a template instantiation base, a typedef for a
// template instantiation whose template argument is itself a typedef, a scope qualified name, and
// a typedef chain whose intermediate lives in a namespace.  This mirrors the inheriting-constructor
// typedef coverage in cpp11_template_using_base but for an ordinary member.
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
