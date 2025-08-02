%module cpp11_std_unique_ptr

#if !(defined(SWIGGO) || defined(SWIGOCAML) || defined(SWIGR) || defined(SWIGSCILAB))

%warnfilter(509, 516) overloadTest(Klass);
%warnfilter(509, 516) moveOverloadTest(Klass);
%warnfilter(509, 516) moveRefOverloadTest(Klass);
%warnfilter(509, 516) useRefOverloadTest(Klass);

%include "std_string.i"
%include "std_unique_ptr.i"

%unique_ptr(Klass)

%inline %{
#include <memory>
#include <string>
//#include <iostream>
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
// for testing class inheritance and unique_ptr
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

std::string takeKlassUniquePtr(std::unique_ptr<Klass> k) {
//  std::cout << "takeKlassUniquePtr " << std::hex << (Klass*)k.get() << std::endl;
  std::string s(k ? k->getLabel() : "null smart pointer");
//  std::cout << "takeKlassUniquePtr string: " << s << std::endl;
  return s;
}

std::string moveKlassUniquePtr(std::unique_ptr<Klass>&& k) {
//  std::cout << "moveKlassUniquePtr " << std::hex << (Klass*)k.get() << std::endl;
  std::string s(k ? k->getLabel() : "null smart pointer");
//  std::cout << "moveKlassUniquePtr string: " << s << std::endl;
  return s;
}

std::string moveRefKlassUniquePtr(std::unique_ptr<Klass>& k) {
//  std::cout << "moveRefKlassUniquePtr " << std::hex << (Klass*)k.get() << std::endl;
  std::string s(k ? k->getLabel() : "null smart pointer");
//  std::cout << "moveRefKlassUniquePtr string: " << s << std::endl;
  return s;
}

std::string useRefKlassUniquePtr(const std::unique_ptr<Klass>& k) {
//  std::cout << "useRefKlassUniquePtr " << std::hex << (Klass*)k.get() << std::endl;
  std::string s(k ? k->getLabel() : "null smart pointer");
//  std::cout << "useRefKlassUniquePtr string: " << s << std::endl;
  return s;
}

Klass *make_null() {
  return nullptr;
}

bool is_nullptr(Klass *p) {
  return p == nullptr;
}

Klass *get_not_owned_ptr(Klass *p) {
  return p;
}

std::unique_ptr<Klass> makeKlassUniquePtr(const char* label) {
  return std::unique_ptr<Klass>(new Klass(label));
}

std::unique_ptr<Klass> makeNullUniquePtr() {
  return std::unique_ptr<Klass>();
}

#include <iostream>
std::unique_ptr<Klass>&& makeRVRKlassUniquePtr(const char* label) {
  static std::unique_ptr<Klass> up;
#if !defined(SWIGTCL)
  up.reset(label ? new Klass(label) : nullptr);
#else // No way to pass a null pointer for a string as "NULL" is only way for Tcl to specify a null pointer
  up.reset(strcmp(label, "NULL") != 0 ? new Klass(label) : nullptr);
#endif
  return std::move(up);
}

std::unique_ptr<Klass>& makeRefKlassUniquePtr(const char* label) {
  static std::unique_ptr<Klass> up;
#if !defined(SWIGTCL)
  up.reset(label ? new Klass(label) : nullptr);
#else // No way to pass a null pointer for a string as "NULL" is only way for Tcl to specify a null pointer
  up.reset(strcmp(label, "NULL") != 0 ? new Klass(label) : nullptr);
#endif
  return up;
}


int overloadTest() {
  return 0;
}

int overloadTest(std::unique_ptr<Klass> kover) {
  return 1;
}

int overloadTest(Klass k) {
  return 2;
}

int moveOverloadTest() {
  return 0;
}

int moveOverloadTest(std::unique_ptr<Klass>&& kover) {
  return 1;
}

int moveOverloadTest(Klass k) {
  return 2;
}

int moveRefOverloadTest() {
  return 0;
}

int moveRefOverloadTest(std::unique_ptr<Klass>& kover) {
  return 1;
}

int moveRefOverloadTest(Klass k) {
  return 2;
}

int useRefOverloadTest() {
  return 0;
}

int useRefOverloadTest(const std::unique_ptr<Klass>& kover) {
  return 1;
}

int useRefOverloadTest(Klass k) {
  return 2;
}

%}

#endif
