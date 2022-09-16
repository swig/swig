module cpp11_move_typemaps_runme;

import cpp11_move_typemaps.Counter;
import cpp11_move_typemaps.MoveOnly;
import cpp11_move_typemaps.MovableCopyable;
import std.conv;
import std.algorithm;

void main() {
  {
    Counter.reset_counts();
    scope MoveOnly mo = new MoveOnly(111);
    Counter.check_counts(1, 0, 0, 0, 0, 0);
    MoveOnly.take(mo);
    Counter.check_counts(1, 0, 0, 1, 0, 2);
  }
  Counter.check_counts(1, 0, 0, 1, 0, 2);

  {
    Counter.reset_counts();
    scope MovableCopyable mo = new MovableCopyable(111);
    Counter.check_counts(1, 0, 0, 0, 0, 0);
    MovableCopyable.take(mo);
    Counter.check_counts(1, 0, 0, 1, 0, 2);
  }
  Counter.check_counts(1, 0, 0, 1, 0, 2);

  {
    scope MoveOnly mo = new MoveOnly(222);
    MoveOnly.take(mo);
    bool exception_thrown = false;
    try {
      MoveOnly.take(mo);
    } catch (Exception e) {
      if (!canFind(e.msg, "Cannot release ownership as memory is not owned"))
        throw new Exception("incorrect exception message: " ~ e.msg);
      exception_thrown = true;
    }
    if (!exception_thrown)
      throw new Exception("double usage of take should have been an error");
  }
}
