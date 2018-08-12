// Test director pointer typemaps in typemaps.i - similar to java_director_typemaps.i testcase

import java_director_typemaps_ptr.*;
import java.math.BigInteger;

public class java_director_typemaps_ptr_runme {

  static {
    try {
      System.loadLibrary("java_director_typemaps_ptr");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }


  public static void main(String argv[]) {
    java_director_typemaps_ptr_MyQuux myquux = new java_director_typemaps_ptr_MyQuux();
    Quux quux = myquux;
    quux.etest();
    myquux.testing_nulls = true;
    quux.nulltest();
  }
}

class java_director_typemaps_ptr_MyQuux extends Quux {
  public java_director_typemaps_ptr_MyQuux() {
    super();
  }
  public boolean testing_nulls = false;

  public void director_method_output(
      boolean[] bool_arg,

      byte[] signed_char_arg,
      short[] unsigned_char_arg,

      short[] short_arg,
      int[] unsigned_short_arg,

      int[] int_arg,
      long[] unsigned_int_arg,

      int[] long_arg,
      long[] unsigned_long_arg,

      long[] long_long_arg,
      // BigInteger[] unsigned_long_long_arg,

      float[] float_arg,
      double[] double_arg)
  {
    if (testing_nulls) {
      if (bool_arg != null) throw new RuntimeException("not null bool_arg");
      if (signed_char_arg != null)  throw new RuntimeException("not null signed_char_arg");
      if (unsigned_char_arg != null)  throw new RuntimeException("not null unsigned_char_arg");
      if (short_arg != null)  throw new RuntimeException("not null short_arg");
      if (unsigned_short_arg != null)  throw new RuntimeException("not null unsigned_short_arg");
      if (int_arg != null)  throw new RuntimeException("not null int_arg");
      if (unsigned_int_arg != null)  throw new RuntimeException("not null unsigned_int_arg");
      if (long_arg != null)  throw new RuntimeException("not null long_arg");
      if (unsigned_long_arg != null)  throw new RuntimeException("not null unsigned_long_arg");
      if (long_long_arg != null)  throw new RuntimeException("not null long_long_arg");
      // if (unsigned_long_long_arg != null)  throw new RuntimeException("not null unsigned_long_long_arg");
      if (float_arg != null)  throw new RuntimeException("not null float_arg");
      if (double_arg != null)  throw new RuntimeException("not null double_arg");
    }
    if (bool_arg != null) bool_arg[0] = true;
    if (signed_char_arg != null) signed_char_arg[0] = 1;
    if (unsigned_char_arg != null) unsigned_char_arg[0] = 2;
    if (short_arg != null) short_arg[0] = 3;
    if (unsigned_short_arg != null) unsigned_short_arg[0] = 4;
    if (int_arg != null) int_arg[0] = 5;
    if (unsigned_int_arg != null) unsigned_int_arg[0] = 6;
    if (long_arg != null) long_arg[0] = 7;
    if (unsigned_long_arg != null) unsigned_long_arg[0] = 8;
    if (long_long_arg != null) long_long_arg[0] = 9;
    // if (unsigned_long_long_arg != null) unsigned_long_long_arg[0] = 10;
    if (float_arg != null) float_arg[0] = 11;
    if (double_arg != null) double_arg[0] = 12;
  }

