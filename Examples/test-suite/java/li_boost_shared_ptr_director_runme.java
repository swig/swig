import li_boost_shared_ptr_director.*;

public class li_boost_shared_ptr_director_runme {

  static {
    try {
      System.loadLibrary("li_boost_shared_ptr_director");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(int got, int expected) {
    if (got != expected)
      throw new RuntimeException("Failed, got: " + got + " expected: " + expected);
  }

  public static void main(String argv[]) {
    li_boost_shared_ptr_director_Derived a = new li_boost_shared_ptr_director_Derived(false);
    li_boost_shared_ptr_director_Derived b = new li_boost_shared_ptr_director_Derived(true);

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

class li_boost_shared_ptr_director_Derived extends Base {

  private boolean return_none;

  li_boost_shared_ptr_director_Derived(boolean flag) {
    super();
    this.return_none = flag;
  }

  @Override
  public C ret_c_shared_ptr() {
    if (this.return_none)
      return null;
    else
      return new C();
  }

  @Override
  public C ret_c_by_value() {
    return new C();
  }

  @Override
  public int take_c_by_value(C c) {
      return c.get_m();
  }

  @Override
  public int take_c_by_ref(C c) {
      return c.get_m();
  }

  @Override
  public int take_c_by_pointer(C c) {
    if (c != null)
      return c.get_m();
    else
      return -2;
  }

  @Override
  public int take_c_by_pointer_ref(C c) {
    if (c != null)
      return c.get_m();
    else
      return -3;
  }

  @Override
  public int take_c_shared_ptr_by_value(C c) {
    if (c != null)
      return c.get_m();
    else
      return -4;
  }

  @Override
  public int take_c_shared_ptr_by_ref(C c) {
    if (c != null)
      return c.get_m();
    else
      return -5;
  }

  @Override
  public int take_c_shared_ptr_by_pointer(C c) {
    if (c != null)
      return c.get_m();
    else
      return -6;
  }

  @Override
  public int take_c_shared_ptr_by_pointer_ref(C c) {
    if (c != null)
      return c.get_m();
    else
      return -7;
  }

}
