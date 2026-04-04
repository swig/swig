local v=require("li_std_map")

local i, k

-- Test StringIntMap = std::map<std::string, int>
local simap = v.StringIntMap()
for i = 0,19 do
    simap:set(tostring(i), i * 18)
end

assert(simap:size() == 20, "simap:size()")
for i = 0,19 do
    k = tostring(i)
    assert(simap:has_key(k), "simap:has_key(" .. i .. ")")
    assert(simap:get(k) == i * 18)
end

-- Copy StringIntMap
local simap2 = v.StringIntMap(simap)
assert(simap2:size() == 20, "simap2:size()")
for i = 0,19 do
    k = tostring(i)
    assert(simap2:has_key(k), "simap2:has_key(" .. i .. ")")
    assert(simap2:get(k) == i * 18)
end

-- set and delete test
for i = 100,110 do
    k = tostring(i)
    simap:set(k, i * 18)
    assert(simap:has_key(k))
    assert(not simap2:has_key(k))
    simap:del(k)
    assert(not simap:has_key(k), "delete simap index " .. i)
end

-- clear test
simap:clear()
assert(simap:size() == 0, "clear")
assert(simap:empty(), "empty")

-- Average
local avg = v.valueAverage(simap2)
assert(avg == 171, "valueAverage(simap2) = " .. avg)

-- Create string with all keys
local keyStringified = v.stringifyKeys(simap2)
-- map do not remember order of insertion but order by string
assert(keyStringified == " 0 1 10 11 12 13 14 15 16 17 18 19 2 3 4 5 6 7 8 9", "stringifyKeys = " .. keyStringified)

-- Test a map with a new complex type (Struct)
local ismap = v.IntStructMap()
for i = 0,9 do
    ismap:set(i, v.Struct(i * 10.1))
end
assert(ismap:size() == 10, "ismap:size()")
for i = 0,9 do
    assert(ismap:get(i).num == i * 10.1, "ismap:get(i)")
end

-- Test a map of pointers
local ispmap = v.IntStructPtrMap()
for i = 0,9 do
    ispmap:set(i, v.Struct(i * 10.1))
end
assert(ispmap:size() == 10, "ispmap:size()")
for i = 0,9 do
    assert(ispmap:get(i).num == i * 10.1, "ispmap:get(i)")
end

-- Test a map of constant pointers
local iscpmap = v.IntStructConstPtrMap()
for i = 0,9 do
    iscpmap:set(i, v.Struct(i * 10.1))
end
assert(iscpmap:size() == 10, "iscpmap:size()")
for i = 0,9 do
    assert(iscpmap:get(i).num == i * 10.1, "iscpmap:get(i)")
end

-- Test complex type as key (Struct)
local limap = v.StructIntMap()
local s7 = v.Struct(7)
limap:set(s7, 8)
assert(limap:get(s7) == 8, "limap:get(s7)")
assert(limap:has_key(s7), "limap:has_key(s7)")
assert(not limap:has_key(v.Struct(8)), "limap:has_key(v.Struct(8))")
