%module throw_exception

// Tests SWIG's automatic exception mechanism

%inline %{

class Error {
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
    void test_multi(int x) throw(int, const char *, Error) {
      if (x == 1) throw 37;
      if (x == 2) throw "Dead";
      if (x == 3) throw Error();
    }
};

 %}

