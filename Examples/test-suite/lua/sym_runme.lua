require("sym")

local flim=sym.Flim()
local flam=sym.Flam()
assert(flim:hulahoops() == "flim-jam","flim:hulahoops()")
assert(flim:Jar() == "flim-jar","flim:Jar()")
assert(flam:Jam() == "flam-jam","flam:Jam()")
assert(flam:Jar() == "flam-jar","flam:Jar()")
