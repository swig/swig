// A class with a private assignment operator.
// This is rare, but sometimes used with singletons and
// objects that have complicated state.

%module private_assign

%inline %{
   class Foo {
   private:
       Foo &operator=(const Foo &f) {
           return *this;
       }
   public:
       void bar() { }
   };

   Foo blah() {
      return Foo();
   }
%}

#pragma SWIG nowarn=350 // operator new

%inline %{
  class TROOT {
  protected:
     void *operator new(size_t l) { return malloc(sizeof(TROOT)); }
   
  public:
    TROOT()
    {
    }

    TROOT(const char *name, const char *title, void *initfunc = 0)
    {
    }
  };

  class A : public TROOT
  {
  };
  
%}

#ifdef SWIGPYTHON

// This case only works in python
%inline %{
   struct Bar : Foo 
   {
   };
   
   Bar bar;
   
%}


#endif
