%module cpp20_spaceship_operator

%rename(spaceship) operator<=>;

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
%}

%constant int COMET = (4 <=> 2 > 0);
