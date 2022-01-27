%module li_std_auto_ptr

%{
#if __GNUC__ >= 5 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 8)
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // auto_ptr deprecation
#endif

#if defined(__clang__)
#pragma clang diagnostic push
// Suppress 'auto_ptr<>' is deprecated
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#endif
%}

#if defined(SWIGCSHARP) || defined(SWIGJAVA) || defined(SWIGPYTHON) || defined(SWIGRUBY)

%include "std_auto_ptr.i"

%auto_ptr(Klass)

%{
#if __cplusplus < 201703L
#include <memory>
#else
// Simple std::auto_ptr implementation for testing after its removal in C++17
namespace std {
  template <class T> class auto_ptr {
    T *ptr;
    public:
      auto_ptr(T *ptr = 0) : ptr(ptr) {}
      auto_ptr(auto_ptr&& a) : ptr(a.ptr) { a.ptr = 0;}
      ~auto_ptr() { delete ptr; }
      T *release() { T *p = ptr; ptr = 0; return p; }
      auto_ptr& operator=(auto_ptr&& a) { if (&a != this) { delete ptr; ptr = a.ptr; a.ptr = 0; } return *this; }
  };
}
#endif

#include <string>
#include "swig_examples_lock.h"
%}

%inline %{

class Klass {
public:
  explicit Klass(const char* label) :
    m_label(label)
  {
    SwigExamples::Lock lock(critical_section);
    total_count++;
  }

  const char* getLabel() const { return m_label.c_str(); }

  ~Klass()
  {
    SwigExamples::Lock lock(critical_section);
    total_count--;
  }

  static int getTotal_count() { return total_count; }

private:
  static SwigExamples::CriticalSection critical_section;
  static int total_count;

  std::string m_label;
};

SwigExamples::CriticalSection Klass::critical_section;
int Klass::total_count = 0;

%}

%template(KlassAutoPtr) std::auto_ptr<Klass>;

%inline %{

std::auto_ptr<Klass> makeKlassAutoPtr(const char* label) {
  return std::auto_ptr<Klass>(new Klass(label));
}

%}

#endif
