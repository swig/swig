var cpp11_move_only = require("cpp11_move_only");

// Output
/* await */(cpp11_move_only.Counter.reset_counts());
var mo = /* await */(cpp11_move_only.MoveOnly.create());
/* await */(cpp11_move_only.Counter.check_counts(1, 0, 0, 2, 0, 2));

/* await */((cpp11_move_only.Counter.reset_counts()));
var mo = /* await */(cpp11_move_only.MovableCopyable.create());
/* await */((cpp11_move_only.Counter.check_counts(2, 1, 0, 0, 1, 2)));

// Move semantics not used
/* await */(cpp11_move_only.Counter.reset_counts());
var mo = /* await */(cpp11_move_only.MovableCopyable.createConst());
/* await */(cpp11_move_only.Counter.check_counts(2, 1, 1, 0, 0, 2));

// Input static method
/* await */(cpp11_move_only.Counter.reset_counts());
var mc = new cpp11_move_only.MovableCopyable(222);
/* await */(cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0));
/* await */(cpp11_move_only.MovableCopyable.take(mc));
/* await */(cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2));

// Input global function
/* await */(cpp11_move_only.Counter.reset_counts());
var mc = new cpp11_move_only.MovableCopyable(333);
/* await */(cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0));
/* await */(cpp11_move_only.global_take_movable_copyable(mc));
/* await */(cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2));

// Input instance method
/* await */(cpp11_move_only.Counter.reset_counts());
var imt = new cpp11_move_only.InstanceMethodsTester();
var mc = new cpp11_move_only.MovableCopyable(444);
/* await */(cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0));
/* await */(imt.instance_take_movable_copyable(mc));
/* await */(cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2));

// Input constructor
/* await */(cpp11_move_only.Counter.reset_counts());
var mc = new cpp11_move_only.MovableCopyable(555);
/* await */(cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0));
var ct = new cpp11_move_only.ConstructorTester(mc);
/* await */(cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2));
