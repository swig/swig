from cpp11_move_only import *

# Output
Counter.reset_counts()
mo = MoveOnly.create()
del mo
Counter.check_counts(1, 0, 0, 2, 0, 3)

Counter.reset_counts()
mc = MovableCopyable.create()
del mc
Counter.check_counts(2, 1, 0, 0, 1, 3)

# Move semantics not used
Counter.reset_counts()
mc = MovableCopyable.createConst()
del mc
Counter.check_counts(2, 1, 1, 0, 0, 3)

# Input static method
Counter.reset_counts()
mc = MovableCopyable(222)
Counter.check_counts(1, 0, 0, 0, 0, 0)
MovableCopyable.take(mc)
Counter.check_counts(2, 0, 1, 1, 0, 2)
del mc
Counter.check_counts(2, 0, 1, 1, 0, 3)

# Input global function
Counter.reset_counts()
mc = MovableCopyable(333)
Counter.check_counts(1, 0, 0, 0, 0, 0)
global_take_movable_copyable(mc)
Counter.check_counts(2, 0, 1, 1, 0, 2)
del mc
Counter.check_counts(2, 0, 1, 1, 0, 3)

# Input instance method
Counter.reset_counts()
imt = InstanceMethodsTester()
mc = MovableCopyable(444)
Counter.check_counts(1, 0, 0, 0, 0, 0)
imt.instance_take_movable_copyable(mc)
Counter.check_counts(2, 0, 1, 1, 0, 2)
del mc
Counter.check_counts(2, 0, 1, 1, 0, 3)

# Input constructor
Counter.reset_counts()
mc = MovableCopyable(555)
Counter.check_counts(1, 0, 0, 0, 0, 0)
ct = ConstructorTester(mc)
Counter.check_counts(2, 0, 1, 1, 0, 2)
del mc
Counter.check_counts(2, 0, 1, 1, 0, 3)
