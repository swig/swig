-- Test for std::set wrapper in Lua
require("import")	-- the import fn
import("li_std_set")	-- import code

for k,v in pairs(li_std_set) do _G[k]=v end -- move to global

-- Test IntSet
local intSet = IntSet()
assert(intSet:empty() == true, "New set should be empty")
assert(intSet:size() == 0, "New set should have size 0")

-- Test insert
assert(intSet:insert(5) == true, "Inserting new element should return true")
assert(intSet:size() == 1, "Set should have 1 element after insert")
assert(intSet:insert(5) == false, "Inserting duplicate should return false")
assert(intSet:size() == 1, "Set size should not change after duplicate insert")

-- Test contains
assert(intSet:contains(5) == true, "Set should contain 5")
assert(intSet:contains(10) == false, "Set should not contain 10")

-- Test has_key (alias for contains)
assert(intSet:has_key(5) == true, "has_key should work like contains")
assert(intSet:has_key(10) == false, "has_key should work like contains")

-- Test count
assert(intSet:count(5) == 1, "count of existing element should be 1")
assert(intSet:count(10) == 0, "count of non-existing element should be 0")

-- Test add (alias for insert without return)
intSet:add(10)
assert(intSet:contains(10) == true, "add should insert element")
assert(intSet:size() == 2, "Set should have 2 elements")

-- Test multiple inserts
intSet:insert(3)
intSet:insert(7)
intSet:insert(1)
assert(intSet:size() == 5, "Set should have 5 elements")

-- Test remove
assert(intSet:remove(5) == true, "Removing existing element should return true")
assert(intSet:size() == 4, "Set should have 4 elements after remove")
assert(intSet:remove(5) == false, "Removing non-existing element should return false")
assert(intSet:size() == 4, "Set size should not change")

-- Test discard (alias for remove without return)
intSet:discard(10)
assert(intSet:contains(10) == false, "discard should remove element")
intSet:discard(999) -- should not throw for non-existing element

-- Test erase (returns count of removed elements)
intSet:insert(20)
assert(intSet:erase(20) == 1, "erase should return 1 for existing element")
assert(intSet:erase(20) == 0, "erase should return 0 for non-existing element")

-- Test clear
intSet:insert(100)
intSet:insert(200)
intSet:clear()
assert(intSet:empty() == true, "Set should be empty after clear")
assert(intSet:size() == 0, "Set should have size 0 after clear")

-- Test get (throws if not found)
intSet:insert(42)
assert(intSet:get(42) == 42, "get should return the element")

local function test_get_not_found()
    intSet:get(999)
end
assert(pcall(test_get_not_found) == false, "get should throw for non-existing element")

-- Test __getitem__
assert(intSet[42] == 42, "__getitem__ should work for existing element")

local function test_getitem_not_found()
    local _ = intSet[999]
end
assert(pcall(test_getitem_not_found) == false, "__getitem__ should throw for non-existing element")

-- Test copy constructor
local originalSet = IntSet()
originalSet:insert(1)
originalSet:insert(2)
originalSet:insert(3)
local copiedSet = IntSet(originalSet)
assert(copiedSet:size() == 3, "Copied set should have same size")
assert(copiedSet:contains(1) == true, "Copied set should contain 1")
assert(copiedSet:contains(2) == true, "Copied set should contain 2")
assert(copiedSet:contains(3) == true, "Copied set should contain 3")

-- Modify copied, original should be unchanged
copiedSet:insert(4)
assert(originalSet:size() == 3, "Original set should be unchanged")
assert(originalSet:contains(4) == false, "Original should not contain new element")

-- Test swap
local set1 = IntSet()
set1:insert(1)
set1:insert(2)
local set2 = IntSet()
set2:insert(10)
set2:insert(20)
set2:insert(30)

set1:swap(set2)
assert(set1:size() == 3, "After swap, set1 should have 3 elements")
assert(set2:size() == 2, "After swap, set2 should have 2 elements")
assert(set1:contains(10) == true, "set1 should contain 10 after swap")
assert(set2:contains(1) == true, "set2 should contain 1 after swap")

-- Test StringSet
local stringSet = StringSet()
assert(stringSet:empty() == true, "New string set should be empty")

stringSet:insert("hello")
stringSet:insert("world")
stringSet:insert("lua")

assert(stringSet:size() == 3, "String set should have 3 elements")
assert(stringSet:contains("hello") == true, "Set should contain 'hello'")
assert(stringSet:contains("swig") == false, "Set should not contain 'swig'")

stringSet:remove("world")
assert(stringSet:size() == 2, "String set should have 2 elements after remove")
assert(stringSet:contains("world") == false, "Set should not contain 'world' after remove")

-- Test FooSet (custom struct)
local fooSet = FooSet()
assert(fooSet:empty() == true, "New Foo set should be empty")

local foo1 = Foo(1)
local foo2 = Foo(2)
local foo3 = Foo(3)

fooSet:insert(foo1)
fooSet:insert(foo2)
fooSet:insert(foo3)

assert(fooSet:size() == 3, "Foo set should have 3 elements")

-- Inserting duplicate (same n value) should return false
local foo1_dup = Foo(1)
assert(fooSet:insert(foo1_dup) == false, "Inserting duplicate Foo should return false")
assert(fooSet:size() == 3, "Foo set size should not change after duplicate")

-- Test remove with Foo
local fooToRemove = Foo(2)
assert(fooSet:remove(fooToRemove) == true, "Removing Foo(2) should succeed")
assert(fooSet:size() == 2, "Foo set should have 2 elements after remove")

