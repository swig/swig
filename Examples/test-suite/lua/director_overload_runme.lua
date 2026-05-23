require("import") -- the import fn
import("director_overload") -- import lib

local o = director_overload.OverloadedGetSet()

assert(o:rw() == 42)
assert(o:rw(7) == nil)
assert(o:rw() == 7)
