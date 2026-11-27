// This tests shared_ptr is working okay. It also checks that there are no memory leaks in the
// class that shared_ptr is pointing via a counting mechanism in the constructors and destructor of Klass.
// In order to test that there are no leaks of the shared_ptr class itself (as it is created on the heap)
// the runtime tests can be run for a long time to monitor memory leaks using memory monitor tools
// like 'top'. There is a wrapper for shared_ptr in shared_ptr_wrapper.h which enables one to
// count the instances of shared_ptr. Uncomment the SHARED_PTR_WRAPPER macro to turn this on.
//
// Also note the debug_shared flag which can be set from the target language.

%module li_boost_shared_ptr

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK);

#if defined(SWIGSCILAB)
%rename(MbrVar) MemberVariables;
%rename(MbrVal) MemberVariables::MemberValue;
%rename(MbrPtr) MemberVariables::MemberPointer;
%rename(MbrRef) MemberVariables::MemberReference;
%rename(SmartMbrVal) MemberVariables::SmartMemberValue;
%rename(SmartMbrPtr) MemberVariables::SmartMemberPointer;
%rename(SmartMbrRef) MemberVariables::SmartMemberReference;
#endif

%inline %{
#include "boost/shared_ptr.hpp"
#include "swig_examples_lock.h"

// Uncomment macro below to turn on shared_ptr memory leak checking as described above
//#define SHARED_PTR_WRAPPER

#ifdef SHARED_PTR_WRAPPER
# include "shared_ptr_wrapper.h"
#endif
%}

%{
#ifndef SHARED_PTR_WRAPPER
# define TestBoost boost
#endif
%}

%include "std_string.i"
#ifndef SHARED_PTR_WRAPPER
# define SWIG_SHARED_PTR_NAMESPACE TestBoost
#endif

#if defined(SWIGC) || defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON) || defined(SWIGD) || defined(SWIGOCTAVE) || defined(SWIGRUBY) || defined(SWIGR) || defined(SWIGLUA)
#define SHARED_PTR_WRAPPERS_IMPLEMENTED
#endif

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)

%include <boost_shared_ptr.i>
%shared_ptr(Space::Klass)
%shared_ptr(Space::KlassDerived)
%shared_ptr(Space::Klass2ndDerived)
%shared_ptr(Space::Klass3rdDerived)
%shared_ptr(IgnoredMultipleInheritBase) // IgnoredMultipleInheritBase not actually used in any wrapped functions, so this isn't entirely necessary and warning 520 could instead have been suppressed.

#endif

// TODO:
// const shared_ptr
// std::vector
// Add in generic %extend for the Upcast function for derived classes
// Remove proxy upcast method - implement %feature("shadow") ??? which replaces the proxy method

%exception {
  if (debug_shared) {
    cout << "++++++" << endl;
    cout << "calling $name" << endl;
  }
  $action
  if (debug_shared) {
    cout << "------" << endl;
  }
}

%ignore IgnoredMultipleInheritBase;
%ignore Space::Klass::operator=;
%newobject pointerownertest();
%newobject smartpointerpointerownertest();

