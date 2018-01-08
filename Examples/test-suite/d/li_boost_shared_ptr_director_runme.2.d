module li_boost_shared_ptr_director_runme;

import std.conv;
import std.exception;
import std.stdio;
import std.string;
import li_boost_shared_ptr_director.li_boost_shared_ptr_director;
import li_boost_shared_ptr_director.Base;
import li_boost_shared_ptr_director.C;

void check(int got, int expected) {
  enforce(got == expected, "Failed. got: " ~ to!string(got) ~ " Expected: " ~ to!string(expected));
}

void main() {
  Derived a = new Derived(false);
  Derived b = new Derived(true);

  check(call_ret_c_shared_ptr(a),  1);
  check(call_ret_c_shared_ptr(b), -1);
  check(call_ret_c_by_value(a),    1);

  check(call_ret_c_shared_ptr(a),  1);
  check(call_ret_c_shared_ptr(b), -1);
  check(call_ret_c_by_value(a),    1);

  check(call_take_c_by_value(a),                  5);
  check(call_take_c_by_ref(a),                    6);
  check(call_take_c_by_pointer(a),                7);
  check(call_take_c_by_pointer_ref(a),            8);
  check(call_take_c_shared_ptr_by_value(a),       9);
  check(call_take_c_shared_ptr_by_ref(a),         10);
  check(call_take_c_shared_ptr_by_pointer(a),     11);
  check(call_take_c_shared_ptr_by_pointer_ref(a), 12);

  check(call_take_c_by_pointer_with_null(a),                -2);
  check(call_take_c_by_pointer_ref_with_null(a),            -3);
  check(call_take_c_shared_ptr_by_value_with_null(a),       -4);
  check(call_take_c_shared_ptr_by_ref_with_null(a),         -5);
  check(call_take_c_shared_ptr_by_pointer_with_null(a),     -6);
  check(call_take_c_shared_ptr_by_pointer_ref_with_null(a), -7);
}

public class Derived : Base {

  private bool return_none;

  public this(bool flag) {
    super();
    this.return_none = flag;
  }

  public override C ret_c_shared_ptr() {
    if (this.return_none)
      return null;
    else
      return new C();
  }

  public override C ret_c_by_value() {
    return new C();
  }

  public override int take_c_by_value(C c) {
    return c.get_m();
  }

  public override int take_c_by_ref(C c) {
      return c.get_m();
  }

  public override int take_c_by_pointer(C c) {
    if (c !is null)
      return c.get_m();
    else
      return -2;
  }

  public override int take_c_by_pointer_ref(C c) {
    if (c !is null)
      return c.get_m();
    else
      return -3;
  }

  public override int take_c_shared_ptr_by_value(C c) {
    if (c !is null)
      return c.get_m();
    else
      return -4;
  }

  public override int take_c_shared_ptr_by_ref(C c) {
    if (c !is null)
      return c.get_m();
    else
      return -5;
  }

  public override int take_c_shared_ptr_by_pointer(C c) {
    if (c !is null)
      return c.get_m();
    else
      return -6;
  }

  public override int take_c_shared_ptr_by_pointer_ref(C c) {
    if (c !is null)
      return c.get_m();
    else
      return -7;
  }

}
