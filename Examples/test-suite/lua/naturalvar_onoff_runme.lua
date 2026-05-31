local v=require("naturalvar_onoff")

local vars = v.Vars()
assert(not pcall(function() vars.member1On = nil end))
vars.member2Off = nil
vars.member3Off = nil
assert(not pcall(function() vars.member3On = nil end))
vars.member4Off = nil
assert(not pcall(function() vars.member4On = nil end))
