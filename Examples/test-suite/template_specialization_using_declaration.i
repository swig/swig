%module template_specialization_using_declaration

%include <std_string.i>

%inline %{
class ConcreteClass {
  int val;
public:
  ConcreteClass(int i = 0) : val(i) {}
  int concrete_value() { return val; }
};

namespace Space {
// primary template class
template<typename T>
struct BaseTemplate {
  void method_primary(T t) {}
  virtual ~BaseTemplate() {}
protected:
  void method_primary_hidden(T t) {}
};
// specialized template class
template<typename T>
struct BaseTemplate<T *> {
  void method_specialization(T t) {}
  virtual ~BaseTemplate() {}
protected:
  void method_specialization_hidden(T t) {}
};
// partially specialized template class
template<>
struct BaseTemplate<int> {
  void method_partial_specialization(int i) {}
  virtual ~BaseTemplate() {}
protected:
  void method_partial_specialization_hidden(int t) {}
};
}
%}

%template(BaseTemplateString) Space::BaseTemplate<std::string>;
%template(BaseTemplateConcreteClass) Space::BaseTemplate<ConcreteClass *>;
%template(BaseTemplateInt) Space::BaseTemplate<int>;

%inline %{
namespace Space {
// primary template class
template<typename T>
struct DerivedTemplate : BaseTemplate<T> {
  void method_primary_derived(T t) {}
  virtual ~DerivedTemplate() {}
  using BaseTemplate<T>::method_primary_hidden;
};
// specialized template class
template<typename T>
struct DerivedTemplate<T *> : BaseTemplate<T *> {
  void method_specialization_derived(T t) {}
  virtual ~DerivedTemplate() {}
  using BaseTemplate<T *>::method_specialization_hidden;
};
// partially specialized template class
template<>
struct DerivedTemplate<int> : BaseTemplate<int> {
  void method_partial_specialization_derived(int i) {}
  virtual ~DerivedTemplate() {}
  using BaseTemplate<int>::method_partial_specialization_hidden;
};
}
%}

%template(DerivedTemplateString) Space::DerivedTemplate<std::string>;
%template(DerivedTemplateConcreteClass) Space::DerivedTemplate<ConcreteClass *>;
%template(DerivedTemplateInt) Space::DerivedTemplate<int>;
