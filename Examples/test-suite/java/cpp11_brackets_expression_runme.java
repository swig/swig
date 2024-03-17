import cpp11_brackets_expression.*;

public class cpp11_brackets_expression_runme {

  static {
    try {
	System.loadLibrary("cpp11_brackets_expression");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    long x = Piece.kMaxSize;
    x = Piece.SimpleAsYouExpect123;
    x = Piece.Just123;
    x = cpp11_brackets_expression.getKMaxSizeGlobal();

    x = cpp11_brackets_expression.getKMaxSizeGlobal();
    x = cpp11_brackets_expression.global_as_you_expect(123);
    x = cpp11_brackets_expression.global_one_two_three();
  }
}
