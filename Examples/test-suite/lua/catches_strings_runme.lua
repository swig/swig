require("import")	-- the import fn
import("catches_strings")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

s, msg = pcall(function() catches_strings.StringsThrower.charstring() end)
assert(s == false and msg:find("charstring message", 1, true))

s, msg = pcall(function() catches_strings.StringsThrower.stdstring() end)
assert(s == false and msg:find("stdstring message", 1, true))
