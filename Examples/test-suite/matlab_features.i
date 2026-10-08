%module matlab_features
%include <std_string.i>
%include <std_vector.i>
%include <std_map.i>
%include <exception.i>
%template(IntMap) std::map<int, int>;
%template(DoubleVector) std::vector<double>;
%exception {
  try {
    $action
  } catch (const std::exception& e) {
    SWIG_exception(SWIG_RuntimeError, e.what());
  }
}
%newobject make_base;
%inline %{
#include <stdexcept>
static int destroyed = 0;
struct Base {
  virtual ~Base() { ++destroyed; }
  virtual int value() const = 0;
};
struct Derived : Base {
  int value() const { return 42; }
};
Base *make_base() { return new Derived(); }
int destruction_count() { return destroyed; }
int read_base(const Base &b) { return b.value(); }
std::string echo_string(const std::string &s) { return s; }
std::vector<double> double_values(const std::vector<double> &values) {
  std::vector<double> result(values);
  for (size_t i = 0; i < result.size(); ++i) result[i] *= 2;
  return result;
}
std::map<int, int> make_map() {
  std::map<int, int> result;
  result[2] = 17;
  return result;
}
int read_map(const std::map<int, int> &value) { return value.at(2); }
int choose(const std::vector<double> &) { return 1; }
int choose(double) { return 2; }
int choose(const char *) { return 3; }
unsigned long long checked_unsigned(unsigned long long value) { return value; }
long long checked_signed(long long value) { return value; }
int checked_integer(int value) { return value; }
double checked_double(double value) { return value; }
void fail_message() { throw std::runtime_error("expected failure"); }
%}
