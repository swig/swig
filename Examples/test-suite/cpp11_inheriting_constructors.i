/* This test checks whether SWIG correctly parses the new constructor
   inheritance.
*/
%module cpp11_inheriting_constructors

%inline %{
// Delegating constructors
class BaseClass {
private:
  int _val;
protected:
  // Protected, so it is only wrapped when a using declaration brings it into a public interface.
  int protectedValue() { return _val; }
public:
  BaseClass(int iValue) { _val = iValue; }
  int retrieveValue() { return _val; }
};

// Constructor inheritance via using declaration
class DerivedClass: public BaseClass {
public:
  using BaseClass::BaseClass; // Adds DerivedClass(int) constructor
};

// Member initialization at the site of the declaration
class SomeClass {
public:
    SomeClass() {}
    explicit SomeClass(int new_value) : value(new_value) {}

    int value = 5;
};

// 'base_type' is a typedef for DerivedClass, which inherits its constructors with a using
// declaration.  Like any constructor, that inheriting-constructor using declaration is named after
// its class, so when SWIG resolves the typedef to the class it names it has to find the class
// itself and not the same-named constructor.  If it picks the constructor, 'base_type::protectedValue'
// does not resolve and the protected method is never brought into the public interface.
class UseInheritCtorTypedef : public DerivedClass {
public:
  UseInheritCtorTypedef(int v) : DerivedClass(v) {}
  typedef DerivedClass base_type;
  using base_type::protectedValue;
};

// Template-mixin variant: the base is a template instantiation whose constructors are inherited
// through the template parameter (TInheritCtor<T> : T { using T::T; }), and a protected base method
// is brought into the public interface through a typedef naming that base.  The inheriting-constructor
// using declaration is named after its class, so resolving the typedef to the class it names must
// find the class itself and not the same-named constructor, otherwise 'base_type::protectedValue'
// does not resolve.  See issue #2951.
template <typename T> class TInheritCtor : public T {
public:
  using T::T;
};
%}

%template(TInheritCtorBase) TInheritCtor<BaseClass>;

%inline %{
class UseTemplateInheritCtor : public TInheritCtor<BaseClass> {
public:
  UseTemplateInheritCtor(int v) : TInheritCtor<BaseClass>(v) {}
  typedef TInheritCtor<BaseClass> base_type;
  using base_type::protectedValue;
};
%}
