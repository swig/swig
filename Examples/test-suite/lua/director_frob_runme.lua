require("director_frob")

local foo = director_frob.Bravo()
local s = foo:abs_method()
assert(s == "Bravo::abs_method()")
