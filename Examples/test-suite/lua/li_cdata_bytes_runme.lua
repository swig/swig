require("import")
local v=require("li_cdata_bytes")

local m = v.predefStr()
local s = v.cdata(m, 0x200)
for i=0,0x99 do
  if string.byte(s, i + 1) ~= i then
    error("value " ..  s:byte(i + 1) .. " should be " .. i .. " at index " .. i)
  end
  if string.byte(s, i + 0x101) ~= i then
    error("value " ..  s:byte(i + 0x101) .. " should be " .. i .. " at index " .. i)
  end
end
local s2=''
for i=1,0x100 do
  local d = string.format("%c", 0x100 - i)
  s2 = s2 .. d
end
s = s2 .. s2
local m2 = v.malloc(0x200)
v.memmove(m2, s)
if v.verifyBytes(m2) < 0 then
  error("verifyBytes fails")
end
v.free(m2)
