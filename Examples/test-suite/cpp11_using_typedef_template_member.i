%module cpp11_using_typedef_template_member

// Regression test for #1042 and #1153
//
// A using-declaration brings an inherited member of a template base class into a derived template class.
// The member is named through a typedef or a C++11 alias of the template instantiation (NodeIT) rather
// than through the base class name directly.  A template parameter of the base appears in the inherited
// member's type, either in a data member's type (issue #1042) or in a member function's parameter type
// (issue #1153).  The template parameter must still be expanded in the wrapped member; otherwise the
// qualifier was reduced to the bare template name and the generated wrapper referred to the unexpanded
// 'links_type', failing to compile.

%inline %{
template <typename T> struct Owners {
  T value;
};

template <typename LinksT>
class NodeI {
public:
  using links_type = LinksT;
protected:
  Owners<links_type> owners;                                          // data member type uses links_type (#1042)
  links_type total(const Owners<links_type> &extra) const {           // parameter type uses links_type (#1153)
    return owners.value + extra.value;
  }
};

// The using-declaration qualifier is a C++11 alias declaration of the template instantiation base.
template <typename LinksT>
class ClusterAlias : public NodeI<LinksT> {
public:
  using NodeIT = NodeI<LinksT>;
  using NodeIT::owners;
  using NodeIT::total;
};

// The using-declaration qualifier is a plain typedef of the template instantiation base.
template <typename LinksT>
class ClusterTypedef : public NodeI<LinksT> {
public:
  typedef NodeI<LinksT> NodeIT;
  using NodeIT::owners;
  using NodeIT::total;
};

// Control: the qualifier names the base class directly (this form already worked).
template <typename LinksT>
class ClusterDirect : public NodeI<LinksT> {
public:
  using NodeI<LinksT>::owners;
  using NodeI<LinksT>::total;
};
%}

%template(OwnersInt) Owners<int>;
%template(NodeIInt) NodeI<int>;
%template(ClusterAliasInt) ClusterAlias<int>;
%template(ClusterTypedefInt) ClusterTypedef<int>;
%template(ClusterDirectInt) ClusterDirect<int>;
