local v=require("cpp11_inheriting_constructors")

-- Constructor inheritance via using declaration
local d = v.DerivedClass(10)
assert(d:retrieveValue() == 10, "retrieveValue()")

-- A protected member brought into the public interface through a typedef naming a base that has inheriting constructors
assert(v.UseInheritCtorTypedef(42):protectedValue() == 42, "UseInheritCtorTypedef.protectedValue()")

-- Member initialization at the site of the declaration
local s = v.SomeClass()
assert(s.value == 5, "s.value")
