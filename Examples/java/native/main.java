import example;

public class main {

  static {
    try {
	System.loadLibrary("example");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Cannot load the native code.\nMake sure your LD_LIBRARY_PATH contains \'.\'\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    long p = example.point_create(1, 2);
    System.out.println("auto wrapped  : " + example.point_toString1(p));
    System.out.println("manual wrapped: " + example.point_toString2(p));
  }
}
