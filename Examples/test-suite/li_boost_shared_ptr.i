%module li_boost_shared_ptr

%{
#include "boost/shared_ptr.hpp"
%}

%include "std_string.i"
%include "boost_shared_ptr.i"

SWIG_SHARED_PTR(Klass, Space::Klass)
SWIG_SHARED_PTR_DERIVED(KlassDerived, Space::Klass, Space::KlassDerived)

// TODO:
// check const naturalvar
// const shared_ptr
// std::vector
// Add in generic %extend for the Upcast function for derived classes
// Can probably remove the pgcpp for shared_ptr, unless wrapping shared_ptr<>* shared_ptr<>& and use IntPtr instead of HandleRef for C# ???
// Put tests in a loop and monitor memory
// Remove proxy upcast method - implement %feature("shadow") ??? which replaces the shadow method
// Change GC to garbage collect until expected result with time out
// pgcpp - make it work if comments in jtype typemap

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
%ignore operator=;
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
  virtual std::string getValue() { return value; }
  void append(const std::string &s) { value += s; }
  Klass(const Klass &other) : value(other.value) { if (debug_shared) cout << "Klass(const Klass&) [" << value << "]" << endl; increment(); }

  Klass &operator=(const Klass &other) { value = other.value; return *this; }
  static int getTotal_count() { return total_count; }

private: // TODO: make operator= private too to test shared_ptr
  // lock increment and decrement as a destructor could be called at the same time as a new object is being created
  static void increment() { /*EnterCriticalSection(lock);*/ total_count++; }
  static void decrement() { /*EnterCriticalSection(lock);*/ total_count--; }
  static int total_count;
//  static CriticalSection lock;
  std::string value;
  int array[1024];
};

struct IgnoredMultipleInheritBase { virtual ~IgnoredMultipleInheritBase() {} double d; double e;};

// For most compilers, this use of multiple inheritance results in different derived and base class 
// pointer values ... for some more challenging tests :)
struct KlassDerived : IgnoredMultipleInheritBase, Klass {
  KlassDerived() : Klass() {}
  KlassDerived(const std::string &val) : Klass(val) {}
  virtual ~KlassDerived() {}
  virtual std::string getValue() { return Klass::getValue() + "-Derived"; }
};
KlassDerived* derivedpointertest(KlassDerived* kd) {
  if (kd)
    kd->append(" derivedpointertest");
  return kd;
}


boost::shared_ptr<Klass> factorycreate() {
  return boost::shared_ptr<Klass>(new Klass("factorycreate"));
}
// smart pointer
boost::shared_ptr<Klass> smartpointertest(boost::shared_ptr<Klass> k) {
  if (k)
    k->append(" smartpointertest");
  return boost::shared_ptr<Klass>(k);
}
boost::shared_ptr<Klass>* smartpointerpointertest(boost::shared_ptr<Klass>* k) {
  if (k && *k)
    (*k)->append(" smartpointerpointertest");
  return k;
}
boost::shared_ptr<Klass>& smartpointerreftest(boost::shared_ptr<Klass>& k) {
  if (k)
    k->append(" smartpointerreftest");
  return k;
}
boost::shared_ptr<Klass>*& smartpointerpointerreftest(boost::shared_ptr<Klass>*& k) {
  if (k && *k)
    (*k)->append(" smartpointerpointerreftest");
  return k;
}
// const
boost::shared_ptr<const Klass> constsmartpointertest(boost::shared_ptr<const Klass> k) {
  return boost::shared_ptr<const Klass>(k);
}
boost::shared_ptr<const Klass>* constsmartpointerpointertest(boost::shared_ptr<const Klass>* k) {
  return k;
}
boost::shared_ptr<const Klass>& constsmartpointerreftest(boost::shared_ptr<const Klass>& k) {
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
Klass*& pointerreftest(Klass*& k) {
  k->append(" pointerreftest");
  return k;
}
// null
std::string nullsmartpointerpointertest(boost::shared_ptr<Klass>* k) {
  if (k && *k)
    return "not null";
  else if (!k)
    return "null smartpointer pointer";
  else if (!*k)
    return "null pointer";
}
// $owner
Klass *pointerownertest() {
  return new Klass("pointerownertest");
}
boost::shared_ptr<Klass>* smartpointerpointerownertest() {
  return new boost::shared_ptr<Klass>(new Klass("smartpointerpointerownertest"));
}
/*
Klass* arraytest(Klass k[]) {
  k[0].append(" arraytest");
  return k;
}
*/


long use_count(const boost::shared_ptr<Klass>& sptr) {
  return sptr.use_count();
}
const boost::shared_ptr<Klass>& ref_1() { 
  static boost::shared_ptr<Klass> sptr;
  return sptr;
}

} // namespace Space

%}
%{
  int Space::Klass::total_count = 0;
%}


// Member variables

%inline %{
struct MemberVariables {
  MemberVariables() : SmartMemberPointer(&SmartMemberValue), SmartMemberReference(SmartMemberValue), MemberPointer(0), MemberReference(MemberValue) {}
  boost::shared_ptr<Space::Klass> SmartMemberValue;
  boost::shared_ptr<Space::Klass> * SmartMemberPointer;
  boost::shared_ptr<Space::Klass> & SmartMemberReference;
  Space::Klass MemberValue;
  Space::Klass * MemberPointer;
  Space::Klass & MemberReference;
};
%}

// Templates
%inline %{
template <class T1, class T2> struct Base {
};
typedef Base<int, double> BaseIntDouble_t;
%}
%template(BaseIntDouble) Base<int, double>;
%inline %{
template <class T1, class T2> struct Pair : Base<T1, T2> {
  T1 m_t1;
  T2 m_t2;
  Pair(T1 t1, T2 t2) : m_t1(t1), m_t2(t2) {}
};
%}
%template(PairIntDouble) Pair<int, double>;
SWIG_SHARED_PTR(BaseIntDouble, Base<int, double>)
// Note: cannot use Base<int, double> in the macro below because of the comma in the type, 
// so we use a typedef instead. Alternatively use %arg(Base<int, double>). %arg is defined in swigmacros.swg.
SWIG_SHARED_PTR_DERIVED(PairIntDouble, BaseIntDouble_t, Pair<int, double>)

