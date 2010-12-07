// Lots of tests for methods with default parameters / default arguments

%module default_args

%{
#if defined(_MSC_VER)
  #pragma warning(disable: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif
%}

%include <std_string.i>

%inline %{
  #include <string>

  // Anonymous arguments
  int anonymous(int = 7771);
  int anonymous(int x) { return x; }

  // Bug [548272] Default arguments
  bool booltest(bool x = true) { return x; }

  // scoped enums
  enum flavor { BITTER, SWEET };
  class EnumClass {
    public:
      enum speed { FAST, SLOW };
      // Note: default values should be EnumClass::FAST and SWEET 
      bool blah(speed s = FAST, flavor f = SWEET) { return (s == FAST && f == SWEET); };
  };

  // casts
  const char * casts1(const char *m = (const char *) NULL) {
    char *ret = NULL; 
    if (m) { 
      ret = new char[strlen(m)+1];
      strcpy(ret, m);
    }
    return ret;
  }
  const char * casts2(const char *m = (const char *) "Hello") {
    char *ret = NULL; 
    if (m) { 
      ret = new char[strlen(m)+1];
      strcpy(ret, m);
    }
    return ret;
  }

  // char
  char chartest1(char c = 'x') { return c; }
  char chartest2(char c = '\0') { return c; }

  // namespaces
  namespace AType { 
    enum AType { NoType }; 
  } 
  void dummy(AType::AType aType = AType::NoType) {}
  namespace A { 
    namespace B { 
      int CONST_NUM = 10; 
    } 
    int afunction(int i = B::CONST_NUM) { return i; }
  } 

  // references
  int reftest1(const int &x = 42) { return x; }
  std::string reftest2(const std::string &x = "hello") { return x; }

  // enum scope
  class Tree {
    public:
      enum types {Oak, Fir, Cedar};
      void chops(enum types type) {}
      void test(int x = Oak + Fir + Cedar) {}
  };
  enum Tree::types chops(enum Tree::types type) { return type; }
 
%}

// Rename a class member
%rename(bar2) Foo::bar;
%rename(newname) Foo::oldname(int x = 1234);
%ignore Foo::Foo(int x, int y = 0, int z = 0);
%ignore Foo::meth(int x, int y = 0, int z = 0);
%rename(renamed3arg) Foo::renameme(int x, double d) const;
%rename(renamed2arg) Foo::renameme(int x) const;
%rename(renamed1arg) Foo::renameme() const;

%inline %{

  // Define a class
  class Foo {
    public:
      static int bar;
      static int spam;

      Foo(){}
     
      Foo(int x, int y = 0, int z = 0){}

      void meth(int x, int y = 0, int z = 0){}
    
      // Use a renamed member as a default argument.  SWIG has to resolve
      // bar to Foo::bar and not Foo::spam.  SWIG-1.3.11 got this wrong.
      // (Different default parameter wrapping in SWIG-1.3.23 ensures SWIG doesn't have to resolve these symbols).
      void method1(int x = bar) {}

      // Use unrenamed member as default
      void method2(int x = spam) {}

      // test the method itself being renamed
      void oldname(int x = 1234) {}
      void renameme(int x = 1234, double d=123.4) const {}
  };
  int Foo::bar = 1;
  int Foo::spam = 2;
%}


// tests valuewrapper
%feature("compactdefaultargs") MyClass2::set;
%inline %{
  enum MyType { Val1, Val2 }; 

  class MyClass1 
  { 
    public: 
      MyClass1(MyType myType) {}
  }; 

  class MyClass2 
  { 
    public : 
      void set(MyClass1 cl1 = Val1) {}
      // This could have been written : set(MyClass1 cl1 = MyClass1(Val1)) 
      // But it works in C++ since there is a "conversion" constructor in  MyClass1. 
      void set2(MyClass1 cl1 = Val1) {}
  };
%}


// Default parameters with exception specifications
%inline %{
void exceptionspec(int a = -1) throw (int, const char*) {
  if (a == -1)
    throw "ciao";
  else
    throw a;
}
struct Except {
  Except(bool throwException, int a = -1) throw (int) {
    if (throwException)
      throw a;
  }
  void exspec(int a = 0) throw (int, const char*) {
    ::exceptionspec(a);
  }
};
%}

// Default parameters in static class methods
#ifdef SWIGPYTHON
%rename(staticMethod) staticmethod;
#endif

%inline %{
namespace SpaceName {
  struct Statics {
    static int staticmethod(int a=10, int b=20, int c=30) { return a+b+c; }
  };
}
%}


// Tests which could never be wrapped prior to changes in default argument wrapping implemented in SWIG-1.3.23:
%inline %{
class Tricky {
  static int getDefault() { return 500; }
  enum { privatevalue = 200 };
  static const char charvalue;
public:
  int privatedefault(int val = privatevalue) { return val; }
  int protectedint(int val = intvalue) { return val; }
  double protecteddouble(double val = doublevalue) { return val; }
  int functiondefault(int val = Tricky::getDefault()) { return val; }
  char contrived(const char *c = &charvalue) { return *c; }
protected:
  static const int intvalue = 2000;
  static const double doublevalue;
};
const char Tricky::charvalue = 'X';
const double Tricky::doublevalue = 987.654;


// tests default argument which is a constructor call within namespace
// also tests default constructor (from defaulted parameter)
namespace Space {
struct Klass {
  int val;
  Klass(int val = -1) : val(val) {}
};
Klass constructorcall(const Klass& k = Klass()) { return k; }

}
%}

%{
struct ConstMethods {
  int coo(double d = 0.0) { return 10; }
  int coo(double d = 0.0) const { return 20; }
};
%}

// const methods 
// runtime test needed to check that the const method is called
struct ConstMethods {
  int coo(double d = 0.0) const;
};



// Default args with C linkage
%inline
%{
  extern "C" double cfunc1(double x,double p = 1) {
    return(x+p);
  }

  extern "C" {
    double cfunc2(double x,double p = 2) {
      return(x+p);
    }

    double cfunc3(double x,double p = 3) {
      return(x+p);
    }

    typedef struct Pointf { 
      double		x,y; 
    } Pointf;
  }
%}
