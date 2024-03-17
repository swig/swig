import template_function_parm.*;

public class template_function_parm_runme {

  static {
    try {
      System.loadLibrary("template_function_parm");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    VectorInt vi = new VectorInt();
    vi.add(10);
    vi.add(20);
    vi.add(30);

    MyC myc = new MyC();
    int sum = myc.take_function(template_function_parmConstants.accumulate_integers, vi);
    if (sum != 60)
      throw new RuntimeException("Expected sum of 60, got " + sum);
  }
}
