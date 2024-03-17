/* This testcase checks whether SWIG correctly parses C++11 explicitly defaulted functions and deleted functions */
%module cpp11_default_delete

%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED, SWIGWARN_LANG_OVERLOAD_SHADOW) trivial::trivial(trivial&&);
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED, SWIGWARN_LANG_OVERLOAD_SHADOW) trivial::operator =(trivial&&);

%rename(Assignment) *::operator=;

%inline %{

class NonCopyable {
public:
  NonCopyable& operator=(const NonCopyable&) = delete; /* Removes operator= */
  NonCopyable(const NonCopyable&) = delete; /* Removed copy constructor */
  NonCopyable() = default; /* Explicitly allows the empty constructor */
  void *operator new(size_t) = delete; /* Removes new NonCopyable */
};

struct A1 {
  void funk(int i) {}
  A1() = default;
  ~A1() = default;
  void funk(double i) = delete;  /* Don't cast double to int. Compiler returns an error */
private:
  A1(const A1&);
};
A1::A1(const A1&) = default;

struct A2 {
  void funk(int i) {}

// Workaround clang 10.0.1 -std=c++17 linker error (oddly for Java and not Python):
// Undefined symbols for architecture x86_64:"___cxa_deleted_virtual", referenced from: vtable for A2
#if !(defined(__clang__) && __cplusplus >= 201703L)
  virtual void fff(int) = delete;
#endif

  virtual ~A2() = default;
  template<class T> void funk(T) = delete;
};

struct trivial {
  trivial() = default;
  trivial(const trivial&) = default;
  trivial(trivial&&) = default;
  trivial& operator=(const trivial&) = default;
  trivial& operator=(trivial&&) = default;
  ~trivial() = default;
};

struct nontrivial1 {
  nontrivial1();
};
nontrivial1::nontrivial1() = default;

struct sometype {
  sometype() = delete;
  sometype(int) = delete;
  sometype(double);
  static sometype make(double d) { return sometype(d); }
  static void take(sometype s) {}
};
sometype::sometype(double) {}

struct sometype2 {
  sometype2() = delete;
  sometype2(double) {}
  static sometype2 make(double d) { return sometype2(d); }
  static void take(sometype2 s) {}
};

struct sometype3 {
  int num;
#if __cplusplus >= 202002L
  // Uniform/aggregate initialization was removed in C++20 if there is a user declared constructor, so the initialization in make() below does not work
  // This example can only be tested for C++11 to C++17, in C++20 the constructor declaration is removed by making it an aggregate
  // SWIG still sees the deleted constructor below
#else
  sometype3() = delete;
#endif
  static sometype3 make(int n) {
    // Note: Can only be constructed via copy constructor, so use C++11 uniform initialization to create
    return sometype3 {n};
  }
  static void take(sometype3 s) {}
};

/* Not working with prerelease of gcc-4.8
struct nonew {
  void *operator new(std::size_t) = delete;
  void *operator new[](std::size_t) = delete;
};
*/

struct moveonly {
  moveonly() = default;
  moveonly(const moveonly&) = delete;
  moveonly(moveonly&&) = default;
  moveonly& operator=(const moveonly&) = delete;
  moveonly& operator=(moveonly&&) = default;
  ~moveonly() = default;
};

struct ConstructorThrow {
  ConstructorThrow() throw() = default;
  ConstructorThrow(const ConstructorThrow&) throw() = delete;
  ConstructorThrow(ConstructorThrow&&) throw() = delete;
  ConstructorThrow& operator=(const ConstructorThrow&) throw() = delete;
  ~ConstructorThrow() throw() = default;
};

%}
