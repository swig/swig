local v=require("namespace_template")

local vc = v.vectorchar()
local vs = v.vectorshort()
local vi = v.vectorint()
local vl = v.vectorlong()

vc:blah(10)
vs:blah(10)
vi:blah(10)
vl:blah(10)

vc:vectoruse(vc, vc)
vs:vectoruse(vs, vs)
vi:vectoruse(vi, vi)
vl:vectoruse(vl, vl)
