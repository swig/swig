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

#if !(defined(SWIGGO) || defined(SWIGOCAML) || defined(SWIGR) || defined(SWIGSCILAB))

%warnfilter(509, 516) overloadTest(Klass);

%include "std_string.i"
//#include <iostream>
%include "std_auto_ptr.i"

%auto_ptr(Klass)

%inline %{
void show_cplusplus_version() {
  printf("__cplusplus %d\n", (int)__cplusplus);
}
%}

%{
#if __cplusplus < 201703L
#include <memory>
#else

// If <memory> has already been include (Octave does) then unfortunately gcc incorrectly still provides
// std::auto_ptr when _GLIBCXX_USE_DEPRECATED is defined by the compiler configuration/OS/who knows what!!
#include <memory> // Now need to include it in case _GLIBCXX_USE_DEPRECATED is defined and <memory> has not been included, argh
#if !defined(_GLIBCXX_USE_DEPRECATED)
// Simple std::auto_ptr implementation for testing after its removal in C++17
namespace std {
  template <class T> class auto_ptr {
    T *ptr;
    public:
      explicit auto_ptr(T *p = 0) : ptr(p) {}
      auto_ptr(auto_ptr&& a) : ptr(a.ptr) { a.ptr = 0;}
      ~auto_ptr() { delete ptr; }
      T *release() { T *p = ptr; ptr = 0; return p; }
      T* get() const { return ptr; }
      void reset(T *p = 0) { delete ptr; ptr = p; }
      T &operator*() const { return *ptr; }
      T *operator->() const { return ptr; }
      auto_ptr& operator=(auto_ptr&& a) { if (&a != this) { delete ptr; ptr = a.ptr; a.ptr = 0; } return *this; }
  };
}
#endif

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

  virtual ~Klass()
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

%inline %{

// Virtual inheritance used as this usually results in different values for Klass* and KlassInheritance*
// for testing class inheritance and auto_ptr
struct KlassInheritance : virtual Klass {
  KlassInheritance(const char* label) : Klass(label) {
    // std::cout << "ptrs.... " << std::hex << (Klass*)this << " " << (KlassInheritance*)this << std::endl;
  }
};

std::string useKlassRawPtr(Klass* k) {
//  std::cout << "useKlassRawPtr " << std::hex << (Klass*)k << std::endl;
  std::string s(k->getLabel());
//  std::cout << "useKlassRawPtr string: " << s << std::endl;
  return s;
}

std::string takeKlassAutoPtr(std::auto_ptr<Klass> k) {
//  std::cout << "takeKlassAutoPtr " << std::hex << (Klass*)k.get() << std::endl;
  std::string s(k.get() ? k->getLabel() : "null smart pointer");
//  std::cout << "takeKlassAutoPtr string: " << s << std::endl;
  return s;
}

Klass *make_null() {
  return 0;
}

bool is_nullptr(Klass *p) {
  return p == 0;
}

Klass *get_not_owned_ptr(Klass *p) {
  return p;
}

std::auto_ptr<Klass> makeKlassAutoPtr(const char* label) {
  return std::auto_ptr<Klass>(new Klass(label));
}

std::auto_ptr<Klass> makeNullAutoPtr() {
  return std::auto_ptr<Klass>();
}

int overloadTest() {
  return 0;
}

int overloadTest(std::auto_ptr<Klass> kover) {
  return 1;
}

int overloadTest(Klass k) {
  return 2;
}

%}

#endif
