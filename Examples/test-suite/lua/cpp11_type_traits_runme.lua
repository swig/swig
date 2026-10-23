local v=require("cpp11_type_traits")

assert(v.Elaborate(0, 0) == 1, "Elaborate should have returned 1")
-- TODO Lua do not distinquish integer to float!
-- assert(v.Elaborate(0, 0.0) == 2, "Elaborate should have returned 2")
