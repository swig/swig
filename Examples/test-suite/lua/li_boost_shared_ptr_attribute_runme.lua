local v=require("li_boost_shared_ptr_attribute")

function check(g, expected)
    assert(g.n == expected, "Got value " .. g.n .. " should be " .. expected)
end

local gs = v.GetterSetter(5)
check(gs.myval, 25)
check(gs.AddedAttrib, 25)
gs.AddedAttrib = v.GetSetMe(6)
check(gs.myval, 6)
check(gs.AddedAttrib, 6)

local g = v.GetterOnly(4)
check(g.myval, 16)
check(g.AddedAttrib, 16)
