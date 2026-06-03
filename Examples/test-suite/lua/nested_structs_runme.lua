local v=require("nested_structs")

local named = v.Named();
named.val = 999;
assert(v.nestedByVal(named), 999);
assert(v.nestedByPtr(named), 999);

local outer = v.Outer();
outer.inside1.val = 456;
assert(v.getInside1Val(outer), 456);

outer.inside1 = named;
assert(v.getInside1Val(outer), 999);
