from cpp11_move_only import *

# Output
Counter.reset_counts()
mo = MoveOnly.create()
del mo
Counter.check_counts(1, 0, 0, 2, 0, 3)

Counter.reset_counts()
mo = MovableCopyable.create()
del mo
Counter.check_counts(2, 1, 0, 0, 1, 3)

# Move semantics not used
Counter.reset_counts()
mo = MovableCopyable.createConst()
del mo
Counter.check_counts(2, 1, 1, 0, 0, 3)

# Input
Counter.reset_counts()
mo = MovableCopyable(222)
Counter.check_counts(1, 0, 0, 0, 0, 0)
MovableCopyable.take(mo)
Counter.check_counts(2, 0, 1, 1, 0, 2)
del mo
Counter.check_counts(2, 0, 1, 1, 0, 3)
