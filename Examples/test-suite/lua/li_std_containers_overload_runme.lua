local v=require("li_std_containers_overload")

function check(got, expected)
  assert(got == expected, "Failed check. " .. got .. " != " .. expected)
end

local vec = v.VectorX()
check(v.VectorOverload(vec), "vector<X>")

vec = v.VectorY()
check(v.VectorOverload(vec), "vector<Y>")

vec = v.VectorInt()
check(v.VectorOverload(vec), "vector<int>")

vec = v.VectorString()
check(v.VectorOverload(vec), "vector<string>")

--[[ TODO Lua do not translate Lua table to vector<>
vec = { v.X() }
check(v.VectorOverload(vec), "vector<X>")
vec = { Y() }
check(v.VectorOverload(vec), "vector<Y>")
vec = { 1, 2, 3 }
check(v.VectorOverload(vec), "vector<int>")
vec = { "aaa", "bbb", "ccc" }
check(v.VectorOverload(vec), "vector<string>")
]]
