local v=require("template_templated_constructors")

local t1 = v.TConstructor1(123)
local t2a = v.TConstructor2()
local t2b = v.TConstructor2(123)
local tc1 = v.TClass1Int(123.4)
local tc2a = v.TClass2Int()
local tc2b = v.TClass2Int(123.4)
local double_pair = v.DoublePair(1.1, 2.2)
local short_pair = v.ShortPair(0, 1)
local string_pair = v.StringPair("10", "11")
--[[ TODO %template(IntPair) Pair<int, int> fail
v.IntPair()
v.IntPair(20, 21)
v.IntPair(ip1)
v.IntPair(short_pair)
]]
-- v.Pair(double_pair) TODO fails
-- v.MakeStringPair(string_pair) TODO %template(MakeStringPair) fails
