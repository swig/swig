%module cpp11_move_only

#if defined(SWIGD)
%rename(trace) debug;
#endif

%include "cpp11_move_only_helper.i"

%ignore MoveOnly::operator=;
//%valuewrapper MoveOnly; // SWIG sets %valuewrapper by default for move-only types

%inline %{
#include <iostream>
using namespace std;

bool debug = false;

struct MoveOnly {
  MoveOnly(int i = 0) { if (debug) cout << "MoveOnly(" << i << ")" << " " << this << endl; Counter::normal_constructor++; }

  MoveOnly(const MoveOnly &other) = delete;
  MoveOnly & operator=(const MoveOnly &other) = delete;

  MoveOnly(MoveOnly &&other) noexcept { if (debug) cout << "MoveOnly(MoveOnly &&)" << " " << this << endl; Counter::move_constructor++; }
  MoveOnly & operator=(MoveOnly &&other) noexcept { if (debug) cout << "operator=(MoveOnly &&)" << " " << this << endl; Counter::move_assignment++; return *this; }
  ~MoveOnly() { if (debug) cout << "~MoveOnly()" << " " << this << endl; Counter::destructor++; }

  static MoveOnly create() { return MoveOnly(111); }
  // static const MoveOnly createConst() { return MoveOnly(111); } // not supported by default

  // static void take(MoveOnly mo) { if (debug) cout << "take(MoveOnly)" << " " << &mo << endl; }
};
%}

%ignore MovableCopyable::operator=;
%ignore MovableCopyable::MovableCopyable(MovableCopyable &&);
// %valuewrapper MovableCopyable; // SWIG does not use valuewrapper by default for copyable types with a default constructor

%inline %{
// Movable and Copyable
struct MovableCopyable {
  MovableCopyable(int i = 0) { if (debug) cout << "MovableCopyable(" << i << ")" << " " << this << endl; Counter::normal_constructor++; }

  MovableCopyable(const MovableCopyable &other) { if (debug) cout << "MovableCopyable(const MovableCopyable &)" << " " << this << " " << &other << endl; Counter::copy_constructor++;}
  MovableCopyable & operator=(const MovableCopyable &other) { if (debug) cout << "operator=(const MovableCopyable &)" << " " << this << " " << &other << endl; Counter::copy_assignment++; return *this; }

  MovableCopyable(MovableCopyable &&other) noexcept { if (debug) cout << "MovableCopyable(MovableCopyable &&)" << " " << this << endl; Counter::move_constructor++; }
  MovableCopyable & operator=(MovableCopyable &&other) noexcept { if (debug) cout << "operator=(MovableCopyable &&)" << " " << this << endl; Counter::move_assignment++; return *this; }
  ~MovableCopyable() { if (debug) cout << "~MovableCopyable()" << " " << this << endl; Counter::destructor++; }

  static MovableCopyable create() { return MovableCopyable(111); }
  static const MovableCopyable createConst() { return MovableCopyable(111); }

  static void take(MovableCopyable mc) { if (debug) cout << "take(MovableCopyable)" << " " << &mc << endl; }
};
%}
