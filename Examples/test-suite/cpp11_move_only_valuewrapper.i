%module cpp11_move_only_valuewrapper

/*
 * This test case checks SwigValueWrapper and move assignment.
 * Although not necessary, the test case was developed testing with C++98 compatibility for comparing improvements.
 * C++11 and later is of course required for the move assignment support.
 * C++98 is not actually necesary now as the test-suite only runs this test with compilers that support C++11 and later.
*/

%{
#include <iostream>
#include <sstream>
using std::cout;
using std::endl;

#if __cplusplus >= 201103L
#include <memory>
#else
namespace std {
  // just something that will compile and vaguely work for when c++11 is not supported
  template <class T> class unique_ptr {
    T *ptr;
    public:
      unique_ptr(T *ptr = 0) : ptr(ptr) {}
      unique_ptr(const unique_ptr &a) : ptr(a.ptr) { /*please look away*/ const_cast<unique_ptr &>(a).ptr = 0;}
      ~unique_ptr() { delete ptr; }
      unique_ptr& operator=(const unique_ptr &a) {
        if (&a != this) {
          delete ptr;
          ptr = a.ptr;
          /*please look away*/ const_cast<unique_ptr &>(a).ptr = 0;
        }
        return *this;
      }
  };
}
#endif
%}

%include <std_string.i>

%valuewrapper XXX;
%ignore XXX::operator=;
%catches(std::string) XXX::check_counts;

%inline %{
bool debug = false;
struct XXX {
  XXX(int i = 0) { if (debug) cout << "XXX(" << i << ")" << " " << this << endl; normal_constructor_count++; }
  XXX(const XXX &other) { if (debug) cout << "XXX(const XXX &)" << " " << this << " " << &other << endl; copy_constructor_count++;}
  XXX & operator=(const XXX &other) { if (debug) cout << "operator=(const XXX &)" << " " << this << " " << &other << endl; copy_assignment_count++; return *this; }
#if defined(__cplusplus) && __cplusplus >= 201103L
  XXX(XXX &&other) noexcept { if (debug) cout << "XXX(XXX &&)" << " " << this << endl; move_constructor_count++; }
  XXX & operator=(XXX &&other) noexcept { if (debug) cout << "operator=(XXX &&)" << " " << this << endl; move_assignment_count++; return *this; }
#endif
  ~XXX() { if (debug) cout << "~XXX()" << " " << this << endl; destructor_count++; }
  static int normal_constructor_count;
  static int copy_constructor_count;
  static int copy_assignment_count;
  static int move_constructor_count;
  static int move_assignment_count;
  static int destructor_count;
  static void reset_counts() {
    XXX::normal_constructor_count = 0;
    XXX::copy_constructor_count = 0;
    XXX::copy_assignment_count = 0;
    XXX::move_constructor_count = 0;
    XXX::move_assignment_count = 0;
    XXX::destructor_count = 0;
  }
  // Check against expected counts of constructor, assignment operators etc.
  // Not observed during development, but compiler optimisation could change the expected values.
  // Throws exception if not correct (use %catches to catch them)
  static void check_counts(
      int normal_constructor_count,
      int copy_constructor_count,
      int copy_assignment_count,
      int move_constructor_count,
      int move_assignment_count,
      int destructor_count) {
    bool match = (
      normal_constructor_count == XXX::normal_constructor_count &&
      copy_constructor_count == XXX::copy_constructor_count &&
      copy_assignment_count == XXX::copy_assignment_count &&
      move_constructor_count == XXX::move_constructor_count &&
      move_assignment_count == XXX::move_assignment_count &&
      destructor_count == XXX::destructor_count);
    if (!match) {
      std::stringstream ss;
      ss << "check_counts failed" << std::endl <<
        XXX::normal_constructor_count << " " <<
        XXX::copy_constructor_count << " " <<
        XXX::copy_assignment_count << " " <<
        XXX::move_constructor_count << " " <<
        XXX::move_assignment_count << " " <<
        XXX::destructor_count << " " <<
        " (actual)" << std::endl <<
        normal_constructor_count << " " <<
        copy_constructor_count << " " <<
        copy_assignment_count << " " <<
        move_constructor_count << " " <<
        move_assignment_count << " " <<
        destructor_count << " " <<
        " (expected)" << std::endl;
      throw ss.str();
    }
  }
};

int XXX::normal_constructor_count = 0;
int XXX::copy_constructor_count = 0;
int XXX::copy_assignment_count = 0;
int XXX::move_constructor_count = 0;
int XXX::move_assignment_count = 0;
int XXX::destructor_count = 0;
bool has_cplusplus11() {
#if __cplusplus >= 201103L
  return true;
#else
  return false;
#endif
}
%}

