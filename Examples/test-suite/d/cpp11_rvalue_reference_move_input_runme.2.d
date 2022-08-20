module cpp11_rvalue_reference_move_input_runme;

import cpp11_rvalue_reference_move_input.Counter;
import cpp11_rvalue_reference_move_input.MovableCopyable;
import std.algorithm;

void main() {
  {
    // Function containing rvalue reference parameter
    Counter.reset_counts();
    scope MovableCopyable mo = new MovableCopyable(222);
    Counter.check_counts(1, 0, 0, 0, 0, 0);
    MovableCopyable.movein(mo);
    Counter.check_counts(1, 0, 0, 1, 0, 2);
    if (!MovableCopyable.is_nullptr(mo))
      throw new Exception("is_nullptr failed");
    mo.dispose();
    Counter.check_counts(1, 0, 0, 1, 0, 2);
  }

  {
    // Move constructor test
    Counter.reset_counts();
    scope MovableCopyable mo = new MovableCopyable(222);
    Counter.check_counts(1, 0, 0, 0, 0, 0);
    MovableCopyable mo_moved = new MovableCopyable(mo);
    Counter.check_counts(1, 0, 0, 1, 0, 1);
    if (!MovableCopyable.is_nullptr(mo))
      throw new Exception("is_nullptr failed");
    mo.dispose();
    Counter.check_counts(1, 0, 0, 1, 0, 1);
    mo_moved.dispose();
    Counter.check_counts(1, 0, 0, 1, 0, 2);
  }

  {
    // Move assignment operator test
    Counter.reset_counts();
    scope MovableCopyable mo111 = new MovableCopyable(111);
    scope MovableCopyable mo222 = new MovableCopyable(222);
    Counter.check_counts(2, 0, 0, 0, 0, 0);
    mo111.MoveAssign(mo222);
    Counter.check_counts(2, 0, 0, 0, 1, 1);
    if (!MovableCopyable.is_nullptr(mo222))
      throw new Exception("is_nullptr failed");
    mo222.dispose();
    Counter.check_counts(2, 0, 0, 0, 1, 1);
    mo111.dispose();
    Counter.check_counts(2, 0, 0, 0, 1, 2);
  }

  {
    // null check
    Counter.reset_counts();
    bool exception_thrown = false;
    try {
      MovableCopyable.movein(null);
    } catch (Exception e) {
      if (!canFind(e.msg, "MovableCopyable && is null"))
        throw new Exception("incorrect exception message:" ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("Should have thrown null error");
    Counter.check_counts(0, 0, 0, 0, 0, 0);
  }
}
