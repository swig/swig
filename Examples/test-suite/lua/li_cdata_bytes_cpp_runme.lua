local v=require("li_cdata_bytes_cpp")

local m = v.predefStr()
local s = v.cdata(m, 0x200)
for i=0,0xff do
  assert(string.byte(s, i + 1) == i,
         "value " ..  s:byte(i + 1) .. " should be " .. i .. " at index " .. i)
  assert(string.byte(s, i + 0x101) == i,
         "value " ..  s:byte(i + 0x101) .. " should be " .. i .. " at index " .. i)
end
local s2=''
for i=1,0x100 do
  local d = string.format("%c", 0x100 - i)
  s2 = s2 .. d
end
s = s2 .. s2
local m2 = v.malloc(0x200)
v.memmove(m2, s)
assert(v.verifyBytes(m2) == 0, "verifyBytes fails")
v.free(m2)
