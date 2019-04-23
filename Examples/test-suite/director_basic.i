%module(directors="1") director_basic

#ifdef SWIGOCAML
%warnfilter(SWIGWARN_PARSE_KEYWORD) method;
#endif

%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) MyClass::pmethod;

 %{
 #include <string>

 class Foo {
 public:
   virtual ~Foo() {}
   virtual std::string ping() { return "Foo::ping()"; }
   virtual std::string pong() { return "Foo::pong();" + ping(); }

   static Foo* get_self(Foo *slf) {return slf;}
   
 };

 %}

 %include <std_string.i>

 %feature("director") Foo;


 class Foo {
 public:
   virtual ~Foo();
   virtual std::string ping();
   virtual std::string pong();
   
   static Foo* get_self(Foo *slf);
   
 };

 %{
 #include <complex> 
 %}
 %feature("director") A;

 // basic renaming
 %rename(rg) A::gg;
 %feature("nodirector") hi::A1::gg;

 %inline %{

 struct A{
     A(std::complex<int> i, double d=0.0) {}
     A(int i, bool j=false) {}
     virtual ~A() {}

     virtual int f(int i=0) {return i;}
     virtual int gg(int i=0) {return i;}
 };

 namespace hi  {

   struct A1 : public A {
     A1(std::complex<int> i, double d=0.0) : A(i, d) {}
     A1(int i, bool j=false) : A(i, j) {}

     virtual int ff(int i = 0) {return i;}  
   };
 }


 %}

 %typemap(cscode) MyClass %{
   public void testSwigDerivedClassHasMethod() {
     if (SwigDerivedClassHasMethod("nonVirtual", swigMethodTypes3))
       throw new global::System.Exception("non-overriding non-virtual method would be when connecting director");
     if (SwigDerivedClassHasMethod("nonOverride", swigMethodTypes4))
       throw new global::System.Exception("non-overriding virtual method would be when connecting director");
   }
 %}

 %feature("director") MyClass;

 %inline %{

 typedef void VoidType;

  struct Bar
  {
    int x;
    Bar(int _x = 0) : x(_x)
    {
    }
 };
 
 

class MyClass {
public:
  MyClass(int a = 0) 
  {
  }
  
  virtual void method(VoidType *)
  {
  }
  
  virtual ~MyClass()
  {
  }

  virtual Bar vmethod(Bar b)
  {
    b.x += 13;
    return b;
  }  

  virtual Bar* pmethod(Bar *b)
  {
    b->x += 12;
    return b;
  }  

  Bar cmethod(const Bar &b)
  {
    return vmethod(b);
  }  

  static MyClass *get_self(MyClass *c) 
  {
    return c;
  }

  static Bar * call_pmethod(MyClass *myclass, Bar *b) {
    return myclass->pmethod(b);
  }

  virtual int nonVirtual()
  {
    return 100;
  }

  virtual int nonOverride()
  {
    return 101;
  }

  static int call_nonVirtual(MyClass *myclass)
  {
    return myclass->nonVirtual();
  }

  static int call_nonOverride(MyClass *myclass)
  {
    return myclass->nonOverride();
  }

  // Collisions with generated method names
  virtual void Connect() { }
};

template<class T>
class MyClassT {
public:
  MyClassT(int a = 0) 
  {
  }
  
  virtual void method(VoidType *)
  {
  }
  
  virtual ~MyClassT()
  {
  }
  
};

%}

%template(MyClassT_i) MyClassT<int>;