%inline %{
#include <iostream>
using namespace std;

static bool debug_shared = false;

namespace Space {

struct Klass {
  Klass() : value("EMPTY") { if (debug_shared) cout << "Klass() [" << value << "]" << endl; increment(); }

  Klass(const std::string &val) : value(val) { if (debug_shared) cout << "Klass(string) [" << value << "]" << endl; increment(); }

  virtual ~Klass() { if (debug_shared) cout << "~Klass() [" << value << "]" << endl; decrement(); }
  virtual std::string getValue() const { return value; }
  void append(const std::string &s) { value += s; }
  Klass(const Klass &other) : value(other.value) { if (debug_shared) cout << "Klass(const Klass&) [" << value << "]" << endl; increment(); }

  Klass &operator=(const Klass &other) { value = other.value; return *this; }
  static int getTotal_count() { return total_count; }

private:
  // lock increment and decrement as a destructor could be called at the same time as a
  // new object is being created - C# / Java, at least, have finalizers run in a separate thread
  static Examples::CriticalSection critical_section;
  static void increment() { Examples::Lock lock(critical_section); total_count++; if (debug_shared) cout << "      ++xxxxx Klass::increment tot: " << total_count << endl;}
  static void decrement() { Examples::Lock lock(critical_section); total_count--; if (debug_shared) cout << "      --xxxxx Klass::decrement tot: " << total_count << endl;}
  static int total_count;
  std::string value;
  int array[1024];
};
Examples::CriticalSection Space::Klass::critical_section;

struct IgnoredMultipleInheritBase {
  IgnoredMultipleInheritBase() : d(0.0), e(0.0) {}
  virtual ~IgnoredMultipleInheritBase() {}
  double d;
  double e;
  virtual void AVirtualMethod() {}
};

// For most compilers, this use of multiple inheritance results in different derived and base class
// pointer values ... for some more challenging tests :)
struct KlassDerived : IgnoredMultipleInheritBase, Klass {
  KlassDerived() : Klass() {}
  KlassDerived(const std::string &val) : Klass(val) {}
  KlassDerived(const KlassDerived &other) : Klass(other) {}
  virtual ~KlassDerived() {}
  virtual std::string getValue() const { return Klass::getValue() + "-Derived"; }
};
KlassDerived* derivedpointertest(KlassDerived* kd) {
  if (kd)
    kd->append(" derivedpointertest");
  return kd;
}
KlassDerived& derivedreftest(KlassDerived& kd) {
  kd.append(" derivedreftest");
  return kd;
}
TestBoost::shared_ptr<KlassDerived> derivedsmartptrtest(TestBoost::shared_ptr<KlassDerived> kd) {
  if (kd)
    kd->append(" derivedsmartptrtest");
  return kd;
}
TestBoost::shared_ptr<KlassDerived>* derivedsmartptrpointertest(TestBoost::shared_ptr<KlassDerived>* kd) {
  if (kd && *kd)
    (*kd)->append(" derivedsmartptrpointertest");
  return kd;
}
TestBoost::shared_ptr<KlassDerived>* derivedsmartptrreftest(TestBoost::shared_ptr<KlassDerived>* kd) {
  if (kd && *kd)
    (*kd)->append(" derivedsmartptrreftest");
  return kd;
}
TestBoost::shared_ptr<KlassDerived>*& derivedsmartptrpointerreftest(TestBoost::shared_ptr<KlassDerived>*& kd) {
  if (kd && *kd)
    (*kd)->append(" derivedsmartptrpointerreftest");
  return kd;
}

// 3 classes in inheritance chain test
struct Klass2ndDerived : Klass {
  Klass2ndDerived() : Klass() {}
  Klass2ndDerived(const std::string &val) : Klass(val) {}
};
struct Klass3rdDerived : IgnoredMultipleInheritBase, Klass2ndDerived {
  Klass3rdDerived() : Klass2ndDerived() {}
  Klass3rdDerived(const std::string &val) : Klass2ndDerived(val) {}
  virtual ~Klass3rdDerived() {}
  virtual std::string getValue() const { return Klass2ndDerived::getValue() + "-3rdDerived"; }
};

std::string test3rdupcast( TestBoost::shared_ptr< Klass > k) {
  return k->getValue();
}



TestBoost::shared_ptr<Klass> factorycreate() {
  return TestBoost::shared_ptr<Klass>(new Klass("factorycreate"));
}
// smart pointer
TestBoost::shared_ptr<Klass> smartpointertest(TestBoost::shared_ptr<Klass> k) {
  if (k)
    k->append(" smartpointertest");
  return TestBoost::shared_ptr<Klass>(k);
}
TestBoost::shared_ptr<Klass>* smartpointerpointertest(TestBoost::shared_ptr<Klass>* k) {
  if (k && *k)
    (*k)->append(" smartpointerpointertest");
  return k;
}
TestBoost::shared_ptr<Klass>& smartpointerreftest(TestBoost::shared_ptr<Klass>& k) {
  if (k)
    k->append(" smartpointerreftest");
  return k;
}
TestBoost::shared_ptr<Klass>*& smartpointerpointerreftest(TestBoost::shared_ptr<Klass>*& k) {
  if (k && *k)
    (*k)->append(" smartpointerpointerreftest");
  return k;
}
// const
TestBoost::shared_ptr<const Klass> constsmartpointertest(TestBoost::shared_ptr<const Klass> k) {
  return TestBoost::shared_ptr<const Klass>(k);
}
TestBoost::shared_ptr<const Klass>* constsmartpointerpointertest(TestBoost::shared_ptr<const Klass>* k) {
  return k;
}
TestBoost::shared_ptr<const Klass>& constsmartpointerreftest(TestBoost::shared_ptr<const Klass>& k) {
  return k;
}
// plain pointer
Klass valuetest(Klass k) {
  k.append(" valuetest");
  return k;
}
Klass *pointertest(Klass *k) {
  if (k)
    k->append(" pointertest");
  return k;
}
Klass& reftest(Klass& k) {
  k.append(" reftest");
  return k;
}
Klass *const& pointerreftest(Klass *const& k) {
  k->append(" pointerreftest");
  return k;
}
// null
std::string nullsmartpointerpointertest(TestBoost::shared_ptr<Klass>* k) {
  if (k && *k)
    return "not null";
  else if (!k)
    return "null smartpointer pointer";
  else if (!*k)
    return "null pointer";
  else
    return "also not null";
}

TestBoost::shared_ptr<Klass>* sp_pointer_null() { return NULL; }
TestBoost::shared_ptr<Klass>* null_sp_pointer() { static TestBoost::shared_ptr<Klass> static_sp; return &static_sp; }
TestBoost::shared_ptr<Klass> sp_value_null() { return TestBoost::shared_ptr<Klass>(); }
// $owner
Klass *pointerownertest() {
  return new Klass("pointerownertest");
}
TestBoost::shared_ptr<Klass>* smartpointerpointerownertest() {
  return new TestBoost::shared_ptr<Klass>(new Klass("smartpointerpointerownertest"));
}

// Provide overloads for Klass and derived classes as some language modules, eg Python, create an extra reference in
// the marshalling if an upcast to a base class is required.
long use_count(const TestBoost::shared_ptr<Klass3rdDerived>& sptr) {
  return sptr.use_count();
}
long use_count(const TestBoost::shared_ptr<Klass2ndDerived>& sptr) {
  return sptr.use_count();
}
long use_count(const TestBoost::shared_ptr<KlassDerived>& sptr) {
  return sptr.use_count();
}
long use_count(const TestBoost::shared_ptr<Klass>& sptr) {
  return sptr.use_count();
}

const TestBoost::shared_ptr<Klass>& ref_1() {
  static TestBoost::shared_ptr<Klass> sptr;
  return sptr;
}

// overloading tests
std::string overload_rawbyval(int i) { return "int"; }
std::string overload_rawbyval(Klass k) { return "rawbyval"; }

std::string overload_rawbyref(int i) { return "int"; }
std::string overload_rawbyref(Klass &k) { return "rawbyref"; }

std::string overload_rawbyptr(int i) { return "int"; }
std::string overload_rawbyptr(Klass *k) { return "rawbyptr"; }

std::string overload_rawbyptrref(int i) { return "int"; }
std::string overload_rawbyptrref(Klass *const&k) { return "rawbyptrref"; }



std::string overload_smartbyval(int i) { return "int"; }
std::string overload_smartbyval(TestBoost::shared_ptr<Klass> k) { return "smartbyval"; }

std::string overload_smartbyref(int i) { return "int"; }
std::string overload_smartbyref(TestBoost::shared_ptr<Klass> &k) { return "smartbyref"; }

std::string overload_smartbyptr(int i) { return "int"; }
std::string overload_smartbyptr(TestBoost::shared_ptr<Klass> *k) { return "smartbyptr"; }

std::string overload_smartbyptrref(int i) { return "int"; }
std::string overload_smartbyptrref(TestBoost::shared_ptr<Klass> *&k) { return "smartbyptrref"; }

} // namespace Space

%}
%{
  int Space::Klass::total_count = 0;
%}


