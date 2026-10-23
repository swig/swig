%module overload_kwargs

// Suppress the implicit copy constructor to keep the constructor overload set at exactly the two declared overloads.
%nocopyctor;
%feature("kwargs");

// Map the C++ error below onto TypeError, as bindings of C++ libraries with their own exception types commonly do.
%exception risky {
  try {
    $action
  } catch (const NegativeValueError &) {
    SWIG_exception(SWIG_TypeError, "risky: negative value");
  }
}

%header %{
#include <string.h>
%}

%inline %{
  struct NegativeValueError {
  };
  double gfoo() { return 0.0; }
  double gfoo(double x, double y) { return x + y; }

  struct MyStruct {
    MyStruct() : a_(0.0), b_(0.0) {}
    MyStruct(double a, double b) : a_(a), b_(b) {}
    double foo() { return 0.0; }
    double foo(double x, double y) { return x + y; }
    int bar(int aa) { return aa; }
    const char *bar(const char *bb) { return bb; }
    int baz() { return 0; }
    int baz(int x) { return x; }
    int baz(int x, int y) { return x + y; }
    int dup(int v) { return v; }
    const char *dup(const char *v) { return v; }
    int typed(int value) { return value * 2; }
    int typed(const char *value) { return (int)strlen(value); }
    int midDefault() { return -1; }
    int midDefault(int x, int y = 100, int z = 200) { return x + y + z; }
    int risky(int v) {
      if (v < 0)
        throw NegativeValueError();
      return v;
    }
    int risky(int v, int w) { return v + w; }
    static double sfoo(double x) { return 2 * x; }
    static double sfoo(double x, double y) { return x * y; }
    double getA() { return a_; }
    double getB() { return b_; }
  private:
    double a_;
    double b_;
  };
%}
