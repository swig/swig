require("import")	-- the import fn
import("li_cdata_cpp")	-- import lib
v = li_cdata_cpp

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

s = "ABC\0abc";
m = v.malloc(256);
v.memmove(m, s);
ss = v.cdata(m, 7);
if ss ~= "ABC\0abc" then
   error("failed")
end
