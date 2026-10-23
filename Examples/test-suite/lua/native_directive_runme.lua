local v = require("native_directive")

local s = "abc.DEF-123"
assert(v.CountAlphas(s) == 6, "CountAlphas")
