-- Test for std::array wrapper in Lua
require("import")	-- the import fn
import("cpp11_std_array")	-- import code

for k,v in pairs(cpp11_std_array) do _G[k]=v end -- move to global

-- Helper function to compare arrays
local function compareArrays(arr, expected)
    if arr:size() ~= #expected then
        error("Array sizes differ: " .. arr:size() .. " vs " .. #expected)
    end
    for i = 0, arr:size() - 1 do
        if arr[i] ~= expected[i + 1] then
            error("Array element " .. i .. " differs: " .. arr[i] .. " vs " .. expected[i + 1])
        end
    end
end

-- Test basic array creation
local ai = ArrayInt6()
assert(ai:size() == 6, "Array should have size 6")
assert(ai:empty() == false, "Array should not be empty")

-- Test default values (should be 0 for int)
for i = 0, 5 do
    assert(ai[i] == 0, "Default value should be 0")
end

-- Test setting and getting values
local vals = {10, 20, 30, 40, 50, 60}
for i = 0, 5 do
    ai[i] = vals[i + 1]
end
compareArrays(ai, vals)

-- Test get/set methods
ai:set(0, 100)
assert(ai:get(0) == 100, "get/set methods should work")
ai:set(0, 10)  -- restore

-- Test at() method
assert(ai:at(2) == 30, "at() method should work")

-- Test front() and back()
assert(ai:front() == 10, "front() should return first element")
assert(ai:back() == 60, "back() should return last element")

-- Test fill()
local ai_fill = ArrayInt6()
ai_fill:fill(42)
for i = 0, 5 do
    assert(ai_fill[i] == 42, "fill() should set all elements to 42")
end

-- Test reverse()
local ai_rev = ArrayInt6()
for i = 0, 5 do
    ai_rev[i] = i + 1
end
ai_rev:reverse()
for i = 0, 5 do
    assert(ai_rev[i] == 6 - i, "reverse() should reverse the array")
end

-- Test arrayOutVal
local outVal = arrayOutVal()
compareArrays(outVal, {-2, -1, 0, 0, 1, 2})

-- Test arrayOutRef
local outRef = arrayOutRef()
compareArrays(outRef, {-2, -1, 0, 0, 1, 2})

-- Test arrayOutConstRef
local outConstRef = arrayOutConstRef()
compareArrays(outConstRef, {-2, -1, 0, 0, 1, 2})

-- Test arrayOutPtr
local outPtr = arrayOutPtr()
compareArrays(outPtr, {-2, -1, 0, 0, 1, 2})

-- Test arrayInVal
local inArray = ArrayInt6()
for i = 0, 5 do
    inArray[i] = i + 1
end
local resultVal = arrayInVal(inArray)
compareArrays(resultVal, {10, 20, 30, 40, 50, 60})
-- Original should be unchanged
compareArrays(inArray, {1, 2, 3, 4, 5, 6})

-- Test arrayInConstRef
local constRefArray = ArrayInt6()
for i = 0, 5 do
    constRefArray[i] = i + 1
end
local resultConstRef = arrayInConstRef(constRefArray)
compareArrays(resultConstRef, {10, 20, 30, 40, 50, 60})

-- Test arrayInRef (modifies in place)
local refArray = ArrayInt6()
for i = 0, 5 do
    refArray[i] = i + 1
end
arrayInRef(refArray)
compareArrays(refArray, {10, 20, 30, 40, 50, 60})

-- Test arrayInPtr (modifies in place)
local ptrArray = ArrayInt6()
for i = 0, 5 do
    ptrArray[i] = i + 1
end
arrayInPtr(ptrArray)
compareArrays(ptrArray, {10, 20, 30, 40, 50, 60})

-- Test copy constructor
local original = ArrayInt6()
for i = 0, 5 do
    original[i] = i * 10
end
local copied = ArrayInt6(original)
compareArrays(copied, {0, 10, 20, 30, 40, 50})
-- Modify copied, original should be unchanged
copied[0] = 999
assert(original[0] == 0, "Copy should be independent")

-- Test swap
local arr1 = ArrayInt6()
local arr2 = ArrayInt6()
for i = 0, 5 do
    arr1[i] = i
    arr2[i] = 100 + i
end
arr1:swap(arr2)
for i = 0, 5 do
    assert(arr1[i] == 100 + i, "swap failed for arr1")
    assert(arr2[i] == i, "swap failed for arr2")
end

-- Test out of bounds error handling
local function test_out_of_bounds_get()
    local arr = ArrayInt6()
    local _ = arr[6]  -- should throw
end

local function test_out_of_bounds_set()
    local arr = ArrayInt6()
    arr[6] = 42  -- should throw
end

assert(pcall(test_out_of_bounds_get) == false, "Out of bounds get should throw")
assert(pcall(test_out_of_bounds_set) == false, "Out of bounds set should throw")

-- Test overloaded function
local overloadArray = ArrayInt6()
for i = 0, 5 do
    overloadArray[i] = i + 1
end
local overloadResult = overloadFunc(overloadArray)
compareArrays(overloadResult, {100, 200, 300, 400, 500, 600})

-- The other overload (with two ints) should also work
overloadFunc(1, 2)  -- should not throw
