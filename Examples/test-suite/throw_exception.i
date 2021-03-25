%module throw_exception

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
#define TESTCASE_THROW3(T1, T2, T3) throw(T1, T2, T3)
%{
#define TESTCASE_THROW1(T1)
#define TESTCASE_THROW3(T1, T2, T3)
%}

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) Namespace::enum1;
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) Namespace::enum2;
#ifdef SWIGPHP
%warnfilter(SWIGWARN_PARSE_KEYWORD) Namespace;
#endif

// Tests SWIG's automatic exception mechanism

%inline %{

class CError {
};

void test_is_Error(CError *r) {}

namespace Namespace {
  typedef CError ErrorTypedef;
  typedef const CError& ErrorRef;
  typedef const CError* ErrorPtr;
  typedef int IntArray[10];
  enum EnumTest { enum1, enum2 };
}
class Foo {
public:
    void test_int() TESTCASE_THROW1(int) {
      throw 37;
    }
    void test_msg() TESTCASE_THROW1(const char *) {
      throw "Dead";
    }
    void test_cls() TESTCASE_THROW1(CError) {
      throw CError();
    }	
    void test_cls_ptr() TESTCASE_THROW1(CError *) {
      static CError StaticError;
      throw &StaticError;
    }	
    void test_cls_ref() TESTCASE_THROW1(CError &) {
      static CError StaticError;
      throw StaticError;
    }	
    void test_cls_td() TESTCASE_THROW1(Namespace::ErrorTypedef) {
      throw CError();
    }	
    void test_cls_ptr_td() TESTCASE_THROW1(Namespace::ErrorPtr) {
      static CError StaticError;
      throw &StaticError;
    }	
    void test_cls_ref_td() TESTCASE_THROW1(Namespace::ErrorRef) {
      static CError StaticError;
      throw StaticError;
    }	
    void test_array() TESTCASE_THROW1(Namespace::IntArray) {
      static Namespace::IntArray array;
      for (int i=0; i<10; i++) {
        array[i] = i;
      }
      throw array;
    }	
    void test_enum() TESTCASE_THROW1(Namespace::EnumTest) {
      throw Namespace::enum2;
    }	
    void test_multi(int x) TESTCASE_THROW3(int, const char *, CError) {
      if (x == 1) throw 37;
      if (x == 2) throw "Dead";
      if (x == 3) throw CError();
    }
};

%}

