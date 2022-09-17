
import cpp11_rvalue_reference_move.*;

public class cpp11_rvalue_reference_move_runme {

  static {
    try {
	System.loadLibrary("cpp11_rvalue_reference_move");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    {
      // Function containing rvalue reference parameter
      Counter.reset_counts();
      MovableCopyable mo = new MovableCopyable(222);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable.movein(mo);
      Counter.check_counts(1, 0, 0, 1, 0, 2);
      if (!MovableCopyable.is_nullptr(mo))
        throw new RuntimeException("is_nullptr failed");
      mo.delete();
      Counter.check_counts(1, 0, 0, 1, 0, 2);
    }

    {
      // Move constructor test
      Counter.reset_counts();
      MovableCopyable mo = new MovableCopyable(222);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable mo_moved = new MovableCopyable(mo);
      Counter.check_counts(1, 0, 0, 1, 0, 1);
      if (!MovableCopyable.is_nullptr(mo))
        throw new RuntimeException("is_nullptr failed");
      mo.delete();
      Counter.check_counts(1, 0, 0, 1, 0, 1);
      mo_moved.delete();
      Counter.check_counts(1, 0, 0, 1, 0, 2);
    }

    {
      // Move assignment operator test
      Counter.reset_counts();
      MovableCopyable mo111 = new MovableCopyable(111);
      MovableCopyable mo222 = new MovableCopyable(222);
      Counter.check_counts(2, 0, 0, 0, 0, 0);
      mo111.MoveAssign(mo222);
      Counter.check_counts(2, 0, 0, 0, 1, 1);
      if (!MovableCopyable.is_nullptr(mo222))
        throw new RuntimeException("is_nullptr failed");
      mo222.delete();
      Counter.check_counts(2, 0, 0, 0, 1, 1);
      mo111.delete();
      Counter.check_counts(2, 0, 0, 0, 1, 2);
    }

    {
      // null check
      Counter.reset_counts();
      boolean exception_thrown = false;
      try {
        MovableCopyable.movein(null);
      } catch (NullPointerException e) {
        if (!e.getMessage().contains("MovableCopyable && is null"))
          throw new RuntimeException("incorrect exception message");
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new RuntimeException("Should have thrown null error");
      Counter.check_counts(0, 0, 0, 0, 0, 0);
    }

    {
      // output
      Counter.reset_counts();
      MovableCopyable mc = MovableCopyable.moveout(1234);
      Counter.check_counts(2, 0, 0, 0, 1, 1);
      MovableCopyable.check_numbers_match(mc, 1234);

      boolean exception_thrown = false;
      try {
        MovableCopyable.movein(mc);
      } catch (RuntimeException e) {
        if (!e.getMessage().contains("Cannot release ownership as memory is not owned"))
          throw new RuntimeException("incorrect exception message");
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new RuntimeException("Should have thrown 'Cannot release ownership as memory is not owned' error");
      Counter.check_counts(2, 0, 0, 0, 1, 1);
    }
  }
}
