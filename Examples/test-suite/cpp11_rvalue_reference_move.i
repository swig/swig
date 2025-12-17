%module cpp11_rvalue_reference_move

// Testcase for testing rvalue reference input typemaps which assume the object is moved during a function call

%include "cpp11_move_only_helper.i"

%catches(std::string) MovableCopyable::check_numbers_match;

%rename(MoveAssign) MovableCopyable::operator=(MovableCopyable &&);
%ignore MovableCopyable::operator=(const MovableCopyable &); // ignore copy assignment operator, keep move assignment operator
%ignore MovableCopyable::MovableCopyable(const MovableCopyable &); // ignore copy constructor, keep the move constructor

%inline %{
#include <iostream>
using namespace std;

bool trace = false;

class MovableCopyable {
  int num;
public:
  MovableCopyable(int i = 0) : num(i) { if (trace) cout << "MovableCopyable(" << i << ")" << " " << this << endl; Counter::normal_constructor++; }

  MovableCopyable(const MovableCopyable &other) : num(other.num) { if (trace) cout << "MovableCopyable(const MovableCopyable &)" << " " << this << " " << &other << endl; Counter::copy_constructor++;}
  MovableCopyable & operator=(const MovableCopyable &other) { if (trace) cout << "operator=(const MovableCopyable &)" << " " << this << " " << &other << endl; Counter::copy_assignment++; num = other.num; return *this; }

  MovableCopyable(MovableCopyable &&other) noexcept : num(std::move(other.num)) { if (trace) cout << "MovableCopyable(MovableCopyable &&)" << " " << this << endl; Counter::move_constructor++; }
  MovableCopyable & operator=(MovableCopyable &&other) noexcept { if (trace) cout << "operator=(MovableCopyable &&)" << " " << this << endl; Counter::move_assignment++; num = std::move(other.num); return *this; }
  ~MovableCopyable() { if (trace) cout << "~MovableCopyable()" << " " << this << endl; Counter::destructor++; }

  int getNum() { return num; }

  static void movein(MovableCopyable &&mcin) {
    MovableCopyable mc = std::move(mcin);
  }

  static MovableCopyable && moveout(int i) {
    static MovableCopyable instance;
    instance = MovableCopyable(i);
    return std::move(instance);
  }

  static bool is_nullptr(MovableCopyable *p) {
    return p == nullptr;
  }

  static void check_numbers_match(MovableCopyable *p, int expected_num) {
    if (p->num != expected_num)
      throw std::string("Numbers don't match");
  }
};
%}
