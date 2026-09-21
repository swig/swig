%module julia_basic

%inline %{
#include <stdexcept>
#include <string>
int add(int a, int b = 4) { return a + b; }
double twice(double value) { return value * 2; }
bool invert(bool value) { return !value; }
std::string greet(const std::string& name) { return "Hello " + name; }
int fail() { throw std::runtime_error("expected failure"); }
class Counter {
public:
  int value;
  Counter(int initial = 0) : value(initial) {}
  int increment(int delta = 1) { return value += delta; }
  static int answer() { return 42; }
};
%}