// Member variables

%inline %{
struct MemberVariables {
  MemberVariables() : SmartMemberPointer(&SmartMemberValue), SmartMemberReference(SmartMemberValue), MemberPointer(0), MemberReference(MemberValue) {}
  TestBoost::shared_ptr<Space::Klass> SmartMemberValue;
  TestBoost::shared_ptr<Space::Klass> * SmartMemberPointer;
  TestBoost::shared_ptr<Space::Klass> & SmartMemberReference;
  Space::Klass MemberValue;
  Space::Klass * MemberPointer;
  Space::Klass & MemberReference;
};

// Global variables
TestBoost::shared_ptr<Space::Klass> GlobalSmartValue;
Space::Klass GlobalValue;
Space::Klass * GlobalPointer = 0;
Space::Klass & GlobalReference = GlobalValue;

%}

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)

// Note: %template after the shared_ptr typemaps
%shared_ptr(Base<int, double>)
%shared_ptr(Pair<int, double>)

#endif

// Templates
%inline %{
template <class T1, class T2> struct Base {
  Space::Klass klassBase;
  T1 baseVal1;
  T2 baseVal2;
  Base(T1 t1, T2 t2) : baseVal1(t1*2), baseVal2(t2*2) {}
  virtual std::string getValue() const { return "Base<>"; }
  virtual ~Base() {}
};
%}

