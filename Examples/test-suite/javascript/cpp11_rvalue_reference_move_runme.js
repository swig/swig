var cpp11_rvalue_reference_move = require("cpp11_rvalue_reference_move");

{
  // Function containing rvalue reference parameter
  cpp11_rvalue_reference_move.Counter.reset_counts();
  mo = new cpp11_rvalue_reference_move.MovableCopyable(222);
  cpp11_rvalue_reference_move.Counter.check_counts(1, 0, 0, 0, 0, 0);
  cpp11_rvalue_reference_move.MovableCopyable.movein(mo);
  cpp11_rvalue_reference_move.Counter.check_counts(1, 0, 0, 1, 0, 2);
  if (!cpp11_rvalue_reference_move.MovableCopyable.is_nullptr(mo))
    throw new Error("is_nullptr failed");
  delete mo;
  cpp11_rvalue_reference_move.Counter.check_counts(1, 0, 0, 1, 0, 2);
}

{
  // Move constructor test
  cpp11_rvalue_reference_move.Counter.reset_counts();
  mo = new cpp11_rvalue_reference_move.MovableCopyable(222);
  cpp11_rvalue_reference_move.Counter.check_counts(1, 0, 0, 0, 0, 0);
  mo_moved = new cpp11_rvalue_reference_move.MovableCopyable(mo);
  cpp11_rvalue_reference_move.Counter.check_counts(1, 0, 0, 1, 0, 1);
  if (!cpp11_rvalue_reference_move.MovableCopyable.is_nullptr(mo))
    throw new Error("is_nullptr failed");
  delete mo;
  cpp11_rvalue_reference_move.Counter.check_counts(1, 0, 0, 1, 0, 1);
  // delete mo_moved;
  // cpp11_rvalue_reference_move.Counter.check_counts(1, 0, 0, 1, 0, 2);
  // Above not deleting the C++ object(node v12) - can't reliably control GC - use the movein function instead to delete
  cpp11_rvalue_reference_move.MovableCopyable.movein(mo_moved);
  cpp11_rvalue_reference_move.Counter.check_counts(1, 0, 0, 2, 0, 3);
}

{
  // Move assignment operator test
  cpp11_rvalue_reference_move.Counter.reset_counts();
  mo111 = new cpp11_rvalue_reference_move.MovableCopyable(111);
  mo222 = new cpp11_rvalue_reference_move.MovableCopyable(222);
  cpp11_rvalue_reference_move.Counter.check_counts(2, 0, 0, 0, 0, 0);
  mo111.MoveAssign(mo222);
  cpp11_rvalue_reference_move.Counter.check_counts(2, 0, 0, 0, 1, 1);
  if (!cpp11_rvalue_reference_move.MovableCopyable.is_nullptr(mo222))
    throw new Error("is_nullptr failed");
  delete mo222;
  cpp11_rvalue_reference_move.Counter.check_counts(2, 0, 0, 0, 1, 1);
  // delete mo111;
  // cpp11_rvalue_reference_move.Counter.check_counts(2, 0, 0, 0, 1, 2);
  // Above not deleting the C++ object(node v12) - can't reliably control GC - use the movein function instead to delete
  cpp11_rvalue_reference_move.MovableCopyable.movein(mo111);
  cpp11_rvalue_reference_move.Counter.check_counts(2, 0, 0, 1, 1, 3);
}

{
  // null check
  cpp11_rvalue_reference_move.Counter.reset_counts();
  exception_thrown = false;
  try {
    cpp11_rvalue_reference_move.MovableCopyable.movein(null);
  } catch (e) {
    if (!e.message.includes("invalid null reference"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
    throw new Error("Should have thrown null error");
  cpp11_rvalue_reference_move.Counter.check_counts(0, 0, 0, 0, 0, 0);
}

{
  // output
  cpp11_rvalue_reference_move.Counter.reset_counts();
  var mc = cpp11_rvalue_reference_move.MovableCopyable.moveout(1234);
  cpp11_rvalue_reference_move.Counter.check_counts(2, 0, 0, 0, 1, 1);
  cpp11_rvalue_reference_move.MovableCopyable.check_numbers_match(mc, 1234);

  exception_thrown = false;
  try {
    cpp11_rvalue_reference_move.MovableCopyable.movein(mc);
  } catch (e) {
    if (!e.message.includes("cannot release ownership as memory is not owned"))
      throw new Error("incorrect exception message " + e.message);
    exception_thrown = true;
  }
  if (!exception_thrown)
    throw new Error("Should have thrown 'Cannot release ownership as memory is not owned' error");
  cpp11_rvalue_reference_move.Counter.check_counts(2, 0, 0, 0, 1, 1);
}
