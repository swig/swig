
// This is the long_long runtime testcase. It checks that the long long and
// unsigned long long types map correctly to long and BigInteger respectively.

import long_long.*;
import java.math.*;

public class long_long_runme {

  static {
    try {
	System.loadLibrary("long_long");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    check_ll(0L);
    check_ll(0x7FFFFFFFFFFFFFFFL);
    check_ll(-10);

    check_ull(new BigInteger("0"));
    check_ull(new BigInteger("127"));
    check_ull(new BigInteger("128"));
    check_ull(new BigInteger("9223372036854775807")); //0x7FFFFFFFFFFFFFFFL
    check_ull(new BigInteger("18446744073709551615")); //0xFFFFFFFFFFFFFFFFL
  }

  public static void check_ll(long ll) {
    long_long.setLl(ll);
    long ll_check = long_long.getLl();
    if (ll != ll_check) {
      System.err.println("Runtime test using long long failed. ll=" + ll + " ll_check=" + ll_check);
      System.exit(1);
    }
  }

  public static void check_ull(BigInteger ull) {
    long_long.setUll(ull);
    BigInteger ull_check = long_long.getUll();
    if (ull.compareTo(ull_check) != 0) {
      System.err.println("Runtime test using unsigned long long failed. ull=" + ull.toString() + " ull_check=" + ull_check.toString());
      System.exit(1);
    }
  }
}