  public void director_method_inout(
      boolean[] bool_arg,

      byte[] signed_char_arg,
      short[] unsigned_char_arg,

      short[] short_arg,
      int[] unsigned_short_arg,

      int[] int_arg,
      long[] unsigned_int_arg,

      int[] long_arg,
      long[] unsigned_long_arg,

      long[] long_long_arg,
      // BigInteger[] unsigned_long_long_arg,

      float[] float_arg,
      double[] double_arg)
  {
    if (testing_nulls) {
      if (bool_arg != null) throw new RuntimeException("not null bool_arg");
      if (signed_char_arg != null)  throw new RuntimeException("not null signed_char_arg");
      if (unsigned_char_arg != null)  throw new RuntimeException("not null unsigned_char_arg");
      if (short_arg != null)  throw new RuntimeException("not null short_arg");
      if (unsigned_short_arg != null)  throw new RuntimeException("not null unsigned_short_arg");
      if (int_arg != null)  throw new RuntimeException("not null int_arg");
      if (unsigned_int_arg != null)  throw new RuntimeException("not null unsigned_int_arg");
      if (long_arg != null)  throw new RuntimeException("not null long_arg");
      if (unsigned_long_arg != null)  throw new RuntimeException("not null unsigned_long_arg");
      if (long_long_arg != null)  throw new RuntimeException("not null long_long_arg");
      // if (unsigned_long_long_arg != null)  throw new RuntimeException("not null unsigned_long_long_arg");
      if (float_arg != null)  throw new RuntimeException("not null float_arg");
      if (double_arg != null)  throw new RuntimeException("not null double_arg");
    } else {
      if (bool_arg[0]) throw new RuntimeException("unexpected value for bool_arg");
      if (signed_char_arg[0] != 101)  throw new RuntimeException("unexpected value for signed_char_arg");
      if (unsigned_char_arg[0] != 101)  throw new RuntimeException("unexpected value for unsigned_char_arg");
      if (short_arg[0] != 101)  throw new RuntimeException("unexpected value for short_arg");
      if (unsigned_short_arg[0] != 101)  throw new RuntimeException("unexpected value for unsigned_short_arg");
      if (int_arg[0] != 101)  throw new RuntimeException("unexpected value for int_arg");
      if (unsigned_int_arg[0] != 101)  throw new RuntimeException("unexpected value for unsigned_int_arg");
      if (long_arg[0] != 101)  throw new RuntimeException("unexpected value for long_arg");
      if (unsigned_long_arg[0] != 101)  throw new RuntimeException("unexpected value for unsigned_long_arg");
      if (long_long_arg[0] != 101)  throw new RuntimeException("unexpected value for long_long_arg");
      // if (unsigned_long_long_arg[0] != 101)  throw new RuntimeException("unexpected value for unsigned_long_long_arg");
      if (float_arg[0] != 101)  throw new RuntimeException("unexpected value for float_arg");
      if (double_arg[0] != 101)  throw new RuntimeException("unexpected value for double_arg");
    }

    if (bool_arg != null) bool_arg[0] = false;
    if (signed_char_arg != null) signed_char_arg[0] = 11;
    if (unsigned_char_arg != null) unsigned_char_arg[0] = 12;
    if (short_arg != null) short_arg[0] = 13;
    if (unsigned_short_arg != null) unsigned_short_arg[0] = 14;
    if (int_arg != null) int_arg[0] = 15;
    if (unsigned_int_arg != null) unsigned_int_arg[0] = 16;
    if (long_arg != null) long_arg[0] = 17;
    if (unsigned_long_arg != null) unsigned_long_arg[0] = 18;
    if (long_long_arg != null) long_long_arg[0] = 19;
    // if (unsigned_long_long_arg != null) unsigned_long_long_arg[0] = 110;
    if (float_arg != null) float_arg[0] = 111;
    if (double_arg != null) double_arg[0] = 112;
  }

  public void director_method_nameless_args(
      boolean[] bool_arg,

      byte[] signed_char_arg,
      short[] unsigned_char_arg,

      short[] short_arg,
      int[] unsigned_short_arg,

      int[] int_arg,
      long[] unsigned_int_arg,

      int[] long_arg,
      long[] unsigned_long_arg,

      long[] long_long_arg,
      // BigInteger[] unsigned_long_long_arg,

      float[] float_arg,
      double[] double_arg)
  {
    if (testing_nulls) {
      if (bool_arg != null) throw new RuntimeException("not null bool_arg");
      if (signed_char_arg != null)  throw new RuntimeException("not null signed_char_arg");
      if (unsigned_char_arg != null)  throw new RuntimeException("not null unsigned_char_arg");
      if (short_arg != null)  throw new RuntimeException("not null short_arg");
      if (unsigned_short_arg != null)  throw new RuntimeException("not null unsigned_short_arg");
      if (int_arg != null)  throw new RuntimeException("not null int_arg");
      if (unsigned_int_arg != null)  throw new RuntimeException("not null unsigned_int_arg");
      if (long_arg != null)  throw new RuntimeException("not null long_arg");
      if (unsigned_long_arg != null)  throw new RuntimeException("not null unsigned_long_arg");
      if (long_long_arg != null)  throw new RuntimeException("not null long_long_arg");
      // if (unsigned_long_long_arg != null)  throw new RuntimeException("not null unsigned_long_long_arg");
      if (float_arg != null)  throw new RuntimeException("not null float_arg");
      if (double_arg != null)  throw new RuntimeException("not null double_arg");
    }
    if (bool_arg != null) bool_arg[0] = true;
    if (signed_char_arg != null) signed_char_arg[0] = 12;
    if (unsigned_char_arg != null) unsigned_char_arg[0] = 13;
    if (short_arg != null) short_arg[0] = 14;
    if (unsigned_short_arg != null) unsigned_short_arg[0] = 15;
    if (int_arg != null) int_arg[0] = 16;
    if (unsigned_int_arg != null) unsigned_int_arg[0] = 17;
    if (long_arg != null) long_arg[0] = 18;
    if (unsigned_long_arg != null) unsigned_long_arg[0] = 19;
    if (long_long_arg != null) long_long_arg[0] = 20;
    // if (unsigned_long_long_arg != null) unsigned_long_long_arg[0] = 111;
    if (float_arg != null) float_arg[0] = 112;
    if (double_arg != null) double_arg[0] = 113;
  }
}
