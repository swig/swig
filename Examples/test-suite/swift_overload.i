%module swift_overload

// Swift-specific test: overloaded free functions and members are dispatched to
// distinct Swift methods by the Swift backend.

%inline %{

class Calculator {
public:
  int add(int a, int b) { return a + b; }
  double add(double a, double b) { return a + b; }
  int add(int a, int b, int c) { return a + b + c; }
};

int twice(int x) { return x * 2; }
double twice(double x) { return x * 2; }

%}
