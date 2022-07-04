%module cpp11_std_unique_ptr

#if defined(SWIGCSHARP) || defined(SWIGJAVA) || defined(SWIGPYTHON) || defined(SWIGRUBY)

%include "std_unique_ptr.i"

%unique_ptr(Klass)

%inline %{
#include <memory>
#include <string>
#include "swig_examples_lock.h"

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

%inline %{

std::unique_ptr<Klass> makeKlassUniquePtr(const char* label) {
  return std::unique_ptr<Klass>(new Klass(label));
}

%}

#endif
