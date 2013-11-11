require("import")	-- the import fn
import("using_native_extend")	-- import code
une = using_native_extend

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

a = une.Foo()
assert( a:blah(5) == 5 );
assert( a:blah2(5) == 2 );
