require("import")	-- the import fn
import("template_enum")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

te = template_enum

assert( te.RGBTraits.NumComponents == 3 );

assert( te.Color.NumComponents == 3 );

x = te.foo_i.FOO
x = te.foo_d.BAR
