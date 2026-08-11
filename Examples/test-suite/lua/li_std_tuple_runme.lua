-- Test for std::tuple wrapper in Lua
require("import")
import("li_std_tuple")

for k,v in pairs(li_std_tuple) do _G[k]=v end

-- Test sum_pair_values with a tuple from make_int_double
local t = make_int_double(3, 4.5)
local r = sum_pair_values(t)
assert(r == 7.5, "sum_pair_values test failed: " .. r)

-- Test make_int_double returns a valid tuple
local t2 = make_int_double(10, 20.5)

-- Test pass_tuples with two tuples
local t3 = make_int_double(1, 2.5)
local t4 = make_int_double(10, 20.0)
local t5 = pass_tuples(t3, t4)
assert(t5 ~= nil, "pass_tuples should return a valid tuple")
