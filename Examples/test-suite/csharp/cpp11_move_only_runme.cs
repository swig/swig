using System;
using cpp11_move_onlyNamespace;

public class cpp11_move_only_runme {

  public static void Main() {
    // Output
    Counter.reset_counts();
    using (MoveOnly mo = MoveOnly.create()) {
    }
    Counter.check_counts(1, 0, 0, 2, 0, 3);

    Counter.reset_counts();
    using (MovableCopyable mc = MovableCopyable.create()) {
    }
    Counter.check_counts(2, 1, 0, 0, 1, 3);

    // Move semantics not used
    Counter.reset_counts();
    using (MovableCopyable mc = MovableCopyable.createConst()) {
    }
    Counter.check_counts(2, 1, 1, 0, 0, 3);

    // Input static method
    Counter.reset_counts();
    using (MovableCopyable mc = new MovableCopyable(222)) {
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable.take(mc);
      Counter.check_counts(2, 0, 1, 1, 0, 2);
    }
    Counter.check_counts(2, 0, 1, 1, 0, 3);

    // Input global function
    Counter.reset_counts();
    using (MovableCopyable mc = new MovableCopyable(333)) {
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      cpp11_move_only.global_take_movable_copyable(mc);
      Counter.check_counts(2, 0, 1, 1, 0, 2);
    }
    Counter.check_counts(2, 0, 1, 1, 0, 3);

    // Input instance method
    Counter.reset_counts();
    using (InstanceMethodsTester imt = new InstanceMethodsTester()) {
      using (MovableCopyable mc = new MovableCopyable(444)) {
        Counter.check_counts(1, 0, 0, 0, 0, 0);
        imt.instance_take_movable_copyable(mc);
        Counter.check_counts(2, 0, 1, 1, 0, 2);
      }
      Counter.check_counts(2, 0, 1, 1, 0, 3);
    }

    // Input constructor
    Counter.reset_counts();
    using (MovableCopyable mc = new MovableCopyable(555)) {
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      using (ConstructorTester ct = new ConstructorTester(mc)) {
        Counter.check_counts(2, 0, 1, 1, 0, 2);
      }
      Counter.check_counts(2, 0, 1, 1, 0, 2);
    }
    Counter.check_counts(2, 0, 1, 1, 0, 3);
  }
}