#if defined(SWIGCSHARP)
%typemap(out) std::unique_ptr<XXX> %{
  if (debug) cout << "out start" << endl;
#if __cplusplus >= 201103L
  $result = new std::unique_ptr<XXX>(std::move(static_cast<std::unique_ptr<XXX>&>($1)));
#else
  $result = new std::unique_ptr<XXX>((const std::unique_ptr<XXX> &)$1);
#endif
  if (debug) cout << "out done" << endl;
%}

std::unique_ptr<XXX> makeUniqueXXX();
void cleanup(std::unique_ptr<XXX>* p);
#endif

%{
std::unique_ptr<XXX> makeUniqueXXX() {
  if (debug) cout << "makeUniqueXXX()" << endl;
  return std::unique_ptr<XXX>(new XXX(11));
}
void cleanup(std::unique_ptr<XXX>* p) {
  delete p;
}
%}

%inline %{
XXX createXXX() {
  if (debug) cout << "createXXX()" << endl;
  return XXX(111);
}
%}


%catches(std::string) test1;
%catches(std::string) test2;
%catches(std::string) test3;
%catches(std::string) test4;
%catches(std::string) test5;
%catches(std::string) test6;

%inline %{
// 'unit tests' for SwigValueWrapper
void test1() {
  XXX::reset_counts();
  {
    SwigValueWrapper<XXX> x;
    x = XXX();
  }
#if __cplusplus >= 201103L
  XXX::check_counts(1, 0, 0, 1, 0, 2); // was same as < c++11 counts below before move assignment operator added to SwigValueWrapper
#else
  XXX::check_counts(1, 1, 0, 0, 0, 2);
#endif
}
void test2() {
  XXX::reset_counts();
  {
    SwigValueWrapper<XXX> x;
    x = XXX();
    x = XXX();
  }
#if __cplusplus >= 201103L
  XXX::check_counts(2, 0, 0, 2, 0, 4);
#else
  XXX::check_counts(2, 2, 0, 0, 0, 4);
#endif
}
void test3() {
  XXX::reset_counts();
  {
    SwigValueWrapper<XXX> x;
    XXX a(999);
#if __cplusplus >= 201103L
    x = std::move(a);
#endif
  }
#if __cplusplus >= 201103L
  XXX::check_counts(1, 0, 0, 1, 0, 2);
#endif
}
void test4() {
  XXX::reset_counts();
  {
    SwigValueWrapper<std::unique_ptr<XXX> > x;
    x = std::unique_ptr<XXX>(new XXX(444));
  }
  XXX::check_counts(1, 0, 0, 0, 0, 1);
}
void test5() {
#if __cplusplus >= 201103L
  XXX::reset_counts();
  {
    SwigValueWrapper<std::unique_ptr<XXX> > x;
    x = std::unique_ptr<XXX>(new XXX(550));
    std::unique_ptr<XXX> x2(new XXX(555));
    x = std::move(x2);
  }
  XXX::check_counts(2, 0, 0, 0, 0, 2);
#endif
}
void test6() {
#if __cplusplus >= 201103L
  XXX::reset_counts();
  {
    // emulates how std::unique_ptr typemaps could be wrapped with SwigValueWrapper
    void *ptr = 0;
    SwigValueWrapper<std::unique_ptr<XXX> > x; // SWIG generated if std::unique_ptr<> definition not parsed
    x = makeUniqueXXX(); // SWIG generated code wrapping function returning std::unique_ptr
    ptr = new std::unique_ptr<XXX>(std::move((std::unique_ptr<XXX>&)x)); // 'out' typemap (move std::unique_ptr from stack to the heap), note non-const cast std::unique_tr<XXX>&
    delete (std::unique_ptr<XXX> *)ptr; // Final cleanup (user needs to call this)
  }
  XXX::check_counts(1, 0, 0, 0, 0, 1);
#endif
}
%}
