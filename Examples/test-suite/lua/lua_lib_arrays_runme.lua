lla=require("lua_lib_arrays")
catch_undef_globs() -- catch "undefined" global variables

-- A table is copied into the array, and back out again for an INOUT array
assert(lla.sum_fixed({1, 2, 3}) == 6)
local t = lla.double_fixed({1, 2, 3})
assert(#t == 3 and t[1] == 2 and t[2] == 4 and t[3] == 6)
assert(lla.sum_var({1, 2, 3, 4}) == 10)
t = lla.double_var({1, 2})
assert(#t == 2 and t[1] == 2 and t[2] == 4)
assert(lla.first_colour({lla.Blue, lla.Red}) == lla.Blue)
local item1 = lla.LuaArrayItem()
item1.value = 1
local item2 = lla.LuaArrayItem()
item2.value = 2
assert(lla.items_sum({item1, item2}) == 3)

-- nil is passed on as a NULL array, with a length of 0 for a variable size array, and an INOUT array gives back nil
assert(lla.sum_fixed(nil) == -1)
assert(lla.double_fixed(nil) == nil)
assert(lla.sum_var(nil) == -1)
assert(lla.double_var(nil) == nil)
assert(lla.first_colour(nil) == -1)
assert(lla.items_sum(nil) == -1)

-- Anything else that is not a table of the right size is still an error
assert(not pcall(lla.sum_fixed, {1, 2}))
assert(not pcall(lla.sum_fixed, 1))
assert(not pcall(lla.sum_var, 1))
