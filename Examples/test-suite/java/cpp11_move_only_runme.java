
import cpp11_move_only.*;

public class cpp11_move_only_runme {

  static {
    try {
	System.loadLibrary("cpp11_move_only");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    // Output
    {
      Counter.reset_counts();
      MoveOnly mo = MoveOnly.create();
      mo.delete();
      Counter.check_counts(1, 0, 0, 2, 0, 3);
    }

    {
      Counter.reset_counts();
      MovableCopyable mo = MovableCopyable.create();
      mo.delete();
      Counter.check_counts(2, 1, 0, 0, 1, 3);
    }

    // Move semantics not used
    {
      Counter.reset_counts();
      MovableCopyable mo = MovableCopyable.createConst();
      mo.delete();
      Counter.check_counts(2, 1, 1, 0, 0, 3);
    }

    // Input
    {
      Counter.reset_counts();
      MovableCopyable mo = new MovableCopyable(222);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable.take(mo);
      Counter.check_counts(2, 0, 1, 1, 0, 2);
      mo.delete();
      Counter.check_counts(2, 0, 1, 1, 0, 3);
    }
  }
}
