%module(ruby_minherit="1") injecting_base_class

%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE) MultiDerived;	/* C#, D, Java, PHP multiple inheritance */

// In C++ a base class' name is a member of the base itself (its injected class name), so it is visible
// by name lookup from within a derived class, named either unqualified ('Base') or through the derived
// class ('Derived::Base').  SWIG resolves such a name to the base class' own type.

// These tests name a base that lives in a namespace, WITHOUT the namespace qualifier, as a type in many
// contexts - member and static variables, member, static and free function parameters and return
// values, by value, pointer and const reference, multiple and multi level inheritance, and through the
// derived class.  In every case it must resolve to the one base type.

%include <std_string.i>

%inline %{
#include <string>

namespace Space {
struct Base {
  Base() : tag("default") {}
  Base(const std::string &t) : tag(t) {}
  std::string tag;
  std::string whoami() const { return "Base:" + tag; }
};

struct Base2 {
  Base2() : id(0) {}
  Base2(int i) : id(i) {}
  int id;
};
}
%}

%inline %{
// Every use of 'Base' / 'Base2' below is unqualified: it names the namespaced base through its injected
// class name, visible because the class derives from it.
struct Derived : Space::Base {
  Derived() {}
  Derived(Base b) : Space::Base(b) {}   // constructor taking the base

  Base member;
  static Base sharedvar;

  Base by_value(Base b) const { return b; }
  Base *by_pointer(Base *b) const { return b; }
  Base by_cref(const Base &b) const { return b; }

  static Base make(const std::string &t) { return Base(t); }
  static Base static_id(Base b) { return b; }
};
%}

%{
Space::Base Derived::sharedvar = Space::Base("sharedvar");
%}

%inline %{
// Name the base through the derived class (Derived::Base) at namespace scope.
Derived::Base through_derived(Derived::Base b) { return b; }
Derived::Base *through_derived_ptr(Derived::Base *b) { return b; }

// Multiple inheritance
struct MultiDerived : Space::Base, Space::Base2 {
  MultiDerived() {}
  MultiDerived(Base b, Base2 b2) : Space::Base(b), Space::Base2(b2) {}   // constructor taking each base

  Base first(Base b) const { return b; }
  Base2 second(Base2 b) const { return b; }
};

// Multi level inheritance: name the indirect base unqualified, and through this class.
struct Derived2 : Derived {
  Derived2() {}
  Derived2(Derived2::Base b) : Derived(b) {}   // constructor taking the indirect base through this class

  Base from_grandbase(Base b) const { return b; }
  Derived2::Base from_grandbase_qualified(Derived2::Base b) const { return b; }
};

// Takes the base by its fully qualified type.  It must accept values produced by any of the functions
// above, proving every spelling of the base name resolves to the one Space::Base type.
Space::Base canonical(Space::Base b) { return b; }
int canonical2(Space::Base2 b) { return b.id; }
%}
