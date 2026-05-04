local v=require("cpp11_move_only_valuewrapper")

v.Counter.reset_counts()
local xxx = v.createXXX()
xxx = nil
collectgarbage() -- Ensure 'xxx' is deleted
if v.has_cplusplus11() then
    v.Counter.check_counts(1, 0, 0, 2, 0, 3)
    v.Counter.reset_counts()
    xxx = v.createXXX2()
    xxx = nil
    collectgarbage() -- Ensure 'xxx' is deleted
    v.Counter.check_counts(1, 0, 0, 2, 0, 3)
end
v.test1()
v.test2()
v.test3()
v.test4()
v.test5()
v.test6()

-- Tests unique_ptr
v.Counter.reset_counts()
local ptr = v.makeUniqueXXX()
v.cleanup(ptr)
v.Counter.check_counts(1, 0, 0, 0, 0, 1)