#if !defined(SWIGSCILAB)
%template(BaseIntDouble) Base<int, double>;
#else
%template(BaseIDbl) Base<int, double>;
#endif

%inline %{
template <class T1, class T2> struct Pair : Base<T1, T2> {
  Space::Klass klassPair;
  T1 val1;
  T2 val2;
  Pair(T1 t1, T2 t2) : Base<T1, T2>(t1, t2), val1(t1), val2(t2) {}
  virtual std::string getValue() const { return "Pair<>"; }
};
Pair<int, double> pair_id2(Pair<int, double> p) { return p; }
TestBoost::shared_ptr< Pair<int, double> > pair_id1(TestBoost::shared_ptr< Pair<int, double> > p) { return p; }
%}

%template(PairIntDouble) Pair<int, double>;


// For counting the instances of shared_ptr (all of which are created on the heap)
// shared_ptr_wrapper_count() gives overall count
%inline %{
namespace TestBoost {
  const int NOT_COUNTING = -123456;
  int shared_ptr_wrapper_count() {
  #ifdef SHARED_PTR_WRAPPER
    return TestBoost::SharedPtrWrapper::getTotalCount();
  #else
    return NOT_COUNTING;
  #endif
  }
  #ifdef SHARED_PTR_WRAPPER
  template<> std::string show_message(boost::shared_ptr<Space::Klass >*t) {
    if (!t)
      return "null shared_ptr!!!";
    if (boost::get_deleter<SWIG_null_deleter>(*t))
      return "Klass NULL DELETER"; // pointer may be dangling so cannot use it
    if (*t)
      return "Klass: " + (*t)->getValue();
    else
      return "Klass: NULL";
  }
  template<> std::string show_message(boost::shared_ptr<const Space::Klass >*t) {
    if (!t)
      return "null shared_ptr!!!";
    if (boost::get_deleter<SWIG_null_deleter>(*t))
      return "Klass NULL DELETER"; // pointer may be dangling so cannot use it
    if (*t)
      return "Klass: " + (*t)->getValue();
    else
      return "Klass: NULL";
  }
  template<> std::string show_message(boost::shared_ptr<Space::KlassDerived >*t) {
    if (!t)
      return "null shared_ptr!!!";
    if (boost::get_deleter<SWIG_null_deleter>(*t))
      return "KlassDerived NULL DELETER"; // pointer may be dangling so cannot use it
    if (*t)
      return "KlassDerived: " + (*t)->getValue();
    else
      return "KlassDerived: NULL";
  }
  template<> std::string show_message(boost::shared_ptr<const Space::KlassDerived >*t) {
    if (!t)
      return "null shared_ptr!!!";
    if (boost::get_deleter<SWIG_null_deleter>(*t))
      return "KlassDerived NULL DELETER"; // pointer may be dangling so cannot use it
    if (*t)
      return "KlassDerived: " + (*t)->getValue();
    else
      return "KlassDerived: NULL";
  }
  #endif
}
%}

