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
    System.out.println(example.get_time());

    System.out.println("My Variable = " + example.get_My_variable());

    for(int i=0; i<14; i++) {
      System.out.println("" + i + " factorial is " + example.fact(i));
    }

    for(int i=1; i<100; i++) {
      for(int j=1; j<100; j++) {
        int n = example.mod(i, j);
        example.set_My_variable(example.get_My_variable() + n);
      }
    }

    System.out.println("My_variable = " + example.get_My_variable());
  }
}
