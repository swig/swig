local v=require("cpp11_default_delete")

local st = v.sometype(22.2)
v.sometype.take(st)
st = v.sometype.make(33.3)

local st2 = v.sometype2(22.2)
v.sometype2.take(st2)
st2 = v.sometype2.make(33.3)

local st3 = v.sometype3.make(22)
v.sometype3.take(st3)
st3 = v.sometype3.make(33)
