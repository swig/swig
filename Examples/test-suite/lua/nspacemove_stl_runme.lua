require("import")	-- the import fn
import("nspacemove_stl")	-- import lib

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})


vi = nspacemove_stl.CPlusPlus.Standard.Ints.VectorInt()
vs = nspacemove_stl.CPlusPlus.Standard.Strings.VectorString()
mii = nspacemove_stl.CPlusPlus.Maps.MapIntInt()
mis = nspacemove_stl.CPlusPlus.Maps.MapIntString()

nspacemove_stl.test_vector_int(vi)
nspacemove_stl.test_vector_string(vs)
nspacemove_stl.test_map_int(mii)
nspacemove_stl.test_map_string(mis)
