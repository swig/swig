var cpp11_move_only = require("cpp11_move_only");

// Output
cpp11_move_only.Counter.reset_counts();
var mo = cpp11_move_only.MoveOnly.create();
cpp11_move_only.Counter.check_counts(1, 0, 0, 2, 0, 2);

cpp11_move_only.Counter.reset_counts();
var mc = cpp11_move_only.MovableCopyable.create();
cpp11_move_only.Counter.check_counts(2, 1, 0, 0, 1, 2);

// Move semantics not used
cpp11_move_only.Counter.reset_counts();
var mc = cpp11_move_only.MovableCopyable.createConst();
cpp11_move_only.Counter.check_counts(2, 1, 1, 0, 0, 2);

// Input static method
cpp11_move_only.Counter.reset_counts();
var mc = new cpp11_move_only.MovableCopyable(222);
cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0);
cpp11_move_only.MovableCopyable.take(mc);
cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2);

// Input global function
cpp11_move_only.Counter.reset_counts();
var mc = new cpp11_move_only.MovableCopyable(333);
cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0);
cpp11_move_only.global_take_movable_copyable(mc);
cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2);

// Input instance method
cpp11_move_only.Counter.reset_counts();
var imt = new cpp11_move_only.InstanceMethodsTester();
var mc = new cpp11_move_only.MovableCopyable(444);
cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0);
imt.instance_take_movable_copyable(mc);
cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2);

// Input constructor
cpp11_move_only.Counter.reset_counts();
var mc = new cpp11_move_only.MovableCopyable(555);
cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0);
var ct = new cpp11_move_only.ConstructorTester(mc);
cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2);
