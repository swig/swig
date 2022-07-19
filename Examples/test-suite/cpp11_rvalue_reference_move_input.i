%module cpp11_rvalue_reference_move_input

// Testcase for testing rvalue reference input typemaps which assume the object is moved during a function call

#if defined(SWIGD)
%rename(trace) debug;
#endif

%include "cpp11_move_only_helper.i"

%rename(MoveAssign) MovableCopyable::operator=(MovableCopyable &&);
%ignore MovableCopyable::operator=(const MovableCopyable &); // ignore copy assignment operator, keep move assignment operator
%ignore MovableCopyable::MovableCopyable(const MovableCopyable &); // ignore copy constructor, keep the move constructor

%inline %{
#include <iostream>
using namespace std;

bool debug = false;

class MovableCopyable {
public:
  MovableCopyable(int i = 0) { if (debug) cout << "MovableCopyable(" << i << ")" << " " << this << endl; Counter::normal_constructor++; }

  MovableCopyable(const MovableCopyable &other) { if (debug) cout << "MovableCopyable(const MovableCopyable &)" << " " << this << " " << &other << endl; Counter::copy_constructor++;}
  MovableCopyable & operator=(const MovableCopyable &other) { if (debug) cout << "operator=(const MovableCopyable &)" << " " << this << " " << &other << endl; Counter::copy_assignment++; return *this; }

  MovableCopyable(MovableCopyable &&other) noexcept { if (debug) cout << "MovableCopyable(MovableCopyable &&)" << " " << this << endl; Counter::move_constructor++; }
  MovableCopyable & operator=(MovableCopyable &&other) noexcept { if (debug) cout << "operator=(MovableCopyable &&)" << " " << this << endl; Counter::move_assignment++; return *this; }
  ~MovableCopyable() { if (debug) cout << "~MovableCopyable()" << " " << this << endl; Counter::destructor++; }

  static void movein(MovableCopyable &&mcin) {
    MovableCopyable mc = std::move(mcin);
  }

  static bool is_nullptr(MovableCopyable *p) {
    return p == nullptr;
  }
};

%}
