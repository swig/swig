import example;

public class main {

  static {
    try {
	System.loadLibrary("example");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Cannot load the example native code.\nMake sure your LD_LIBRARY_PATH contains \'.\'\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    String s = "brave new world";
    example.f1(s);
    System.out.println("f1(String): " + s);

    byte b[] = new byte[25];
    example.f2(b);
    System.out.println("f2(byte[]): " + new String(b));

    StringBuffer sb = new StringBuffer(20);
    example.f3(sb);
    System.out.println("f3(StringBuffer): " + sb);
  }
}
