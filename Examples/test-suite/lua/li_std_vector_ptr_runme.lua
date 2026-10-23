local v=require("li_std_vector_ptr")

function check(val1, val2)
    assert(val1 == val2, val1 .. "!=" .. val2)
end
local ip1 = v.makeIntPtr(11)
local ip2 = v.makeIntPtr2(22)

local vi = v.IntPtrVector()
vi:push_back(ip1)
vi:push_back(ip2)
check(v.getValueFromVector(vi, 0), 11)
check(v.getValueFromVector(vi, 1), 22)

check(v.getIntValue(vi[0]), 11)
check(v.getIntValue(vi[1]), 22)
check(v.getIntValue2(vi[0]), 11)
check(v.getIntValue2(vi[1]), 22)

local ipp = v.makeIntPtrPtr(vi[0])
check(v.getIntValue3(ipp), 11) -- Note: getIntValue3 takes int**

local vA = v.APtrVector()
vA:push_back(v.makeA(33))
vA:push_back(v.makeA(34))
check(v.getVectorValueA(vA, 0), 33)

local vB = v.BPtrVector()
vB:push_back(v.makeB(133))
vB:push_back(v.makeB(134))
check(v.getVectorValueB(vB, 0), 133)

local vC = v.CPtrVector()
vC:push_back(v.makeC(1133))
vC:push_back(v.makeC(1134))
check(v.getVectorValueC(vC, 0), 1133)

--[[ TODO Lua do not convert table to std::vector<>
vA = { v.makeA(233), v.makeA(234) }
check(v.getVectorValueA(vA, 0), 233)
vB = { v.makeB(333), v.makeB(334) }
check(v.getVectorValueB(vB, 0), 333)
vC = { v.makeC(3333), v.makeC(3334) }
check(v.getVectorValueC(vC, 0), 3333)
-- mixed A and B should not be accepted
local vAB = { v.makeA(999), v.makeB(999) }
assert(not pcall(function v.getVectorValueA(vAB, 0) end))
]]

local b111 = v.makeB(111)
local bNones = v.BPtrVector()
bNones:push_back(nil)
bNones:push_back(b111)
bNones:push_back(nil)
assert(bNones:size() == 3)

local i, b
local bCount = 0
local noneCount = 0
for i = 0,2 do
  b = bNones[i]
  if b == nil then
    noneCount = noneCount + 1
  else
    assert(b.val == 111, "b.val is wrong")
    bCount = bCount + 1
  end
end
assert(bCount == 1, "bCount wrong")
assert(noneCount == 2, "noneCount wrong")
