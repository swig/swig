-- Test for std::unordered_map wrapper in Lua
require("import")
import_to_globs("cpp11_std_unordered_map")

-- Test UnorderedMapIntInt
local intMap = UnorderedMapIntInt()
assert(intMap:empty() == true, "New unordered_map should be empty")
assert(intMap:size() == 0, "New unordered_map should have size 0")

-- Test set and get
intMap:set(1, 100)
assert(intMap:size() == 1, "Map should have 1 element after set")
assert(intMap:get(1) == 100, "Get should return the value")
assert(intMap:has_key(1) == true, "has_key should return true for existing key")
assert(intMap:has_key(999) == false, "has_key should return false for non-existing key")

-- Test contains (alias for has_key)
assert(intMap:contains(1) == true, "contains should return true for existing key")
assert(intMap:contains(999) == false, "contains should return false for non-existing key")

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
assert(intMap:has_key(1) == false, "Deleted key should not exist")

-- Test del with non-existing key (should throw)
local function test_del_not_found()
	intMap:del(999)
end
assert(pcall(test_del_not_found) == false, "del should throw for non-existing key")

-- Test get with non-existing key (should throw)
local function test_get_not_found()
	intMap:get(999)
end
assert(pcall(test_get_not_found) == false, "get should throw for non-existing key")

-- Test __getitem__ with non-existing key (should throw)
local function test_getitem_not_found()
	local _ = intMap[999]
end
assert(pcall(test_getitem_not_found) == false, "__getitem__ should throw for non-existing key")

-- Test remove
intMap:set(5, 500)
intMap:set(6, 600)
assert(intMap:remove(5) == true, "remove should return true for existing key")
assert(intMap:size() == 2, "Size should decrease after remove")
assert(intMap:remove(5) == false, "remove should return false for non-existing key")
assert(intMap:size() == 2, "Size should not change when removing non-existing key")

-- Test clear
intMap:set(10, 1000)
intMap:set(20, 2000)
intMap:clear()
assert(intMap:empty() == true, "Map should be empty after clear")
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
assert(originalMap:has_key(4) == false, "Original should not contain new key")

-- Test UnorderedMapStringInt
local stringMap = UnorderedMapStringInt()
assert(stringMap:empty() == true, "New string map should be empty")

stringMap:set("one", 1)
stringMap:set("two", 2)
stringMap:set("three", 3)

assert(stringMap:size() == 3, "String map should have 3 elements")
assert(stringMap:get("one") == 1, "Get should return correct value")
assert(stringMap:get("two") == 2, "Get should return correct value")
assert(stringMap:has_key("three") == true, "has_key should work with strings")
assert(stringMap:has_key("four") == false, "has_key should work with strings")

stringMap:del("two")
assert(stringMap:size() == 2, "String map should have 2 elements after del")
assert(stringMap:has_key("two") == false, "Deleted key should not exist")

-- Test with bracket syntax
stringMap["four"] = 4
assert(stringMap["four"] == 4, "Bracket syntax should work with strings")
