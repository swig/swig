require("import") -- the import fn
import("lua_lightuserdata") -- import lib

local t = lua_lightuserdata
local d = t.get_lightuserdata()
local r = t.check_lighuserdata(d)
assert(r)
