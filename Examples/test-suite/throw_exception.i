%module throw_exception

// Tests SWIG's automatic exception mechanism

%inline %{

class Error {
};

namespace Namespace {
  typedef Error ErrorTypedef;
  typedef const Error& ErrorRef;
  typedef const Error* ErrorPtr;
};
class Foo {
public:
    void test_int() throw(int) {
      throw 37;
    }
    void test_msg() throw(const char *) {
      throw "Dead";
    }
    void test_cls() throw(Error) {
      throw Error();
    }	
    void test_cls_ptr() throw(Error *) {
      static Error StaticError;
      throw &StaticError;
    }	
    void test_cls_ref() throw(Error &) {
      static Error StaticError;
      throw StaticError;
    }	
    void test_cls_td() throw(Namespace::ErrorTypedef) {
      throw Error();
    }	
    void test_cls_ptr_td() throw(Namespace::ErrorPtr) {
      static Error StaticError;
      throw &StaticError;
    }	
    void test_cls_ref_td() throw(Namespace::ErrorRef) {
      static Error StaticError;
      throw StaticError;
    }	
    void test_multi(int x) throw(int, const char *, Error) {
      if (x == 1) throw 37;
      if (x == 2) throw "Dead";
      if (x == 3) throw Error();
    }
};

 %}

