%module valuewrapper_opaque

/* 
 *  Opaque types
 */
%{
template<typename T> class TemplateClass {
public:
TemplateClass<T>(T a) {}
};

struct B
{
};

class C
{
public:
  C(int){}
};
%}


/*
 * Hint swig that the Opaque type B don't need the value wrapper.
 * This hint is only necessary in very very special cases.
 */
%feature("novaluewrapper") B;
class B;


%inline %{

class A 
{
public:
  A(int){}
};

class Klass {};


TemplateClass<Klass> getKlass(Klass k) {
  TemplateClass<Klass> t(k);
  return t;
}


TemplateClass<A> getA(A a) {
  TemplateClass<A> t(a);
  return t;
}


TemplateClass<B> getA(B b) {
  TemplateClass<B> t(b);
  return t;
}


TemplateClass<C> getC(C a) {
  TemplateClass<C> t(a);
  return t;
}


TemplateClass<int> getInt(int a) {
  TemplateClass<int> t(a);
  return t;
}

A sgetA(A a) {
  return a;
}

Klass sgetKlass(Klass a) {
  return a;
}

template <class T> 
struct auto_ptr
{
  auto_ptr(T a){}
};

auto_ptr<A> getPtrA(auto_ptr<A> a) {
  return a;
}

B getB(B a) {
  return a;
}
 
%}

%template() auto_ptr<A>;
