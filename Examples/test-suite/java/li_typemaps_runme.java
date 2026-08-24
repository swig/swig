
// Check a few of the INPUT, OUTPUT and INOUT typemaps.

import li_typemaps.*;
import java.math.*;

public class li_typemaps_runme {

  static {
    try {
	System.loadLibrary("li_typemaps");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    // Check double INPUT typemaps
    if (li_typemaps.in_double(22.22) != 22.22) exit_test("in_double");
    if (li_typemaps.inr_double(22.22) != 22.22) exit_test("inr_double");

    // Check double OUTPUT typemaps
    {
        double[] var = {44.44};
        li_typemaps.out_double(22.22, var);
        if (var[0] != 22.22) exit_test("out_double");
    }
    {
        double[] var = {44.44};
        li_typemaps.outr_double(22.22, var);
        if (var[0] != 22.22) exit_test("outr_double");
    }
    try {
        double[] var = null;
        li_typemaps.out_double(22.22, var);
        exit_test("null out_double");
    } catch (NullPointerException e) {
    }

    // Check double INOUT typemaps
    {
        double[] var = {44.44};
        li_typemaps.inout_double(var);
        if (var[0] != 44.44) exit_test("inout_double");
    }
    {
        double[] var = {44.44};
        li_typemaps.inoutr_double(var);
        if (var[0] != 44.44) exit_test("inoutr_double");
    }
    try {
        double[] var = null;
        li_typemaps.inout_double(var);
        exit_test("null inout_double");
    } catch (NullPointerException e) {
    }

    // Check unsigned long long INPUT typemaps
    BigInteger forty = new BigInteger("40");
    BigInteger twenty = new BigInteger("20");
    if (!li_typemaps.in_ulonglong(twenty).equals(twenty)) exit_test("in_ulonglong");
    if (!li_typemaps.inr_ulonglong(twenty).equals(twenty)) exit_test("inr_ulonglong");

    try {
        li_typemaps.in_ulonglong(null);
        exit_test("null in_ulonglong");
    } catch (NullPointerException e) {
    }

    // Check unsigned long long OUTPUT typemaps
    {
        BigInteger[] var = {new BigInteger("40")};
        li_typemaps.out_ulonglong(twenty, var);
        if (!var[0].equals(twenty)) exit_test("out_ulonglong");
    }
    {
        BigInteger[] var = {new BigInteger("40")};
        li_typemaps.outr_ulonglong(twenty, var);
        if (!var[0].equals(twenty)) exit_test("outr_ulonglong");
    }
    try {
        BigInteger[] var = null;
        li_typemaps.out_ulonglong(twenty, var);
        exit_test("null out_ulonglong");
    } catch (NullPointerException e) {
    }
    {
        BigInteger[] var = { null };
        li_typemaps.out_ulonglong(twenty, var);
        if (!var[0].equals(twenty)) exit_test("null element out_ulonglong");
    }

    // Check unsigned long long INOUT typemaps
    {
        BigInteger[] var = {new BigInteger("40")};
        li_typemaps.inout_ulonglong(var);
        if (!var[0].equals(forty)) exit_test("inout_ulonglong");
    }
    {
        BigInteger[] var = {new BigInteger("40")};
        li_typemaps.inoutr_ulonglong(var);
        if (!var[0].equals(forty)) exit_test("inoutr_ulonglong");
    }

    // Two parameters using the same typemap
    {
      int var1 = 3;
      int var2 = 4;
      if (li_typemaps.in_int_multi(var1, var2) != 7) exit_test("in_int_multi");
    }
    {
      int var1 = 5;
      int var2 = 6;
      int[] var3 = {0};
      int[] var4 = {0};
      li_typemaps.out_int_multi(var1, var2, var3, var4);
      if (var3[0] != 5 || var4[0] != 6) exit_test("out_int_multi");
    }
    {
      int[] var1 = {7};
      int[] var2 = {8};
      li_typemaps.inout_int_multi(var1, var2);
      if (var1[0] != 14 || var2[0] != 24) exit_test("inout_int_multi");
    }

    try {
        BigInteger[] var = null;
        li_typemaps.inout_ulonglong(var);
        exit_test("null inout_ulonglong");
    } catch (NullPointerException e) {
    }
    try {
        BigInteger[] var = { null };
        li_typemaps.inout_ulonglong(var);
        exit_test("null element inout_ulonglong");
    } catch (NullPointerException e) {
    }

  }

  private static void exit_test(String funcName) {
      throw new RuntimeException("Test FAILED in function " + funcName);
  }
}

