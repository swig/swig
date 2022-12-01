require("import")	-- the import fn
import("mod_a")	-- import lib
import("mod_b")	-- import lib

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

c = mod_b.C()
d = mod_b.D()
d:DoSomething(c)
