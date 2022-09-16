
namespace Space {
struct Klass {
  Klass(int i) {}
  Klass() {}
};
}

namespace AnotherSpace {
  class Another {};
}

namespace Space {
  using namespace AnotherSpace;
  enum Enu { En1, En2, En3 };
  template<typename T> struct NotXYZ {};
  template<typename T> class XYZ {
    NotXYZ<int> *m_int;
    T m_t;
    NotXYZ<T> m_notxyz;
  public:
    operator NotXYZ<int>*() const { return m_int; }
    operator XYZ<int>*() const { return 0; }
    operator Another() const { Another an; return an; }
    void templateT(T i) {}
    void templateNotXYZ(NotXYZ<T> i) {}
    void templateXYZ(XYZ<T> i) {}
    operator T() { return m_t; }
    operator NotXYZ<T>() const { return m_notxyz; }
  };
}

#if defined(SWIG)
%exception Space::ABC::operator ABC %{
#if defined(__clang__)
  // Workaround for: warning: conversion function converting 'Space::ABC' to itself will never be used
  _swig_result = *arg1;
#else
  $action
#endif
%}
#endif

namespace Space {
// non-templated class using itself in method and operator
class ABC {
  public:
    void method(ABC a) const {}
    void method(Klass k) const {}
    operator ABC*() const { return new ABC(); }
    operator Klass() const { Klass k; return k; }
};
}

