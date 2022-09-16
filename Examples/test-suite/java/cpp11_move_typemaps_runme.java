
import cpp11_move_typemaps.*;

public class cpp11_move_typemaps_runme {

  static {
    try {
	System.loadLibrary("cpp11_move_typemaps");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    {
      Counter.reset_counts();
      MoveOnly mo = new MoveOnly(111);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MoveOnly.take(mo);
      Counter.check_counts(1, 0, 0, 1, 0, 2);
      mo.delete();
    }
    Counter.check_counts(1, 0, 0, 1, 0, 2);

    {
      Counter.reset_counts();
      MovableCopyable mo = new MovableCopyable(111);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable.take(mo);
      Counter.check_counts(1, 0, 0, 1, 0, 2);
      mo.delete();
    }
    Counter.check_counts(1, 0, 0, 1, 0, 2);

    {
      MoveOnly mo = new MoveOnly(222);
      MoveOnly.take(mo);
      boolean exception_thrown = false;
      try {
        MoveOnly.take(mo);
      } catch (RuntimeException e) {
        if (!e.getMessage().contains("Cannot release ownership as memory is not owned"))
          throw new RuntimeException("incorrect exception message");
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new RuntimeException("double usage of take should have been an error");
    }
  }
}
