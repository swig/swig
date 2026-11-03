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

  // Const references to member pointers
  check("Square area", 100.0, do_op_cref(s, area_pt));
  check("Square perim", 40.0, do_op_cref(s, perimetervar_td_cref()));
  check("Square perim", 40.0, do_op(s, perimetervar_td_cref()));

  // Overloaded on the member pointer type
  check("Overload by value", 3, call_overloaded(ADD_BY_VALUE, 1, 2));
  check("Overload by pointer", -7, call_overloaded(ADD_BY_POINTER, 3, 4));
  check("Overload by int", 110, call_overloaded(10, 5, 6));

  // NULL member pointers
  enforce(get_null_memberpt() is null, "get_null_memberpt() is not null");
  enforce(is_null_memberpt(null), "is_null_memberpt(null) failed");
  enforce(is_null_memberpt(NULLPT), "is_null_memberpt(NULLPT) failed");
  enforce(!is_null_memberpt(area_pt), "is_null_memberpt(area_pt) failed");
  areavar = null;
  enforce(areavar is null, "areavar is not null");
  enforce(get_null_memberpt_cref() is null, "get_null_memberpt_cref() is not null");
  enforce(is_null_memberpt_cref(null), "is_null_memberpt_cref(null) failed");
  enforce(!is_null_memberpt_cref(area_pt), "is_null_memberpt_cref(area_pt) failed");
}

void check(string what, double expected, double actual) {
  enforce(expected == actual, "Failed: " ~ what ~ ": expected " ~
    to!string(expected) ~ ", but got " ~ to!string(actual));
}
