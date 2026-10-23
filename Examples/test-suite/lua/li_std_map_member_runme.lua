local v = require("li_std_map_member")

local a = v.mapita()
a:set(1, v.TestA())
assert(a:get(1).i == 1, "a[1] != 1")
a:get(1).i = 2
assert(a:get(1).i == 2, "a[1] != 2")
