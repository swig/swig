var cpp11_move_typemaps = require("cpp11_move_typemaps");

/* await */(cpp11_move_typemaps.Counter.reset_counts());
var mo = new cpp11_move_typemaps.MoveOnly(111);
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 0, 0, 0));
/* await */(cpp11_move_typemaps.MoveOnly.take(mo));
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2));
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2));

/* await */(cpp11_move_typemaps.Counter.reset_counts());
mo = new cpp11_move_typemaps.MovableCopyable(111);
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 0, 0, 0));
/* await */(cpp11_move_typemaps.MovableCopyable.take(mo));
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2));
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2));

mo = new cpp11_move_typemaps.MoveOnly(222);
/* await */(cpp11_move_typemaps.MoveOnly.take(mo));
var exception_thrown = false;
try {
  /* await */(cpp11_move_typemaps.MoveOnly.take(mo));
} catch (e) {
  if (!e.message.includes("cannot release ownership as memory is not owned"))
    throw new Error("incorrect exception message:" + e.message);
  exception_thrown = true;
}
if (!exception_thrown)
  throw new Error("double usage of take should have been an error");


/* await */(cpp11_move_typemaps.Counter.reset_counts());
var imt = new cpp11_move_typemaps.InstanceMethodsTester();

mo = new cpp11_move_typemaps.MoveOnly(333);
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 0, 0, 0));
/* await */(imt.instance_take_move_only(mo));
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2));
//delete mo;

/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2));
/* await */(cpp11_move_typemaps.Counter.reset_counts());

var mc = new cpp11_move_typemaps.MovableCopyable(444);
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 0, 0, 0));
/* await */(imt.instance_take_movable_copyable(mc));
/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2));
//delete mc;

/* await */(cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2));
