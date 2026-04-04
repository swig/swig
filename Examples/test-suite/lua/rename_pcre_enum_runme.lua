local v=require("rename_pcre_enum")

local foo = v.First
assert(foo ~= v.Second, "Enum values should be different")

-- Check that Foo_Max enum element was ignored.
assert(v.Max == nil)

local bc = v.MaxMax
assert(bc == 2, "Wrong enum value")

local c = v.red
assert(c ~= v.blue, "Enum values should be different")
