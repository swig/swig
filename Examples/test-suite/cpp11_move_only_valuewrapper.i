%module cpp11_move_only_valuewrapper

/*
 * This test case checks SwigValueWrapper and move assignment.
 * Although not necessary, the test case was developed testing with C++98 compatibility for comparing improvements.
 * C++11 and later is of course required for the move assignment support.
 * C++98 is not actually necessary now as the test-suite only runs this test with compilers that support C++11 and later.
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

%include "cpp11_move_only_helper.i"

%valuewrapper XXX;
%ignore XXX::operator=;

%inline %{
bool trace = false;
struct XXX {
  XXX(int i = 0) { if (trace) cout << "XXX(" << i << ")" << " " << this << endl; Counter::normal_constructor++; }
  XXX(const XXX &other) { if (trace) cout << "XXX(const XXX &)" << " " << this << " " << &other << endl; Counter::copy_constructor++;}
  XXX & operator=(const XXX &other) { if (trace) cout << "operator=(const XXX &)" << " " << this << " " << &other << endl; Counter::copy_assignment++; return *this; }
#if defined(__cplusplus) && __cplusplus >= 201103L
  XXX(XXX &&other) noexcept { if (trace) cout << "XXX(XXX &&)" << " " << this << endl; Counter::move_constructor++; }
  XXX & operator=(XXX &&other) noexcept { if (trace) cout << "operator=(XXX &&)" << " " << this << endl; Counter::move_assignment++; return *this; }
#endif
  ~XXX() { if (trace) cout << "~XXX()" << " " << this << endl; Counter::destructor++; }
};

bool has_cplusplus11() {
#if __cplusplus >= 201103L
  return true;
#else
  return false;
#endif
}
%}

std::unique_ptr<XXX> makeUniqueXXX();
void cleanup(std::unique_ptr<XXX>* p);

%{
std::unique_ptr<XXX> makeUniqueXXX() {
  if (trace) cout << "makeUniqueXXX()" << endl;
  return std::unique_ptr<XXX>(new XXX(11));
}
void cleanup(std::unique_ptr<XXX>* p) {
  delete p;
}
typedef XXX UUU;
%}

%inline %{
XXX createXXX() {
  if (trace) cout << "createXXX()" << endl;
  return XXX(111);
}
XXX createXXX2() {
  if (trace) cout << "createXXX2()" << endl;
  return XXX(222);
}
UUU createUnknownType() {
  if (trace) cout << "createXXX2()" << endl;
  return XXX(222);
}
struct YYY {};
void inputByValue(UUU uuu, XXX xxx, YYY yyy) {}
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
  Counter::reset_counts();
  {
    SwigValueWrapper<XXX> x;
    x = XXX();
  }
#if __cplusplus >= 201103L
  Counter::check_counts(1, 0, 0, 1, 0, 2); // was same as < c++11 counts below before move assignment operator added to SwigValueWrapper
#else
  Counter::check_counts(1, 1, 0, 0, 0, 2);
#endif
}
void test2() {
  Counter::reset_counts();
  {
    SwigValueWrapper<XXX> x;
    x = XXX();
    x = XXX();
  }
#if __cplusplus >= 201103L
  Counter::check_counts(2, 0, 0, 2, 0, 4);
#else
  Counter::check_counts(2, 2, 0, 0, 0, 4);
#endif
}
void test3() {
  Counter::reset_counts();
  {
    SwigValueWrapper<XXX> x;
    XXX a(999);
#if __cplusplus >= 201103L
    x = std::move(a);
#endif
  }
#if __cplusplus >= 201103L
  Counter::check_counts(1, 0, 0, 1, 0, 2);
#endif
}
void test4() {
  Counter::reset_counts();
  {
    SwigValueWrapper<std::unique_ptr<XXX> > x;
    x = std::unique_ptr<XXX>(new XXX(444));
  }
  Counter::check_counts(1, 0, 0, 0, 0, 1);
}
void test5() {
#if __cplusplus >= 201103L
  Counter::reset_counts();
  {
    SwigValueWrapper<std::unique_ptr<XXX> > x;
    x = std::unique_ptr<XXX>(new XXX(550));
    std::unique_ptr<XXX> x2(new XXX(555));
    x = std::move(x2);
  }
  Counter::check_counts(2, 0, 0, 0, 0, 2);
#endif
}
void test6() {
#if __cplusplus >= 201103L
  Counter::reset_counts();
  {
    // emulates how std::unique_ptr typemaps could be wrapped with SwigValueWrapper
    void *ptr = 0;
    SwigValueWrapper<std::unique_ptr<XXX> > x; // SWIG generated if std::unique_ptr<> definition not parsed
    x = makeUniqueXXX(); // SWIG generated code wrapping function returning std::unique_ptr
    ptr = new std::unique_ptr<XXX>(x); // 'out' typemap (move std::unique_ptr from stack to the heap)
    delete (std::unique_ptr<XXX> *)ptr; // Final cleanup (user needs to call this)
  }
  Counter::check_counts(1, 0, 0, 0, 0, 1);
#endif
}
%}
