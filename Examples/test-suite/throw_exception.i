%module throw_exception

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW(TYPES...) throw(TYPES)
%{
#define TESTCASE_THROW(TYPES...)
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
    void test_int() TESTCASE_THROW(int) {
      throw 37;
    }
    void test_msg() TESTCASE_THROW(const char *) {
      throw "Dead";
    }
    void test_cls() TESTCASE_THROW(CError) {
      throw CError();
    }	
    void test_cls_ptr() TESTCASE_THROW(CError *) {
      static CError StaticError;
      throw &StaticError;
    }	
    void test_cls_ref() TESTCASE_THROW(CError &) {
      static CError StaticError;
      throw StaticError;
    }	
    void test_cls_td() TESTCASE_THROW(Namespace::ErrorTypedef) {
      throw CError();
    }	
    void test_cls_ptr_td() TESTCASE_THROW(Namespace::ErrorPtr) {
      static CError StaticError;
      throw &StaticError;
    }	
    void test_cls_ref_td() TESTCASE_THROW(Namespace::ErrorRef) {
      static CError StaticError;
      throw StaticError;
    }	
    void test_array() TESTCASE_THROW(Namespace::IntArray) {
      static Namespace::IntArray array;
      for (int i=0; i<10; i++) {
        array[i] = i;
      }
      throw array;
    }	
    void test_enum() TESTCASE_THROW(Namespace::EnumTest) {
      throw Namespace::enum2;
    }	
    void test_multi(int x) TESTCASE_THROW(int, const char *, CError) {
      if (x == 1) throw 37;
      if (x == 2) throw "Dead";
      if (x == 3) throw CError();
    }
};

%}

