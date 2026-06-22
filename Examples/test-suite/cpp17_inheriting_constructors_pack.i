%module cpp17_inheriting_constructors_pack

// C++17 inheriting-constructor pack (P0195R2): a class deriving from a variadic base pack inherits
// the constructors of every base with a single 'using T::T ...;' declaration.  SWIG used to drop the
// last base's constructor and emit a spurious Warning 526 for it, naming the using-declaration after
// the derived class instead of the base (issue #3481).

%include <std_string.i>

// The instantiated classes have multiple bases, so the target languages that wrap multiple inheritance
// with a single proxy plus mix-in methods report their usual multiple inheritance notes.
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) Combined<IntBase, StringBase>;
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) Combined<IntBase, StringBase, MultiBase>;
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) Surrounded<IntBase, StringBase, MultiBase>;

%inline %{
#include <string>

// Each constructor records what it built into a shared value read back through last_constructed().
// A free function keeps the check identical in every target language and independent of how each
// language proxies multiple inheritance.  Every base is also default constructible, so constructing
// the derived class through one inherited constructor default constructs the other bases (which leave
// the shared value untouched).
static std::string g_last_constructed;

struct IntBase {
  IntBase() {}
  IntBase(int a) { g_last_constructed = "int:" + std::to_string(a); }
};

struct StringBase {
  StringBase() {}
  StringBase(std::string a) { g_last_constructed = "string:" + a; }
};

struct MultiBase {
  MultiBase() {}
  MultiBase(bool b, std::string s, int i = 10) {
    g_last_constructed = "multi:" + std::string(b ? "true" : "false") + ":" + s + ":" + std::to_string(i);
  }
};

template <typename... T>
struct Combined : T... {
  using T::T ...;
};

// Surrounded declares its own constructors immediately before and after the pack using-declaration, so
// the expanded inherited constructors are spliced into the middle of the member list.  This checks the
// sibling links either side of the using-declaration survive (the using-declaration is no longer the
// last child) and nothing is dropped or reordered.
template <typename... T>
struct Surrounded : T... {
  // Own default constructor so the class is unambiguously default constructible: the inheriting
  // constructor pack also makes each base's default constructor a candidate for Surrounded().
  Surrounded() {}
  Surrounded(int a, int b) { g_last_constructed = "before:" + std::to_string(a) + ":" + std::to_string(b); }
  using T::T ...;
  Surrounded(int a, int b, int c) { g_last_constructed = "after:" + std::to_string(a) + ":" + std::to_string(b) + ":" + std::to_string(c); }
};

std::string last_constructed() { return g_last_constructed; }
%}

%template(CombinedIS) Combined<IntBase, StringBase>;
%template(CombinedISM) Combined<IntBase, StringBase, MultiBase>;
%template(SurroundedISM) Surrounded<IntBase, StringBase, MultiBase>;
