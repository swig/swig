require("import")	-- the import fn
import("keyword_rename")	-- import lib into global
kn=keyword_rename--alias

-- catching undefined variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})


-- assert( kn.end(5) == 5 ) -- Curretly  SWIG/Lua doesn't rename keywords
-- assert( kn.nil(7) == 7 )

-- But you can always access wrongly named members using string constants
assert( kn["end"](5) == 5 )
assert( kn["nil"](7) == 7 )
