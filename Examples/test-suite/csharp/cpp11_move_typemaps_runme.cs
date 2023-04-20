using System;
using cpp11_move_typemapsNamespace;

public class cpp11_move_typemaps_runme {

  public static void Main() {
    Counter.reset_counts();
    using (MoveOnly mo = new MoveOnly(111)) {
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MoveOnly.take(mo);
      Counter.check_counts(1, 0, 0, 1, 0, 2);
    }
    Counter.check_counts(1, 0, 0, 1, 0, 2);

    Counter.reset_counts();
    using (MovableCopyable mo = new MovableCopyable(111)) {
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable.take(mo);
      Counter.check_counts(1, 0, 0, 1, 0, 2);
    }
    Counter.check_counts(1, 0, 0, 1, 0, 2);

    using (MoveOnly mo = new MoveOnly(222)) {
      MoveOnly.take(mo);
      bool exception_thrown = false;
      try {
        MoveOnly.take(mo);
      } catch (ApplicationException e) {
        if (!e.Message.Contains("Cannot release ownership as memory is not owned"))
          throw new ApplicationException("incorrect exception message");
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new ApplicationException("double usage of take should have been an error");
    }
  }
}
