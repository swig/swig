%module cpp20_spaceship_operator

%rename(spaceship) operator<=>;

// The canonical defaulted comparison operator has a deduced return type, which SWIG
// cannot deduce, so it is ignored with warning 345.
%warnfilter(SWIGWARN_CPP14_AUTO) Defaulted::operator<=>;
%rename(is_equal) Defaulted::operator==;

%inline %{
#include <compare>

int v = (-1 <=> 1 > 0) ? 7 : 42;

// We use !(a >= b) here due to limited support for (a < b) in SWIG's parser.
#define ALIEN !(0 <=> 1 >= 0)

const int SPACE = 3 <=> 3 == 0;

struct A {
  int v;

  explicit A(int v_) : v(v_) { }
};

int operator<=>(const A& a, const A& b) {
  return a.v - b.v;
}

int f(int v = (-1 <=> 1 > 0) ? 7 : 42) { return v; }

struct Defaulted {
  int v;

  explicit Defaulted(int v_) : v(v_) { }

  // Deduced return type - ignored, the deduced 'std::strong_ordering' would not be wrappable anyway.
  auto operator<=>(const Defaulted&) const = default;

  // A defaulted equality operator has to return bool, deduced or not, and is wrapped.
  bool operator==(const Defaulted&) const = default;
};

struct Deleted {
  int v;

  explicit Deleted(int v_) : v(v_) { }

  // Deleted functions with a deduced return type are ignored without a warning.
  auto operator<=>(const Deleted&) const = delete;
  auto m() const = delete;
};
%}

%constant int COMET = (4 <=> 2 > 0);
