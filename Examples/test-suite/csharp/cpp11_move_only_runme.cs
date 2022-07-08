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
    using (MovableCopyable mo = MovableCopyable.create()) {
    }
    Counter.check_counts(2, 1, 0, 0, 1, 3);

    // Move semantics not used
    Counter.reset_counts();
    using (MovableCopyable mo = MovableCopyable.createConst()) {
    }
    Counter.check_counts(2, 1, 1, 0, 0, 3);

    // Input
    Counter.reset_counts();
    using (MovableCopyable mo = new MovableCopyable(222)) {
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable.take(mo);
      Counter.check_counts(2, 0, 1, 1, 0, 2);
    }
    Counter.check_counts(2, 0, 1, 1, 0, 3);
  }
}
