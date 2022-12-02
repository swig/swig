var cpp11_move_typemaps = require("cpp11_move_typemaps");

cpp11_move_typemaps.Counter.reset_counts();
mo = new cpp11_move_typemaps.MoveOnly(111);
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 0, 0, 0);
cpp11_move_typemaps.MoveOnly.take(mo);
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2);
delete mo;
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2);

cpp11_move_typemaps.Counter.reset_counts();
mo = new cpp11_move_typemaps.MovableCopyable(111);
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 0, 0, 0);
cpp11_move_typemaps.MovableCopyable.take(mo);
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2);
delete mo;
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2);

mo = new cpp11_move_typemaps.MoveOnly(222);
cpp11_move_typemaps.MoveOnly.take(mo);
exception_thrown = false;
try {
  cpp11_move_typemaps.MoveOnly.take(mo);
} catch (e) {
  if (!e.message.includes("cannot release ownership as memory is not owned"))
    throw new Error("incorrect exception message:" + e.message);
  exception_thrown = true;
}
if (!exception_thrown)
  throw new Error("double usage of take should have been an error");
