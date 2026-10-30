// This test checks SWIG's code generation for C++ functions
// and methods that differ only in constness.  

%module constover

%rename(test_pconst) test(const char *);
%rename(test_constm) test(char *) const;
%rename(test_pconstm) test(const char *) const;
%rename(test_cvm) test(char *) const volatile;

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

%}

