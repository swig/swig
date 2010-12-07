module member_pointer_runme;

import std.conv;
import std.exception;
import member_pointer.member_pointer;
import member_pointer.Square;
import member_pointer.SWIGTYPE_m_Shape__f_void__double;

void main() {
  auto s = new Square(10);

  // Do some calculations
  auto area_pt = areapt();
  auto perim_pt = perimeterpt();
  check("Square area", 100.0, do_op(s, area_pt));
  check("Square perim", 40.0, do_op(s, perim_pt));

  SWIGTYPE_m_Shape__f_void__double memberPtr = null;
  memberPtr = areavar;
  memberPtr = perimetervar;

  // Try the variables
  check("Square area", 100.0, do_op(s, areavar));
  check("Square perim", 40.0, do_op(s, perimetervar));

  // Modify one of the variables
  areavar = perim_pt;
  check("Square perimeter", 40.0, do_op(s,areavar));

  // Try the constants
  memberPtr = AREAPT;
  memberPtr = PERIMPT;
  memberPtr = NULLPT;

  check("Square area", 100.0, do_op(s, AREAPT));
  check("Square perim", 40.0, do_op(s, PERIMPT));
}

void check(string what, double expected, double actual) {
  enforce(expected == actual, "Failed: " ~ what ~ ": expected " ~
    to!string(expected) ~ ", but got " ~ to!string(actual));
}
