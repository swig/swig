%module overload_kwargs

%nocopyctor;
%feature("kwargs");

%inline %{
  struct MyStruct {
    MyStruct() : a_(0.0), b_(0.0) {}
    MyStruct(double a, double b) : a_(a), b_(b) {}
    double foo() { return 0.0; }
    double foo(double x, double y) { return x + y; }
    double getA() { return a_; }
    double getB() { return b_; }
  private:
    double a_;
    double b_;
  };
%}
