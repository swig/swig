%module cpp11_variadic_function_templates

// Some tests for variadic function templates
%inline %{
class A {
public:
  A() {
    a = 100;
  }
  virtual ~A() {}
  int a;
};

class B {
public:
  B() {
    b = 200;
  }
  virtual ~B() {}
  int b;
};

class C {
public:
  C() {
    c = 300;
  }
  virtual ~C() {}
  int c;
};

class D {
public:
  D() {
    d = 400;
  }
  virtual ~D() {}
  int d;
};
%}

// #1863
%inline %{
class Container {
public:
template<typename... Args>
  static void notifyMyTypes(void (fn)(Args...)); // unconventional function (ptr)
template<typename... Args>
  static void notifyMyTypesA(void (*fn)(Args...)) {} // conventional function ptr
template<typename... Args>
  static void notifyMyTypesB(void fn(Args...)) {}; // unconventional function (ptr)
};
%}
%{
template<typename... Args>
  void Container::notifyMyTypes(void (fn)(Args...)) {}

// Explicit template instantiations
template void Container::notifyMyTypes<>(void (tt)());
template void Container::notifyMyTypes<int>(void (tt)(int));
template void Container::notifyMyTypes<int, double>(void (tt)(int, double));
%}

// Not supported (most vexing parse), see Extending.html#Extending_nn7
//%template(ContainerNotifyMyTypes1) Container::notifyMyTypes<int>;
%template(ContainerNotifyMyTypesA1) Container::notifyMyTypesA<int>;
%template(ContainerNotifyMyTypesB1) Container::notifyMyTypesB<int>;

// #1863
%inline %{
#include <type_traits>
class EmplaceContainer {
public:
template<typename T, typename... Args>
void emplace(Args &&... args) noexcept(
    std::is_nothrow_constructible<T, Args &&...>::value) {}
};
%}

%template(emplace) EmplaceContainer::emplace<int,A>;
// TODO
//%template(emplace) EmplaceContainer::emplace<int,A,B,C>;
