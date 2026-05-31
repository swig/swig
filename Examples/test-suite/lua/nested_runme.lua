local v=require("nested")

function check(a, b)
    assert(a == b, "Problem: " .. a .. " != " .. b)
end

local xx = v.x_t()
local yy = v.y_t()
local aa = v.a_t()
local bb = v.b_t()
local cc = v.c_t()
local dd = v.d_t()

v.set_union_values(100, xx, yy, aa, bb, cc, dd)

check(xx.duplicate_p.x, 100)
check(yy.duplicate_p.y, 101)
check(aa.duplicate_p.a, 102)
check(bb.duplicate_p.b, 103)
check(cc.duplicate_p.c, 104)
check(dd.duplicate_p.d, 105)
