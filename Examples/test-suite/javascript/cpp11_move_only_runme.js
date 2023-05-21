var cpp11_move_only = require("cpp11_move_only");

// Output
cpp11_move_only.Counter.reset_counts();
var mo = cpp11_move_only.MoveOnly.create();
cpp11_move_only.Counter.check_counts(1, 0, 0, 2, 0, 2);

cpp11_move_only.Counter.reset_counts();
var mo = cpp11_move_only.MovableCopyable.create();
cpp11_move_only.Counter.check_counts(2, 1, 0, 0, 1, 2);

// Move semantics not used
cpp11_move_only.Counter.reset_counts();
var mo = cpp11_move_only.MovableCopyable.createConst();
cpp11_move_only.Counter.check_counts(2, 1, 1, 0, 0, 2);

// Input
cpp11_move_only.Counter.reset_counts();
var mo = new cpp11_move_only.MovableCopyable(222);
cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0);
cpp11_move_only.MovableCopyable.take(mo);
cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2);
