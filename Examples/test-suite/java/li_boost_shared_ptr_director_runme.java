public class li_boost_shared_ptr_runme {

  static {
    try {
      System.loadLibrary("li_boost_shared_ptr");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(String got, String expected) {
    if (!got.equals(expected))
      throw new RuntimeException("Failed, got: " + got + " expected: " + expected);
  }

  public static void main(String argv[]) {
    li_boost_shared_ptr_director_Derived a = li_boost_shared_ptr_director_Derived.new(false);
    li_boost_shared_ptr_director_Derived b = li_boost_shared_ptr_director_Derived.new(true);

    check(call_ret_c_shared_ptr(a) ==  1);
    check(call_ret_c_shared_ptr(b) == -1);
    check(call_ret_c_by_value(a)   ==  1);

    check(call_take_c_by_value(a)                  == 5);
    check(call_take_c_shared_ptr_by_value(a)       == 6);
    check(call_take_c_shared_ptr_by_ref(a)         == 7);
    check(call_take_c_shared_ptr_by_pointer(a)     == 8);
    check(call_take_c_shared_ptr_by_pointer_ref(a) == 9);

    check(call_take_c_shared_ptr_by_value_with_null(a)       == -2);
    check(call_take_c_shared_ptr_by_ref_with_null(a)         == -3);
    check(call_take_c_shared_ptr_by_pointer_with_null(a)     == -4);
    check(call_take_c_shared_ptr_by_pointer_ref_with_null(a) == -5);

  }
}

class li_boost_shared_ptr_director_Derived extends li_boost_shared_ptr_director.Base {

  @Override
  public String ping() {
    return "li_boost_shared_ptr_director_MyBarFoo.ping()";
  }

  @Override
  public String pong() {
    return "li_boost_shared_ptr_director_MyBarFoo.pong();" + ping();
  }

  @Override
  public String upcall(li_boost_shared_ptr_director.FooBar fooBarPtr) {
    return "override;" + fooBarPtr.FooBarDo();
  }

  @Override
  public li_boost_shared_ptr_director.Foo makeFoo() {
    return new li_boost_shared_ptr_director.Foo();
  }
}
