local v=require("cpp11_move_only")

-- Output
v.Counter.reset_counts()
local mo = v.MoveOnly.create()
mo = nil
collectgarbage() -- Ensure 'mo' is deleted
v.Counter.check_counts(1, 0, 0, 2, 0, 3)

v.Counter.reset_counts()
local mc = v.MovableCopyable.create()
mc = nil
collectgarbage() -- Ensure 'mc' is deleted
v.Counter.check_counts(2, 1, 0, 0, 1, 3)

-- Move semantics not used
v.Counter.reset_counts()
mc = v.MovableCopyable.createConst()
mc = nil
collectgarbage() -- Ensure 'mc' is deleted
v.Counter.check_counts(2, 1, 1, 0, 0, 3)

-- Input static method
v.Counter.reset_counts()
mc = v.MovableCopyable(222)
v.Counter.check_counts(1, 0, 0, 0, 0, 0)
v.MovableCopyable.take(mc)
v.Counter.check_counts(2, 0, 1, 1, 0, 2)
mc = nil
collectgarbage() -- Ensure 'mc' is deleted
v.Counter.check_counts(2, 0, 1, 1, 0, 3)

-- Input global function
v.Counter.reset_counts()
mc = v.MovableCopyable(333)
v.Counter.check_counts(1, 0, 0, 0, 0, 0)
v.global_take_movable_copyable(mc)
v.Counter.check_counts(2, 0, 1, 1, 0, 2)
mc = nil
collectgarbage() -- Ensure 'mc' is deleted
v.Counter.check_counts(2, 0, 1, 1, 0, 3)

-- Input instance method
v.Counter.reset_counts()
local imt = v.InstanceMethodsTester()
mc = v.MovableCopyable(444)
v.Counter.check_counts(1, 0, 0, 0, 0, 0)
imt:instance_take_movable_copyable(mc)
v.Counter.check_counts(2, 0, 1, 1, 0, 2)
mc = nil
collectgarbage() -- Ensure 'mc' is deleted
v.Counter.check_counts(2, 0, 1, 1, 0, 3)

-- Input constructor
v.Counter.reset_counts()
mc = v.MovableCopyable(555)
v.Counter.check_counts(1, 0, 0, 0, 0, 0)
local ct = v.ConstructorTester(mc)
v.Counter.check_counts(2, 0, 1, 1, 0, 2)
mc = nil
collectgarbage() -- Ensure 'mc' is deleted
v.Counter.check_counts(2, 0, 1, 1, 0, 3)
