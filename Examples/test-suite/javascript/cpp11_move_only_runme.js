var cpp11_move_only = require("cpp11_move_only");

// Output
/* await */(cpp11_move_only.Counter.reset_counts());
var mo = /* await */(cpp11_move_only.MoveOnly.create());
/* await */(cpp11_move_only.Counter.check_counts(1, 0, 0, 2, 0, 2));

/* await */(cpp11_move_only.Counter.reset_counts());
var mo = /* await */(cpp11_move_only.MovableCopyable.create());
/* await */(cpp11_move_only.Counter.check_counts(2, 1, 0, 0, 1, 2));

// Move semantics not used
/* await */(cpp11_move_only.Counter.reset_counts());
var mo = /* await */(cpp11_move_only.MovableCopyable.createConst());
/* await */(cpp11_move_only.Counter.check_counts(2, 1, 1, 0, 0, 2));

// Input
/* await */(cpp11_move_only.Counter.reset_counts());
var mo = new cpp11_move_only.MovableCopyable(222);
/* await */(cpp11_move_only.Counter.check_counts(1, 0, 0, 0, 0, 0));
/* await */(cpp11_move_only.MovableCopyable.take(mo));
/* await */(cpp11_move_only.Counter.check_counts(2, 0, 1, 1, 0, 2));
