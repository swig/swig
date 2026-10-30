// This test checks SWIG's code generation for C++ functions
// and methods that differ only in constness.  

%module constover

%rename(test_pconst) test(const char *);
%rename(test_constm) test(char *) const;
%rename(test_pconstm) test(const char *) const;
%rename(test_cvm) test(char *) const volatile;

%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW, SWIGWARN_LANG_OVERLOAD_IGNORED) FooVolatileOverloaded::overloaded;

%inline %{

char *test(char *x) {
  return (char *) "test";
}

char *test(const char *x) {
  return (char *) "test_pconst";
}

 class Foo {
 public:
   Foo() { }
   char *test(char *x) {
     return (char *) "test";
   }
   char *test(const char *x) {
     return (char *) "test_pconst";
   }
   char *test(char *x) const {
     return (char *) "test_constmethod";
   }
   char *test(const char *x) const {
     return (char *) "test_pconstmethod";
   }
 };

 class FooVolatile {
 public:
   FooVolatile() { }
   char *test(char *x) volatile {
     return (char *) "test_volatilemethod";
   }
   char *test(char *x) const volatile {
     return (char *) "test_cvmethod";
   }
 };

 // The C target language gave both overloads the same name
 class FooVolatileOverloaded {
 public:
   FooVolatileOverloaded() { }
   char *overloaded(char *x) volatile {
     return (char *) "overloaded_volatilemethod";
   }
   char *overloaded(char *x) const volatile {
     return (char *) "overloaded_cvmethod";
   }
 };

%}

