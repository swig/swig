%module xxx

struct NotConnected {};
struct Base {};
struct Derived : Base {};
struct MoreDerived : Derived {
  using Base::Base;
  using NotConnected::NotConnected;
};

template<typename T>
struct TemplateBase {};
template<typename T>
struct TemplateDerived : TemplateBase<T> {};
template<typename T>
struct TemplateMoreDerived : TemplateDerived<T> {
  using TemplateBase<T>::TemplateBase;
};

%template(TemplateBaseInt) TemplateBase<int>;
%template(TempDerivedInt) TemplateDerived<int>;
%template(TempMoreDerivedInt) TemplateMoreDerived<int>;
