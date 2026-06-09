require("memberin_extend_c")

local t = memberin_extend_c.Person()
t.name = "Fred Bloggs"
assert(t.name == "FRED BLOGGS", "Wrong name")
