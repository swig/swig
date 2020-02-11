%module li_std_auto_ptr

#if defined(SWIGCSHARP) || defined(SWIGJAVA) || defined(SWIGPYTHON) || defined(SWIGRUBY)

// Prefer using std::unique_ptr<> if it's available, as auto_ptr<> generates
// deprecation warnings with C++14 compilers and may not exist at all when
// using C++17.
//
// As we can't test for C++11 support at SWIG time, we use an extra level of
// indirection, with SwigTest::auto_ptr being defined as either auto_ptr<> or
// unique_ptr<> below.
#define SWIG_AUTO_PTR_NAMESPACE SwigTest
%include "std_auto_ptr.i"

%auto_ptr(Klass)

%{
#include <memory>
#include <string>
#include "swig_examples_lock.h"
%}

%{
namespace SwigTest
{
#if __cplusplus >= 201103L || \
    (defined(_MSC_VER) && _MSC_VER >= 1800)
  template <typename T>
  using auto_ptr = std::unique_ptr<T>;
#else // No C++11 support
  using std::auto_ptr;
#endif
}
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

%template(KlassAutoPtr) SwigTest::auto_ptr<Klass>;

%inline {

SwigTest::auto_ptr<Klass> makeKlassAutoPtr(const char* label) {
  return SwigTest::auto_ptr<Klass>(new Klass(label));
}

}

#endif
