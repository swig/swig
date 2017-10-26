using System;
using li_boost_shared_ptr_directorNamespace;

public class li_boost_shared_ptr_director_runme {

  private static void check(int got, int expected) {
    if (got != expected)
      throw new Exception("Failed, got: " + got + " expected: " + expected);
  }

  public static void Main() {
    Derived a = new Derived(false);
    Derived b = new Derived(true);

    check(li_boost_shared_ptr_director.call_ret_c_shared_ptr(a),  1);
    check(li_boost_shared_ptr_director.call_ret_c_shared_ptr(b), -1);
    check(li_boost_shared_ptr_director.call_ret_c_by_value(a),    1);

    check(li_boost_shared_ptr_director.call_ret_c_shared_ptr(a),  1);
    check(li_boost_shared_ptr_director.call_ret_c_shared_ptr(b), -1);
    check(li_boost_shared_ptr_director.call_ret_c_by_value(a),    1);

    check(li_boost_shared_ptr_director.call_take_c_by_value(a),                  5);
    check(li_boost_shared_ptr_director.call_take_c_by_ref(a),                    6);
    check(li_boost_shared_ptr_director.call_take_c_by_pointer(a),                7);
    check(li_boost_shared_ptr_director.call_take_c_by_pointer_ref(a),            8);
    check(li_boost_shared_ptr_director.call_take_c_shared_ptr_by_value(a),       9);
    check(li_boost_shared_ptr_director.call_take_c_shared_ptr_by_ref(a),         10);
    check(li_boost_shared_ptr_director.call_take_c_shared_ptr_by_pointer(a),     11);
    check(li_boost_shared_ptr_director.call_take_c_shared_ptr_by_pointer_ref(a), 12);

    check(li_boost_shared_ptr_director.call_take_c_by_pointer_with_null(a),                -2);
    check(li_boost_shared_ptr_director.call_take_c_by_pointer_ref_with_null(a),            -3);
    check(li_boost_shared_ptr_director.call_take_c_shared_ptr_by_value_with_null(a),       -4);
    check(li_boost_shared_ptr_director.call_take_c_shared_ptr_by_ref_with_null(a),         -5);
    check(li_boost_shared_ptr_director.call_take_c_shared_ptr_by_pointer_with_null(a),     -6);
    check(li_boost_shared_ptr_director.call_take_c_shared_ptr_by_pointer_ref_with_null(a), -7);
  }

}

class Derived : Base {

  private bool return_none;

  public Derived(bool flag) : base() {
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
    if (c != null)
      return c.get_m();
    else
      return -2;
  }

  public override int take_c_by_pointer_ref(C c) {
    if (c != null)
      return c.get_m();
    else
      return -3;
  }

  public override int take_c_shared_ptr_by_value(C c) {
    if (c != null)
      return c.get_m();
    else
      return -4;
  }

  public override int take_c_shared_ptr_by_ref(C c) {
    if (c != null)
      return c.get_m();
    else
      return -5;
  }

  public override int take_c_shared_ptr_by_pointer(C c) {
    if (c != null)
      return c.get_m();
    else
      return -6;
  }

  public override int take_c_shared_ptr_by_pointer_ref(C c) {
    if (c != null)
      return c.get_m();
    else
      return -7;
  }

}
