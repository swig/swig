-- Test for std::unordered_map wrapper in Lua
require_to_globs("cpp11_std_unordered_map")

-- Test UnorderedMapIntInt
local intMap = UnorderedMapIntInt()
assert(intMap:empty(), "New unordered_map should be empty")
assert(intMap:size() == 0, "New unordered_map should have size 0")

-- Test set and get
intMap:set(1, 100)
assert(intMap:size() == 1, "Map should have 1 element after set")
assert(intMap:get(1) == 100, "Get should return the value")
assert(intMap:has_key(1), "has_key should return true for existing key")
assert(not intMap:has_key(999), "has_key should return false for non-existing key")

-- Test contains (alias for has_key)
assert(intMap:contains(1), "contains should return true for existing key")
assert(not intMap:contains(999), "contains should return false for non-existing key")

-- Test __getitem__ and __setitem__
intMap[2] = 200
assert(intMap[2] == 200, "__getitem__ should return the value")
assert(intMap:size() == 2, "Map should have 2 elements")

-- Update existing key
intMap:set(1, 150)
assert(intMap:get(1) == 150, "Value should be updated")
assert(intMap:size() == 2, "Size should not change when updating")

intMap[1] = 175
assert(intMap[1] == 175, "Value should be updated via __setitem__")

-- Test del
intMap:del(1)
assert(intMap:size() == 1, "Size should decrease after del")
assert(not intMap:has_key(1), "Deleted key should not exist")

-- Test del with non-existing key (should throw)
local function test_del_not_found()
	intMap:del(999)
end
assert(not pcall(test_del_not_found), "del should throw for non-existing key")

-- Test get with non-existing key (should throw)
local function test_get_not_found()
	intMap:get(999)
end
assert(not pcall(test_get_not_found), "get should throw for non-existing key")

-- Test __getitem__ with non-existing key (should throw)
local function test_getitem_not_found()
	local _ = intMap[999]
end
assert(not pcall(test_getitem_not_found), "__getitem__ should throw for non-existing key")

-- Test remove
intMap:set(5, 500)
intMap:set(6, 600)
assert(intMap:remove(5), "remove should return true for existing key")
assert(intMap:size() == 2, "Size should decrease after remove")
assert(not intMap:remove(5), "remove should return false for non-existing key")
assert(intMap:size() == 2, "Size should not change when removing non-existing key")

-- Test clear
intMap:set(10, 1000)
intMap:set(20, 2000)
intMap:clear()
assert(intMap:empty(), "Map should be empty after clear")
assert(intMap:size() == 0, "Size should be 0 after clear")

-- Test copy constructor
local originalMap = UnorderedMapIntInt()
originalMap:set(1, 10)
originalMap:set(2, 20)
originalMap:set(3, 30)
local copiedMap = UnorderedMapIntInt(originalMap)
assert(copiedMap:size() == 3, "Copied map should have same size")
assert(copiedMap:get(1) == 10, "Copied map should have same values")
assert(copiedMap:get(2) == 20, "Copied map should have same values")
assert(copiedMap:get(3) == 30, "Copied map should have same values")

-- Modify copied, original should be unchanged
copiedMap:set(4, 40)
assert(originalMap:size() == 3, "Original map should be unchanged")
assert(not originalMap:has_key(4), "Original should not contain new key")

-- Test UnorderedMapStringInt
local stringMap = UnorderedMapStringInt()
assert(stringMap:empty(), "New string map should be empty")

stringMap:set("one", 1)
stringMap:set("two", 2)
stringMap:set("three", 3)

assert(stringMap:size() == 3, "String map should have 3 elements")
assert(stringMap:get("one") == 1, "Get should return correct value")
assert(stringMap:get("two") == 2, "Get should return correct value")
assert(stringMap:has_key("three"), "has_key should work with strings")
assert(not stringMap:has_key("four"), "has_key should work with strings")

stringMap:del("two")
assert(stringMap:size() == 2, "String map should have 2 elements after del")
assert(not stringMap:has_key("two"), "Deleted key should not exist")

-- Test with bracket syntax
stringMap["four"] = 4
assert(stringMap["four"] == 4, "Bracket syntax should work with strings")
