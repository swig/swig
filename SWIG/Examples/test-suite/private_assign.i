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

