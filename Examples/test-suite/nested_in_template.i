%module nested_in_template

#if !defined(SWIGCSHARP) && !defined(SWIGJAVA)
%feature("flatnested");
#endif

%inline %{
template <int>
struct OuterTemplate;

template <>
struct OuterTemplate<1>
{
  struct AbstractBase
  {
    virtual bool IsSameAs(const AbstractBase& other) const = 0;
    virtual ~AbstractBase() {}
  };

  struct ConcreteDerived : AbstractBase
  {
    ConcreteDerived() : m_value(0) {}
    explicit ConcreteDerived(int value) : m_value(value) {}

    virtual bool IsSameAs(const AbstractBase& other) const {
      return m_value == static_cast<const ConcreteDerived&>(other).m_value;
    }

    int m_value;
  };
};
%}

%template(OuterTemplate1) OuterTemplate<1>;
