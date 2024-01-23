
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
      MovableCopyable mc = MovableCopyable.create();
      mc.delete();
      Counter.check_counts(2, 1, 0, 0, 1, 3);
    }

    // Move semantics not used
    {
      Counter.reset_counts();
      MovableCopyable mc = MovableCopyable.createConst();
      mc.delete();
      Counter.check_counts(2, 1, 1, 0, 0, 3);
    }

    // Input static method
    {
      Counter.reset_counts();
      MovableCopyable mc = new MovableCopyable(222);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable.take(mc);
      Counter.check_counts(2, 0, 1, 1, 0, 2);
      mc.delete();
      Counter.check_counts(2, 0, 1, 1, 0, 3);
    }

    // Input global function
    {
      Counter.reset_counts();
      MovableCopyable mc = new MovableCopyable(333);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      cpp11_move_only.global_take_movable_copyable(mc);
      Counter.check_counts(2, 0, 1, 1, 0, 2);
      mc.delete();
      Counter.check_counts(2, 0, 1, 1, 0, 3);
    }

    // Input instance method
    {
      Counter.reset_counts();
      InstanceMethodsTester imt = new InstanceMethodsTester();
      MovableCopyable mc = new MovableCopyable(444);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      imt.instance_take_movable_copyable(mc);
      Counter.check_counts(2, 0, 1, 1, 0, 2);
      mc.delete();
      Counter.check_counts(2, 0, 1, 1, 0, 3);
    }

    // Input constructor
    {
      Counter.reset_counts();
      MovableCopyable mc = new MovableCopyable(555);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      ConstructorTester ct = new ConstructorTester(mc);
      Counter.check_counts(2, 0, 1, 1, 0, 2);
      mc.delete();
      Counter.check_counts(2, 0, 1, 1, 0, 3);
    }
  }
}
