using System;
using cpp11_rvalue_reference_move_inputNamespace;

public class cpp11_rvalue_reference_move_input_runme {
  public static void Main() {
    {
      // Function containing rvalue reference parameter
      Counter.reset_counts();
      MovableCopyable mo = new MovableCopyable(222);
      Counter.check_counts(1, 0, 0, 0, 0, 0);
      MovableCopyable.movein(mo);
      Counter.check_counts(1, 0, 0, 1, 0, 2);
      if (!MovableCopyable.is_nullptr(mo))
        throw new ApplicationException("is_nullptr failed");
      mo.Dispose();
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
        throw new ApplicationException("is_nullptr failed");
      mo.Dispose();
      Counter.check_counts(1, 0, 0, 1, 0, 1);
      mo_moved.Dispose();
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
        throw new ApplicationException("is_nullptr failed");
      mo222.Dispose();
      Counter.check_counts(2, 0, 0, 0, 1, 1);
      mo111.Dispose();
      Counter.check_counts(2, 0, 0, 0, 1, 2);
    }

    {
      // null check
      Counter.reset_counts();
      bool exception_thrown = false;
      try {
        MovableCopyable.movein(null);
      } catch (ArgumentNullException e) {
        if (!e.Message.Contains("MovableCopyable && is null"))
          throw new ApplicationException("incorrect exception message:" + e);
        exception_thrown = true;
      }
      if (!exception_thrown)
        throw new ApplicationException("Should have thrown null error");
      Counter.check_counts(0, 0, 0, 0, 0, 0);
    }
  }
}
