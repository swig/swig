%module basic
%inline %{
#include <string>
#include <stdexcept>
enum Colour { RED = 3, GREEN = 7 };
int add(int a, int b) { return a + b; }
long long wide(long long n) { return n + 1; }
bool negate(bool b) { return !b; }
std::string greet(std::string s) { return "hello " + s; }
int fail() { throw std::runtime_error("expected failure"); }
class Counter {
public:
  Counter(int n = 0) : value(n) {}
  int value;
  int increment(int n) { return value += n; }
  static int twice(int n) { return 2 * n; }
};
%}
