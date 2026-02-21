require("import") -- the import fn
import("director_frob") -- import lib

local foo = director_frob.Bravo()
local s = foo:abs_method()
assert(s == "Bravo::abs_method()")
