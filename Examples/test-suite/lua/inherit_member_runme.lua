require("inherit_member")

local s = inherit_member.child()
s.pvar = "p"
s.cvar = "c"
assert(s.pvar == "p")
assert(s.cvar == "c")
