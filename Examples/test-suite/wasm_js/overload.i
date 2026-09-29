%module overload
%inline %{
#include <string>
int choose(int n) { return n + 1; }
std::string choose(std::string s) { return s + "!"; }
int default_value(int n = 7) { return n; }
long default_long(long n = 8) { return n; }
long long default_wide(long long n = 9) { return n; }
class Base {
public:
  Base() {}
  virtual ~Base() {}
  int base() const { return 17; }
};
class Derived : public Base {
public:
  Derived(int n = 4) : value(n) {}
  int value;
};
int identify(Base *b) { return b->base(); }
int identify(int n) { return n; }
struct Left {
  Left(): left_value(17) {}
  int left_value;
  static int left_static() { return 19; }
};
struct GenCombined {
  GenCombined(): right_value(41) {}
  int right_value;
  int right() const { return right_value; }
};
struct Combined : Left, GenCombined {
};
int read_right(GenCombined *value) { return value->right_value; }
%}

%typemap(typecheck, precedence=5) int preferred {
  $1 = 1;
}
%typemap(typecheck, precedence=20) double fallback {
  $1 = 1;
}
%typemap(jstypecheck) int preferred "Number.isInteger($input)"
%typemap(jstypecheck) double fallback "typeof $input === 'number'"
%inline %{
std::string ranked(double fallback) { (void)fallback; return "fallback"; }
int ranked(int preferred) { return preferred + 100; }
class Fuzzy {
  int value_;
public:
  Fuzzy(double fallback, int offset = 1) : value_(static_cast<int>(fallback) + offset + 200) {}
  Fuzzy(int preferred, int offset = 1) : value_(preferred + offset + 300) {}
  int value() const { return value_; }
  std::string member(double fallback) { (void)fallback; return "fallback"; }
  int member(int preferred) { return preferred + 400; }
  static std::string stat(double fallback) { (void)fallback; return "fallback"; }
  static int stat(int preferred) { return preferred + 500; }
};
%}
