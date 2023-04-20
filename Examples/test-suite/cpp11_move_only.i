%module cpp11_move_only

%include "cpp11_move_only_helper.i"

#if defined(SWIGOCAML)
%rename(valu) val;
#endif

%ignore MoveOnly::operator=;
//%valuewrapper MoveOnly; // SWIG sets %valuewrapper by default for move-only types

%inline %{
#include <iostream>
using namespace std;

bool trace = false;

struct MoveOnly {
  int val;
  MoveOnly(int i = 0) : val(i) { if (trace) cout << "MoveOnly(" << i << ")" << " " << this << endl; Counter::normal_constructor++; }

  MoveOnly(const MoveOnly &other) = delete;
  MoveOnly & operator=(const MoveOnly &other) = delete;

  MoveOnly(MoveOnly &&other) noexcept : val(std::move(other.val)) { if (trace) cout << "MoveOnly(MoveOnly &&)" << " " << this << endl; Counter::move_constructor++; }
  MoveOnly & operator=(MoveOnly &&other) noexcept { if (trace) cout << "operator=(MoveOnly &&)" << " " << this << endl; Counter::move_assignment++; if (this != &other) { val = std::move(other.val); } return *this; }
  ~MoveOnly() { if (trace) cout << "~MoveOnly()" << " " << this << endl; Counter::destructor++; }

  static MoveOnly create() { return MoveOnly(111); }
  // static const MoveOnly createConst() { return MoveOnly(111); } // not supported by default

  // compile error by default, see cpp11_move_typemaps.i
  #if defined(WRAP_TAKE_METHOD)
  static void take(MoveOnly mo) { if (trace) cout << "take(MoveOnly)" << " " << &mo << endl; }
  #endif
};
%}

%ignore MovableCopyable::operator=;
%ignore MovableCopyable::MovableCopyable(MovableCopyable &&);
// %valuewrapper MovableCopyable; // SWIG does not use valuewrapper by default for copyable types with a default constructor

%inline %{
// Movable and Copyable
struct MovableCopyable {
  int val;
  MovableCopyable(int i = 0) : val(i) { if (trace) cout << "MovableCopyable(" << i << ")" << " " << this << endl; Counter::normal_constructor++; }

  MovableCopyable(const MovableCopyable &other) : val(other.val) { if (trace) cout << "MovableCopyable(const MovableCopyable &)" << " " << this << " " << &other << endl; Counter::copy_constructor++;}
  MovableCopyable & operator=(const MovableCopyable &other) { if (trace) cout << "operator=(const MovableCopyable &)" << " " << this << " " << &other << endl; Counter::copy_assignment++; if (this != &other) { val = other.val; } return *this; }

  MovableCopyable(MovableCopyable &&other) noexcept : val(std::move(other.val)) { if (trace) cout << "MovableCopyable(MovableCopyable &&)" << " " << this << endl; Counter::move_constructor++; }
  MovableCopyable & operator=(MovableCopyable &&other) noexcept { if (trace) cout << "operator=(MovableCopyable &&)" << " " << this << endl; Counter::move_assignment++; if (this != &other) { val = std::move(other.val); } return *this; }
  ~MovableCopyable() { if (trace) cout << "~MovableCopyable()" << " " << this << endl; Counter::destructor++; }

  static MovableCopyable create() { return MovableCopyable(111); }
  static const MovableCopyable createConst() { return MovableCopyable(111); }

  static void take(MovableCopyable mc) { if (trace) cout << "take(MovableCopyable)" << " " << &mc << endl; }
};
%}
